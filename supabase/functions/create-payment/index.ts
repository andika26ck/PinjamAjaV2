import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { corsHeaders } from "../_shared/cors.ts";

const MIDTRANS_SERVER_KEY = Deno.env.get("MIDTRANS_SERVER_KEY") ?? "";
const IS_PROD = (Deno.env.get("MIDTRANS_IS_PRODUCTION") ?? "false") === "true";
const SNAP_URL = IS_PROD
  ? "https://app.midtrans.com/snap/v1/transactions"
  : "https://app.sandbox.midtrans.com/snap/v1/transactions";

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const { booking_id } = await req.json();
    if (!booking_id) return json({ message: "booking_id wajib diisi." }, 400);

    // 1) Verifikasi user dari JWT yang dikirim app
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

    // 2) Client service-role untuk tulis ke tabel payments (bypass RLS)
    const admin = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
    );

    // 3) Ambil booking + validasi kepemilikan
    const { data: booking, error: bErr } = await admin
      .from("bookings")
      .select(
        "id, item_id, renter_id, owner_id, price_per_day, total_days, deposit_amount, platform_fee, total_price, payment_status",
      )
      .eq("id", booking_id)
      .single();
    if (bErr || !booking) return json({ message: "Booking tidak ditemukan." }, 404);
    if (booking.renter_id !== user.id) {
      return json({ message: "Kamu bukan penyewa booking ini." }, 403);
    }
    if (booking.payment_status === "paid") {
      return json({ message: "Booking sudah dibayar." }, 409);
    }

    const rentalFee = Number(booking.price_per_day) * Number(booking.total_days);
    const platformFee = Number(booking.platform_fee);
    const deposit = Number(booking.deposit_amount);
    const grossAmount = Number(booking.total_price); // rental + fee + deposit

    // 4) Info tambahan untuk Midtrans (opsional tapi bagus)
    const { data: item } = await admin
      .from("items").select("title").eq("id", booking.item_id).single();
    const { data: profile } = await admin
      .from("profiles").select("name, phone").eq("id", user.id).single();

    const orderId = `PJA-${String(booking_id).slice(0, 8)}-${Date.now().toString(36)}`
      .toUpperCase();
    const expiryMinutes = 60 * 24; // 24 jam

    const itemDetails = [
      { id: "rental", name: `Sewa: ${(item?.title ?? "Barang").slice(0, 40)}`, price: rentalFee, quantity: 1 },
      { id: "platform_fee", name: "Biaya layanan", price: platformFee, quantity: 1 },
      { id: "deposit", name: "Deposit (dikembalikan)", price: deposit, quantity: 1 },
    ].filter((i) => i.price > 0);

    const payload = {
      transaction_details: { order_id: orderId, gross_amount: grossAmount },
      item_details: itemDetails,
      customer_details: {
        first_name: profile?.name ?? "Pengguna",
        email: user.email ?? undefined,
        phone: profile?.phone ?? undefined,
      },
      expiry: { unit: "minute", duration: expiryMinutes },
      credit_card: { secure: true },
    };

    // 5) Minta Snap token ke Midtrans
    const snapRes = await fetch(SNAP_URL, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Accept: "application/json",
        Authorization: `Basic ${btoa(MIDTRANS_SERVER_KEY + ":")}`,
      },
      body: JSON.stringify(payload),
    });
    const snap = await snapRes.json();
    if (!snapRes.ok || !snap.token) {
      console.error("Midtrans error", snap);
      return json(
        { message: snap?.error_messages?.join(", ") ?? "Gagal membuat transaksi Midtrans." },
        502,
      );
    }

    const expiredAt = new Date(Date.now() + expiryMinutes * 60 * 1000).toISOString();

    // 6) Simpan / update row payments (unik per booking_id)
    const { error: upErr } = await admin.from("payments").upsert(
      {
        booking_id: booking.id,
        renter_id: booking.renter_id,
        owner_id: booking.owner_id,
        midtrans_order_id: orderId,
        snap_token: snap.token,
        snap_redirect_url: snap.redirect_url ?? null,
        rental_fee: rentalFee,
        deposit_amount: deposit,
        platform_fee: platformFee,
        total_amount: grossAmount,
        status: "pending",
        expired_at: expiredAt,
        updated_at: new Date().toISOString(),
      },
      { onConflict: "booking_id" },
    );
    if (upErr) {
      console.error("Upsert payment error", upErr);
      return json({ message: "Gagal menyimpan data pembayaran." }, 500);
    }

    // 7) Balikan sesuai PaymentRequestModel di app
    return json(
      {
        snap_token: snap.token,
        snap_redirect_url: snap.redirect_url ?? null,
        order_id: orderId,
        total_amount: grossAmount,
        expired_at: expiredAt,
      },
      200,
    );
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