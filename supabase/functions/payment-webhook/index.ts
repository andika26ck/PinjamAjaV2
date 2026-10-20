import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const MIDTRANS_SERVER_KEY = Deno.env.get("MIDTRANS_SERVER_KEY") ?? "";

Deno.serve(async (req) => {
  if (req.method !== "POST") {
    return new Response("Method Not Allowed", { status: 405 });
  }

  try {
    const body = await req.json();
    const {
      order_id,
      status_code,
      gross_amount,
      signature_key,
      transaction_status,
      fraud_status,
      payment_type,
      transaction_id,
    } = body;

    // 1) Verifikasi signature: sha512(order_id + status_code + gross_amount + server_key)
    const expected = await sha512(
      `${order_id}${status_code}${gross_amount}${MIDTRANS_SERVER_KEY}`,
    );
    if (expected !== signature_key) {
      console.error("Invalid signature", { order_id });
      return jsonResp({ message: "Invalid signature" }, 403);
    }

    const admin = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
    );

    // 2) Cari payment berdasarkan order_id
    const { data: payment, error } = await admin
      .from("payments")
      .select("id, booking_id, status")
      .eq("midtrans_order_id", order_id)
      .single();
    if (error || !payment) {
      console.error("Payment tidak ditemukan", order_id);
      return jsonResp({ message: "Payment not found" }, 404);
    }

    // 3) Tentukan status sukses
    const isSuccess =
      (transaction_status === "capture" && fraud_status === "accept") ||
      transaction_status === "settlement";

    const channel =
      body?.va_numbers?.[0]?.bank ??
      body?.store ??
      body?.acquirer ??
      payment_type ??
      null;

    if (isSuccess) {
      // Idempotent: RPC hanya update jika belum 'paid'
      const { error: rpcErr } = await admin.rpc("handle_payment_success", {
        p_booking_id: payment.booking_id,
        p_transaction_id: transaction_id ?? null,
        p_payment_method: payment_type ?? null,
        p_payment_channel: channel,
      });
      if (rpcErr) {
        console.error("RPC handle_payment_success error", rpcErr);
        return jsonResp({ message: "DB update failed" }, 500);
      }
    } else if (transaction_status === "pending") {
      await admin.from("payments")
        .update({ status: "pending", updated_at: new Date().toISOString() })
        .eq("id", payment.id);
    } else if (transaction_status === "expire") {
      await setStatus(admin, payment, "expired", transaction_id, transaction_status);
    } else if (["deny", "cancel", "failure"].includes(transaction_status)) {
      await setStatus(admin, payment, "failed", transaction_id, transaction_status);
    } else if (["refund", "partial_refund"].includes(transaction_status)) {
      await setStatus(admin, payment, "refunded", transaction_id, transaction_status);
    }

    // 4) Selalu balas 200 supaya Midtrans berhenti retry
    return jsonResp({ received: true }, 200);
  } catch (e) {
    console.error(e);
    return jsonResp({ message: "error" }, 500);
  }
});

async function setStatus(
  admin: any,
  payment: { id: string; booking_id: string; status: string },
  status: string,
  txId: string | null,
  txStatus: string,
) {
  await admin.from("payments").update({
    status,
    refunded_at: status === "refunded" ? new Date().toISOString() : undefined,
    updated_at: new Date().toISOString(),
  }).eq("id", payment.id);

  await admin.from("payment_audit_logs").insert({
    payment_id: payment.id,
    booking_id: payment.booking_id,
    action: "webhook_status",
    old_status: payment.status,
    new_status: status,
    actor: "webhook",
    metadata: { transaction_id: txId, midtrans_status: txStatus },
  });

  // Lepas booking agar tanggal bisa dipakai lagi kalau gagal/kadaluarsa
  if (status === "expired" || status === "failed") {
    await admin.from("bookings")
      .update({ payment_status: "unpaid" })
      .eq("id", payment.booking_id);
  }
}

async function sha512(input: string): Promise<string> {
  const data = new TextEncoder().encode(input);
  const hash = await crypto.subtle.digest("SHA-512", data);
  return Array.from(new Uint8Array(hash))
    .map((b) => b.toString(16).padStart(2, "0"))
    .join("");
}

function jsonResp(body: unknown, status: number) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { "Content-Type": "application/json" },
  });
}