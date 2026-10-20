/// Hasil RPC `admin_dashboard_stats()` — ringkasan untuk dashboard admin.
class AdminDashboardStats {
  final int totalUsers;
  final int suspendedUsers;
  final int kycPending;
  final int totalItems;
  final int flaggedItems;
  final int totalBookings;
  final int activeBookings;
  final int completedBookings;
  final int openReports;
  final int openDisputes;
  final int pendingPayouts;
  final int gmv; // gross merchandise value (Rp)
  final int platformRevenue; // total komisi (Rp)

  const AdminDashboardStats({
    this.totalUsers = 0,
    this.suspendedUsers = 0,
    this.kycPending = 0,
    this.totalItems = 0,
    this.flaggedItems = 0,
    this.totalBookings = 0,
    this.activeBookings = 0,
    this.completedBookings = 0,
    this.openReports = 0,
    this.openDisputes = 0,
    this.pendingPayouts = 0,
    this.gmv = 0,
    this.platformRevenue = 0,
  });

  factory AdminDashboardStats.fromJson(Map<String, dynamic> json) {
    int n(String key) => (json[key] as num?)?.toInt() ?? 0;
    return AdminDashboardStats(
      totalUsers: n('total_users'),
      suspendedUsers: n('suspended_users'),
      kycPending: n('kyc_pending'),
      totalItems: n('total_items'),
      flaggedItems: n('flagged_items'),
      totalBookings: n('total_bookings'),
      activeBookings: n('active_bookings'),
      completedBookings: n('completed_bookings'),
      openReports: n('open_reports'),
      openDisputes: n('open_disputes'),
      pendingPayouts: n('pending_payouts'),
      gmv: n('gmv'),
      platformRevenue: n('platform_revenue'),
    );
  }
}