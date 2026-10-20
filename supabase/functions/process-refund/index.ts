import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { corsHeaders } from "../_shared/cors.ts";

const MIDTRANS_SERVER_KEY = Deno.env.get("MIDTRANS_SERVER_KEY") ?? "";
const IS_PROD = (Deno.env.get("MIDTRANS_IS_PRODUCTION") ?? "false") === "true";
// Refund pakai Core API (api.*), beda host dengan Snap (app.*)
const CORE_BASE = IS_PROD
  ? "https://api.midtrans.com"
  : "https://api.sandbox.midtrans.com";

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const { booking_id, reason } = await req.json();
    if (!booking_id) return json({ message: "booking_id wajib diisi." }, 400);

    // 1) Verifikasi user
    const authHeader = req.headers.get("Authorization") ?? "";
    const userClient = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_ANON_KEY")!,
      { global: { headers: { Authorization: authHeader } } },
    );
    const {
      data: { user },
      error: userErr,
    } = await userClient.auth.getUser();
    if (userErr || !user) return json({ message: "Tidak terautentikasi." }, 401);

    const admin = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
    );

    // 2) Ambil payment + validasi
    const { data: payment, error } = await admin
      .from("payments")
      .select("id, booking_id, renter_id, owner_id, midtrans_order_id, total_amount, status")
      .eq("booking_id", booking_id)
      .single();
    if (error || !payment) return json({ message: "Pembayaran tidak ditemukan." }, 404);
    if (payment.renter_id !== user.id && payment.owner_id !== user.id) {
      return json({ message: "Kamu tidak berhak atas pembayaran ini." }, 403);
    }
    if (payment.status !== "paid") {
      return json({ message: "Hanya pembayaran berstatus paid yang bisa direfund." }, 409);
    }

    // 3) Tandai refund_pending
    await admin.from("payments").update({
      status: "refund_pending",
      refund_reason: reason ?? null,
      updated_at: new Date().toISOString(),
    }).eq("id", payment.id);

    // 4) Panggil Midtrans Refund API
    const refundRes = await fetch(
      `${CORE_BASE}/v2/${payment.midtrans_order_id}/refund`,
      {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Accept: "application/json",
          Authorization: `Basic ${btoa(MIDTRANS_SERVER_KEY + ":")}`,
        },
        body: JSON.stringify({
          refund_key: `RF-${payment.id}-${Date.now().toString(36)}`,
          amount: Number(payment.total_amount),
          reason: reason ?? "Refund oleh pengguna",
        }),
      },
    );
    const refund = await refundRes.json();
    const ok = refundRes.ok && ["200", "201"].includes(String(refund.status_code));

    if (!ok) {
      console.error("Refund gagal", refund);
      // Kembalikan ke paid bila Midtrans menolak
      await admin.from("payments")
        .update({ status: "paid", updated_at: new Date().toISOString() })
        .eq("id", payment.id);
      await admin.from("payment_audit_logs").insert({
        payment_id: payment.id,
        booking_id: payment.booking_id,
        action: "refund_failed",
        old_status: "paid",
        new_status: "paid",
        actor: "user",
        metadata: { response: refund },
      });
      return json(
        { message: refund?.status_message ?? "Refund ditolak Midtrans." },
        502,
      );
    }

    // 5) Sukses: set refunded + batalkan booking
    await admin.from("payments").update({
      status: "refunded",
      refunded_at: new Date().toISOString(),
      refund_amount: Number(payment.total_amount),
      updated_at: new Date().toISOString(),
    }).eq("id", payment.id);

    await admin.from("bookings").update({
      status: "cancelled",
      payment_status: "refunded",
    }).eq("id", payment.booking_id);

    await admin.from("payment_audit_logs").insert({
      payment_id: payment.id,
      booking_id: payment.booking_id,
      action: "refunded",
      old_status: "paid",
      new_status: "refunded",
      actor: "user",
      metadata: { reason: reason ?? null, response: refund },
    });

    return json({ status: "refunded" }, 200);
  } catch (e) {
    console.error(e);
    return json({ message: "Terjadi kesalahan tak terduga." }, 500);
  }
});

function json(body: unknown, status: number) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}