import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/utils/app_exception.dart';
import '../../../data/models/booking.dart';
import '../../auth/providers/auth_provider.dart';
import 'item_detail_provider.dart';

part 'owner_stats_provider.g.dart';

// Status booking yang dihitung sebagai pendapatan / sedang aktif.
// Sesuaikan dengan nilai enum `status` di tabel bookings milikmu.
const _revenueStatuses = {'confirmed', 'active', 'ongoing', 'completed', 'paid'};
const _activeStatuses = {'confirmed', 'active', 'ongoing', 'paid'};

bool _isRevenue(String status) => _revenueStatuses.contains(status);
bool _isActive(String status) => _activeStatuses.contains(status);

DateTime _dayOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// Statistik ringkas per item untuk ditampilkan di daftar Owner Dashboard.
class ItemMiniStat {
  final int totalBookings;
  final int revenueThisMonth;
  const ItemMiniStat({this.totalBookings = 0, this.revenueThisMonth = 0});
}

class _Acc {
  int total = 0;
  int revenue = 0;
}

/// Map itemId -> statistik mini, dari satu query semua booking milik owner.
@riverpod
Future<Map<String, ItemMiniStat>> ownerItemStats(
    OwnerItemStatsRef ref) async {
  final userId = ref.watch(supabaseClientProvider).auth.currentUser?.id;
  if (userId == null) {
    throw const AppException('Sesi tidak ditemukan. Silakan masuk ulang.');
  }
  final bookings =
      await ref.watch(itemRepositoryProvider).fetchOwnerBookings(userId);
  final now = DateTime.now();
  final acc = <String, _Acc>{};
  for (final b in bookings) {
    final a = acc.putIfAbsent(b.itemId, _Acc.new);
    a.total++;
    final c = b.createdAt;
    if (c != null &&
        c.year == now.year &&
        c.month == now.month &&
        _isRevenue(b.status)) {
      a.revenue += b.totalPrice;
    }
  }
  return {
    for (final e in acc.entries)
      e.key: ItemMiniStat(
        totalBookings: e.value.total,
        revenueThisMonth: e.value.revenue,
      ),
  };
}

/// Statistik lengkap untuk satu item (layar stats).
class ItemStatsBundle {
  final int totalRevenue;
  final int activeBookings;
  final double avgRating;
  final List<int> last7DaysRevenue; // index 0 = 6 hari lalu, 6 = hari ini
  final List<DateTime> last7DaysLabels;
  final List<Booking> recentBookings;

  const ItemStatsBundle({
    this.totalRevenue = 0,
    this.activeBookings = 0,
    this.avgRating = 0,
    this.last7DaysRevenue = const [],
    this.last7DaysLabels = const [],
    this.recentBookings = const [],
  });
}

@riverpod
Future<ItemStatsBundle> itemStats(ItemStatsRef ref, String itemId) async {
  final repo = ref.watch(itemRepositoryProvider);
  final bookings = await repo.fetchItemBookings(itemId);
  final reviews = await repo.fetchReviews(itemId, limit: 100);

  final today = _dayOnly(DateTime.now());
  final labels = List<DateTime>.generate(
      7, (i) => today.subtract(Duration(days: 6 - i)));
  final daily = List<int>.filled(7, 0);

  var totalRevenue = 0;
  var activeBookings = 0;
  for (final b in bookings) {
    if (_isRevenue(b.status)) totalRevenue += b.totalPrice;
    if (_isActive(b.status)) activeBookings++;
    final c = b.createdAt;
    if (c != null && _isRevenue(b.status)) {
      final d = _dayOnly(c);
      final idx = labels.indexWhere((l) => l == d);
      if (idx >= 0) daily[idx] += b.totalPrice;
    }
  }

  final avgRating = reviews.isEmpty
      ? 0.0
      : reviews.map((r) => r.rating).reduce((a, b) => a + b) / reviews.length;

  return ItemStatsBundle(
    totalRevenue: totalRevenue,
    activeBookings: activeBookings,
    avgRating: avgRating,
    last7DaysRevenue: daily,
    last7DaysLabels: labels,
    recentBookings: bookings.take(5).toList(),
  );
}