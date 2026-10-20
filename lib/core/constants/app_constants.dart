/// Konstanta global aplikasi & konfigurasi Supabase.
class AppConstants {
  AppConstants._();

  static const String appName = 'PinjamAja';

  // Isi via --dart-define saat run/build, atau ganti default di bawah.
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://YOUR-PROJECT.supabase.co',
  );
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'YOUR-ANON-KEY',
  );

  // Storage buckets
  static const String itemImagesBucket = 'item-images';
  static const String avatarsBucket = 'avatars';
  static const String kycDocsBucket = 'kyc-docs'; // (+) KYC (bucket privat)
  static const String disputeEvidenceBucket = 'dispute-evidence'; // (+) Sengketa (privat)

  // Deep link untuk OAuth / reset password (sesuaikan native config).
  static const String oauthRedirectUrl = 'io.pinjamaja://login-callback/';

  // ===== Barang (Item) =====
  static const int minItemPhotos = 1;
  static const int maxItemPhotos = 5;
  static const int maxTitleLength = 100;
  static const int minDescriptionLength = 20;

  // Status barang (kolom items.status)
  static const String itemStatusAvailable = 'available';
  static const String itemStatusRented = 'rented';
  static const String itemStatusInactive = 'inactive';

  // ===== Booking =====
  // Biaya layanan platform = 5% dari subtotal sewa.
  static const double platformFeeRate = 0.05;

  // Status booking (kolom bookings.status)
  static const String bookingStatusPending = 'pending';
  static const String bookingStatusConfirmed = 'confirmed';
  static const String bookingStatusActive = 'active';
  static const String bookingStatusCompleted = 'completed';
  static const String bookingStatusCancelled = 'cancelled';
  static const String bookingStatusAwaitingPayment = 'awaiting_payment';

  // ===== Pembayaran =====
  // Status pembayaran pada booking (kolom bookings.payment_status)
  static const String paymentStatusUnpaid = 'unpaid';
  static const String paymentStatusPaid = 'paid';

  // === Denda keterlambatan & deposit (fitur denda) ===
/// Toleransi pengembalian: sampai jam 12 siang H+1 dari tanggal selesai.
static const int lateGraceUntilHour = 12;

/// Denda per hari telat = (tarif sewa harian) x rate ini. 1.0 = 1x tarif.
static const double lateFeeRatePerDay = 1.0;

/// Deposit minimal yang wajib di-set owner = (harga sewa/hari) x rate ini.
static const double depositMinRate = 1.0; // 100%

static const String lateFeeStatusNone = 'none';
static const String lateFeeStatusUnpaid = 'unpaid';
static const String lateFeeStatusPaid = 'paid';

// --- Konfirmasi pemilik & refund (escrow) ---
// Tenggat pemilik untuk Terima/Tolak setelah penyewa membayar (jam).
// Lewat tenggat: booking auto-cancel & dana dikembalikan penuh.
static const int ownerConfirmDeadlineHours = 24;

// Status pengembalian dana.
static const String refundStatusNone = 'none';
static const String refundStatusPending = 'pending';
static const String refundStatusRefunded = 'refunded';
}