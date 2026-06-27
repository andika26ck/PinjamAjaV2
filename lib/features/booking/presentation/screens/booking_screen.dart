import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/app_exception.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../data/models/item.dart';
import '../../../items/presentation/screens/item_detail_screen.dart'
    show conditionColor;
import '../../providers/booking_provider.dart';
import '../widgets/booking_card.dart';
import 'payment_screen.dart';

const _h = TextStyle(fontSize: 18, fontWeight: FontWeight.w700);

class BookingScreen extends ConsumerWidget {
  final String itemId; // = item_id
  final Item? item;
  const BookingScreen({super.key, required this.itemId, this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final passed = item;
    if (passed != null) return _BookingFlow(item: passed);
    final async = ref.watch(bookingItemProvider(itemId));
    return Scaffold(
      appBar: AppBar(title: const Text('Sewa Barang')),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text(e is AppException ? e.message : 'Gagal memuat barang.'),
        ),
        data: (it) => _BookingFlow(item: it),
      ),
    );
  }
}

class _BookingFlow extends ConsumerStatefulWidget {
  final Item item;
  const _BookingFlow({required this.item});
  @override
  ConsumerState<_BookingFlow> createState() => _BookingFlowState();
}

class _BookingFlowState extends ConsumerState<_BookingFlow> {
  final _pageController = PageController();
  final _notesC = TextEditingController();
  int _step = 0;
  DateTime? _start;
  DateTime? _end;
  DateTime _focusedDay = DateTime.now();

  late final Set<DateTime> _blocked = {
    for (final d in widget.item.blockedDates)
      DateTime(d.year, d.month, d.day),
  };

  @override
  void dispose() {
    _pageController.dispose();
    _notesC.dispose();
    super.dispose();
  }

  int get _totalDay =>
      (_start == null || _end == null) ? 0 : _end!.difference(_start!).inDays + 1;
  int get _subtotal => widget.item.pricePerDay * _totalDay;
  int get _fee => (_subtotal * AppConstants.platformFeeRate).round();
  int get _deposit => widget.item.depositAmount;
  int get _total => _subtotal + _fee + _deposit;

  bool _isBlocked(DateTime day) =>
      _blocked.contains(DateTime(day.year, day.month, day.day));

  bool _rangeHasBlocked() {
    if (_start == null || _end == null) return false;
    for (var d = _start!; !d.isAfter(_end!); d = d.add(const Duration(days: 1))) {
      if (_isBlocked(d)) return true;
    }
    return false;
  }

  void _goTo(int step) {
    setState(() => _step = step);
    _pageController.animateToPage(step,
        duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  void _next() {
    if (_step == 0) {
      if (_start == null || _end == null) {
        _snack('Pilih tanggal sewa dulu.');
        return;
      }
      if (_rangeHasBlocked()) {
        _snack('Rentang tanggal memuat hari yang tidak tersedia.', error: true);
        return;
      }
    }
    if (_step < 2) _goTo(_step + 1);
  }

  void _back() {
    if (_step > 0) _goTo(_step - 1);
  }

  void _snack(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: error ? AppColors.error : null,
    ));
  }

