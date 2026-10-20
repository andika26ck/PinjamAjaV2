import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/manual_payout_provider.dart';

class PayoutAccountScreen extends ConsumerStatefulWidget {
  const PayoutAccountScreen({super.key});

  @override
  ConsumerState<PayoutAccountScreen> createState() =>
      _PayoutAccountScreenState();
}

class _PayoutAccountScreenState extends ConsumerState<PayoutAccountScreen> {
  final _bankC = TextEditingController();
  final _numberC = TextEditingController();
  final _nameC = TextEditingController();
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final acc =
          await ref.read(manualPayoutRepositoryProvider).getMyPayoutAccount();
      _bankC.text = acc.bankName ?? '';
      _numberC.text = acc.accountNumber ?? '';
      _nameC.text = acc.accountName ?? '';
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  @override
  void dispose() {
    _bankC.dispose();
    _numberC.dispose();
    _nameC.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_bankC.text.trim().isEmpty ||
        _numberC.text.trim().isEmpty ||
        _nameC.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lengkapi semua kolom dulu, ya.')));
      return;
    }
    setState(() => _saving = true);
    try {
      await ref.read(manualPayoutRepositoryProvider).updateMyPayoutAccount(
            bankName: _bankC.text.trim(),
            accountNumber: _numberC.text.trim(),
            accountName: _nameC.text.trim(),
          );
      ref.invalidate(myPayoutAccountProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Rekening pencairan tersimpan.')));
        Navigator.of(context).maybePop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Gagal menyimpan: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rekening Pencairan')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'Rekening ini dipakai admin untuk mentransfer hasil sewa '
                  'barangmu. Pastikan datanya benar.',
                  style: TextStyle(height: 1.5),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _bankC,
                  decoration: const InputDecoration(
                    labelText: 'Nama bank (mis. BCA, Mandiri)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _numberC,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Nomor rekening',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _nameC,
                  decoration: const InputDecoration(
                    labelText: 'Nama pemilik rekening',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
      bottomNavigationBar: _loading
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(52)),
                  child: _saving
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                              strokeWidth: 2.5, color: Colors.white))
                      : const Text('Simpan Rekening'),
                ),
              ),
            ),
    );
  }
}