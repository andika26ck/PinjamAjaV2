import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../data/search_filters.dart';
import '../../providers/home_provider.dart';
import '../../providers/search_provider.dart';

/// Tampilkan bottom sheet filter pencarian.
Future<void> showFilterBottomSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => const FilterBottomSheet(),
  );
}

class FilterBottomSheet extends ConsumerStatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  ConsumerState<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends ConsumerState<FilterBottomSheet> {
  static const List<(String, String)> _conditionOptions = [
    ('baru', 'Baru'),
    ('sangat_baik', 'Sangat Baik'),
    ('baik', 'Baik'),
    ('cukup', 'Cukup'),
  ];
  static const List<(int?, String)> _radiusOptions = [
    (10, '10 km'),
    (25, '25 km'),
    (50, '50 km'),
    (null, 'Semua'),
  ];

  late List<String> _categoryIds;
  late List<String> _conditions;
  late RangeValues _price;
  int? _radiusKm;

  @override
  void initState() {
    super.initState();
    final f = ref.read(searchControllerProvider).filters;
    _categoryIds = [...f.categoryIds];
    _conditions = [...f.conditions];
    _price = RangeValues(f.minPrice, f.maxPrice);
    _radiusKm = f.radiusKm;
  }

  void _reset() {
    setState(() {
      _categoryIds = [];
      _conditions = [];
      _price = const RangeValues(
          SearchFilters.priceFloor, SearchFilters.priceCeil);
      _radiusKm = null;
    });
  }

  void _apply() {
    ref.read(searchControllerProvider.notifier).applyFilters(
          SearchFilters(
            categoryIds: _categoryIds,
            conditions: _conditions,
            minPrice: _price.start,
            maxPrice: _price.end,
            radiusKm: _radiusKm,
          ),
        );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final cats = ref.watch(categoriesProvider);
    return SafeArea(
      child: Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Filter',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
              const SizedBox(height: 20),

              // Kategori (multi-select)
              const Text('Kategori', style: _labelStyle),
              const SizedBox(height: 10),
              cats.maybeWhen(
                data: (list) => Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: list.map((c) {
                    final sel = _categoryIds.contains(c.id);
                    return FilterChip(
                      label: Text(c.name),
                      selected: sel,
                      onSelected: (v) => setState(() {
                        v ? _categoryIds.add(c.id) : _categoryIds.remove(c.id);
                      }),
                    );
                  }).toList(),
                ),
                orElse: () => const SizedBox(
                  height: 24,
                  child: Center(
                      child: Text('Memuat kategori...',
                          style: TextStyle(color: AppColors.textTertiary))),
                ),
              ),
              const SizedBox(height: 20),

              // Range harga
              Row(
                children: [
                  const Text('Harga per hari', style: _labelStyle),
                  const Spacer(),
                  Text(
                    '${Formatters.rupiah(_price.start)} - ${Formatters.rupiah(_price.end)}',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
              RangeSlider(
                values: _price,
                min: SearchFilters.priceFloor,
                max: SearchFilters.priceCeil,
                divisions: 20,
                labels: RangeLabels(
                  Formatters.rupiah(_price.start),
                  Formatters.rupiah(_price.end),
                ),
                onChanged: (v) => setState(() => _price = v),
              ),
              const SizedBox(height: 12),

              // Kondisi barang
              const Text('Kondisi', style: _labelStyle),
              const SizedBox(height: 6),
              ..._conditionOptions.map((opt) {
                final sel = _conditions.contains(opt.$1);
                return CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  controlAffinity: ListTileControlAffinity.leading,
                  value: sel,
                  title: Text(opt.$2),
                  onChanged: (v) => setState(() {
                    (v ?? false)
                        ? _conditions.add(opt.$1)
                        : _conditions.remove(opt.$1);
                  }),
                );
              }),
              const SizedBox(height: 12),

              // Radius lokasi
              const Text('Radius lokasi', style: _labelStyle),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                children: _radiusOptions.map((opt) {
                  final sel = _radiusKm == opt.$1;
                  return ChoiceChip(
                    label: Text(opt.$2),
                    selected: sel,
                    onSelected: (_) => setState(() => _radiusKm = opt.$1),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _reset,
                      child: const Text('Reset'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _apply,
                      child: const Text('Terapkan Filter'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

const _labelStyle = TextStyle(fontSize: 15, fontWeight: FontWeight.w600);