  Future<void> _confirmAndPay() async {
    final booking =
        await ref.read(bookingControllerProvider.notifier).createBooking(
              item: widget.item,
              start: _start!,
              end: _end!,
              notes: _notesC.text,
            );
    if (!mounted || booking == null) return;
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (_) => PaymentScreen(booking: booking, item: widget.item),
    ));
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<void>>(bookingControllerProvider, (_, next) {
      next.whenOrNull(error: (e, _) {
        _snack(e is AppException ? e.message : 'Terjadi kesalahan.',
            error: true);
      });
    });
    final saving = ref.watch(bookingControllerProvider).isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Sewa Barang')),
      body: Column(
        children: [
          _StepIndicator(step: _step),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [_stepDates(), _stepSummary(), _stepConfirm()],
            ),
          ),
          _bottomBar(saving),
        ],
      ),
    );
  }

  // ---- STEP 1: Pilih tanggal ----
  Widget _stepDates() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text('Pilih tanggal sewa', style: _h),
        const SizedBox(height: 4),
        const Text('Tanggal merah tidak tersedia.',
            style: TextStyle(color: AppColors.textTertiary, fontSize: 12)),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          padding: const EdgeInsets.all(8),
          child: TableCalendar<void>(
            firstDay: DateTime.now().subtract(const Duration(days: 1)),
            lastDay: DateTime.now().add(const Duration(days: 365)),
            focusedDay: _focusedDay,
            rangeSelectionMode: RangeSelectionMode.toggledOn,
            rangeStartDay: _start,
            rangeEndDay: _end,
            headerStyle: const HeaderStyle(
                formatButtonVisible: false, titleCentered: true),
            availableGestures: AvailableGestures.horizontalSwipe,
            enabledDayPredicate: (day) => !_isBlocked(day),
            calendarStyle: const CalendarStyle(
              rangeHighlightColor: Color(0x332563EB),
              rangeStartDecoration: BoxDecoration(
                  color: AppColors.primary, shape: BoxShape.circle),
              rangeEndDecoration: BoxDecoration(
                  color: AppColors.primary, shape: BoxShape.circle),
              todayDecoration: BoxDecoration(
                  color: AppColors.primaryLight, shape: BoxShape.circle),
            ),
            calendarBuilders: CalendarBuilders(
              disabledBuilder: (context, day, _) =>
                  _isBlocked(day) ? _blockedCell(day) : null,
            ),
            onPageChanged: (d) => _focusedDay = d,
            onRangeSelected: (start, end, focused) {
              setState(() {
                _start = start == null
                    ? null
                    : DateTime(start.year, start.month, start.day);
                _end = end == null
                    ? null
                    : DateTime(end.year, end.month, end.day);
                _focusedDay = focused;
              });
            },
          ),
        ),
        const SizedBox(height: 16),
        if (_start != null)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.date_range, color: AppColors.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _end == null
                        ? 'Mulai ${formatShortDate(_start)} — pilih tanggal selesai'
                        : '${formatShortDate(_start)} → ${formatShortDate(_end)}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                if (_end != null)
                  Text('$_totalDay hari',
                      style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700)),
              ],
            ),
          ),
      ],
    );
  }

  Widget _blockedCell(DateTime day) => Container(
        margin: const EdgeInsets.all(4),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.error.withOpacity(0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text('${day.day}',
            style: const TextStyle(
                color: AppColors.error,
                decoration: TextDecoration.lineThrough)),
      );

  // ---- STEP 2: Ringkasan ----
  Widget _stepSummary() {
    final item = widget.item;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text('Ringkasan booking', style: _h),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 64,
                  height: 64,
                  child: item.thumbnailUrl != null
                      ? Image.network(item.thumbnailUrl!, fit: BoxFit.cover)
                      : const ColoredBox(color: AppColors.surfaceVariant),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 15)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: conditionColor(item.condition).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(item.condition.label,
                          style: TextStyle(
                              color: conditionColor(item.condition),
                              fontSize: 11,
                              fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _summaryRow('Mulai', formatShortDate(_start)),
        _summaryRow('Selesai', formatShortDate(_end)),
        _summaryRow('Total hari', '$_totalDay hari'),
        const Divider(height: 28),
        _priceRow('Harga sewa',
            '${Formatters.rupiah(item.pricePerDay)} × $_totalDay hari',
            Formatters.rupiah(_subtotal)),
        _priceRow('Deposit', 'Dikembalikan setelah sewa',
            Formatters.rupiah(_deposit)),
        _priceRow('Biaya layanan (5%)', null, Formatters.rupiah(_fee)),
        const Divider(height: 28),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('TOTAL',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            Text(Formatters.rupiah(_total),
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary)),
          ],
        ),
        const SizedBox(height: 24),
        const Text('Catatan untuk owner (opsional)',
            style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          controller: _notesC,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Contoh: ambil barang sore hari, dll.',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget _summaryRow(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: AppColors.textSecondary)),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      );

  Widget _priceRow(String label, String? sub, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label),
                  if (sub != null)
                    Text(sub,
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.textTertiary)),
                ],
              ),
            ),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      );

  // ---- STEP 3: Konfirmasi ----
  Widget _stepConfirm() {
    final item = widget.item;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text('Konfirmasi & bayar', style: _h),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.06),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.primary.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.title,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 16)),
              const SizedBox(height: 8),
              Text(
                  '${formatShortDate(_start)} → ${formatShortDate(_end)}  ·  $_totalDay hari',
                  style: const TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total bayar',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  Text(Formatters.rupiah(_total),
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Dengan melanjutkan, kamu menyetujui ketentuan sewa & kebijakan '
          'deposit PinjamAja. Deposit dikembalikan setelah barang dikembalikan '
          'dalam kondisi baik.',
          style: TextStyle(
              fontSize: 12, color: AppColors.textSecondary, height: 1.5),
        ),
      ],
    );
  }

  Widget _bottomBar(bool saving) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: Row(
          children: [
            if (_step > 0) ...[
              Expanded(
                child: OutlinedButton(
                  onPressed: saving ? null : _back,
                  child: const Text('Kembali'),
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed:
                    saving ? null : (_step < 2 ? _next : _confirmAndPay),
                child: saving
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 2.5, color: Colors.white))
                    : Text(_step < 2 ? 'Lanjut' : 'Konfirmasi & Bayar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  final int step;
  const _StepIndicator({required this.step});
  static const _labels = ['Tanggal', 'Ringkasan', 'Bayar'];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: List.generate(_labels.length * 2 - 1, (i) {
          if (i.isOdd) {
            final done = (i ~/ 2) < step;
            return Expanded(
              child: Container(
                height: 2,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                color: done ? AppColors.primary : AppColors.border,
              ),
            );
          }
          final idx = i ~/ 2;
          final reached = idx <= step;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 26,
                width: 26,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: reached ? AppColors.primary : AppColors.surfaceVariant,
                  shape: BoxShape.circle,
                ),
                child: Text('${idx + 1}',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color:
                            reached ? Colors.white : AppColors.textTertiary)),
              ),
              const SizedBox(height: 4),
              Text(_labels[idx],
                  style: TextStyle(
                      fontSize: 11,
                      color: reached
                          ? AppColors.textPrimary
                          : AppColors.textTertiary)),
            ],
          );
        }),
      ),
    );
  }
}