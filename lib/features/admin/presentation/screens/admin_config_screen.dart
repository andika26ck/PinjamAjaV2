import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../providers/admin_controller.dart';
import '../../providers/admin_providers.dart';
import '../widgets/admin_scaffold.dart';

/// Metadata field konfigurasi yang dikenal (selaras key seed `app_config`).
class _ConfigSpec {
  final String key;
  final String label;
  final String helper;
  final bool isInt;
  final bool isPercent; // tampilkan preview % di bawah field
  const _ConfigSpec(this.key, this.label, this.helper,
      {this.isInt = false, this.isPercent = false});
}

const _configSpecs = <_ConfigSpec>[
  _ConfigSpec('platform_fee_rate', 'Komisi platform',
      'Desimal. 0.05 = 5% dari subtotal sewa.', isPercent: true),
  _ConfigSpec('deposit_min_rate', 'Deposit minimum',
      'Relatif tarif harian. 1.0 = 100% tarif/hari.'),
  _ConfigSpec('late_fee_rate_per_day', 'Denda keterlambatan / hari',
      'Relatif tarif harian. 1.0 = 100% tarif/hari.'),
  _ConfigSpec('owner_confirm_deadline_hours', 'Batas konfirmasi pemilik',
      'Dalam jam. Lewat ini pesanan otomatis dibatalkan.', isInt: true),
];

class AdminConfigScreen extends ConsumerStatefulWidget {
  const AdminConfigScreen({super.key});

  @override
  ConsumerState<AdminConfigScreen> createState() => _AdminConfigScreenState();
}

class _AdminConfigScreenState extends ConsumerState<AdminConfigScreen> {
  final Map<String, TextEditingController> _controllers = {};
  bool _seeded = false;

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  /// Isi controller sekali dari config yang dimuat.
  void _seed(Map<String, dynamic> config) {
    if (_seeded) return;
    for (final spec in _configSpecs) {
      _controllers[spec.key] =
          TextEditingController(text: _fmt(config[spec.key], spec.isInt));
    }
    _seeded = true;
  }

  String _fmt(dynamic raw, bool isInt) {
    if (raw == null) return '';
    if (raw is num) {
      return isInt ? raw.toInt().toString() : _trimNum(raw);
    }
    return raw.toString();
  }

  String _trimNum(num n) {
    var s = n.toString();
    if (s.contains('.')) {
      s = s.replaceAll(RegExp(r'0+$'), '');
      s = s.replaceAll(RegExp(r'\.$'), '');
    }
    return s;
  }

  Future<void> _saveAll(Map<String, dynamic> current) async {
    final controller = ref.read(adminControllerProvider.notifier);
    var changed = 0;
    var failed = 0;
    for (final spec in _configSpecs) {
      final text = _controllers[spec.key]?.text.trim() ?? '';
      if (text.isEmpty) continue;
      final Object? parsed =
          spec.isInt ? int.tryParse(text) : num.tryParse(text);
      if (parsed == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Nilai "${spec.label}" tidak valid.'),
          backgroundColor: AppColors.error,
        ));
        return;
      }
      final cur = current[spec.key];
      final curNum = cur is num ? cur : null;
      final isSame = curNum != null &&
          (spec.isInt
              ? curNum.toInt() == (parsed as int)
              : curNum.toDouble() == (parsed as num).toDouble());
      if (isSame) continue;
      final ok = await controller.updateConfig(key: spec.key, value: parsed);
      if (ok) {
        changed++;
      } else {
        failed++;
      }
    }
    if (!mounted) return;
    final err = ref.read(adminControllerProvider).error;
    final msg = failed > 0
        ? 'Sebagian gagal disimpan: ${err ?? 'kesalahan'}'
        : changed == 0
            ? 'Tidak ada perubahan.'
            : '$changed konfigurasi disimpan.';
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: failed > 0 ? AppColors.error : AppColors.success,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final configAsync = ref.watch(adminConfigProvider);
    final isWorking = ref.watch(adminControllerProvider).isLoading;

    return AdminScaffold(
      current: AdminSection.config,
      title: 'Konfigurasi Platform',
      body: configAsync.when(
        skipLoadingOnReload: true,
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _ErrorView(
          message: '$e',
          onRetry: () => ref.invalidate(adminConfigProvider),
        ),
        data: (config) {
          _seed(config);
          final knownKeys = _configSpecs.map((e) => e.key).toSet();
          final extraKeys =
              config.keys.where((k) => !knownKeys.contains(k)).toList();
          return RefreshIndicator(
            onRefresh: () async {
              _seeded = false;
              ref.invalidate(adminConfigProvider);
              await ref.read(adminConfigProvider.future);
              if (mounted) setState(() {});
            },
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              children: [
                const Text('Parameter Ekonomi',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                const Text(
                  'Berlaku untuk transaksi & booking baru setelah disimpan.',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 16),
                for (final spec in _configSpecs) ...[
                  _ConfigCard(
                    spec: spec,
                    controller: _controllers[spec.key]!,
                  ),
                  const SizedBox(height: 12),
                ],
                if (extraKeys.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  const Divider(),
                  const SizedBox(height: 8),
                  const Text('Konfigurasi lain (baca saja)',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  for (final k in extraKeys)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(k,
                                style: const TextStyle(
                                    color: AppColors.textSecondary)),
                          ),
                          Text('${config[k]}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                ],
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: isWorking ? null : () => _saveAll(config),
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Simpan Perubahan'),
                ),
                if (isWorking) ...[
                  const SizedBox(height: 16),
                  const Center(child: CircularProgressIndicator()),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ConfigCard extends StatefulWidget {
  final _ConfigSpec spec;
  final TextEditingController controller;
  const _ConfigCard({required this.spec, required this.controller});

  @override
  State<_ConfigCard> createState() => _ConfigCardState();
}

class _ConfigCardState extends State<_ConfigCard> {
  @override
  Widget build(BuildContext context) {
    final spec = widget.spec;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(spec.label,
              style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(spec.helper,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 12)),
          const SizedBox(height: 10),
          TextField(
            controller: widget.controller,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            onChanged: spec.isPercent ? (_) => setState(() {}) : null,
            decoration: InputDecoration(
              isDense: true,
              border: const OutlineInputBorder(),
              suffixText: spec.isInt ? 'jam' : null,
              helperText: spec.isPercent ? _percentPreview() : null,
            ),
          ),
        ],
      ),
    );
  }

  String? _percentPreview() {
    final v = num.tryParse(widget.controller.text.trim());
    if (v == null) return null;
    final pct = v * 100;
    return '= ${pct.toStringAsFixed(pct % 1 == 0 ? 0 : 2)}%';
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(32),
      children: [
        const SizedBox(height: 40),
        const Icon(Icons.error_outline, size: 48, color: AppColors.error),
        const SizedBox(height: 12),
        Text(message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textSecondary)),
        const SizedBox(height: 16),
        Center(
          child: FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Coba lagi'),
          ),
        ),
      ],
    );
  }
}