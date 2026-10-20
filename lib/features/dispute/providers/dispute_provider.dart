import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/app_exception.dart';
import '../../auth/providers/auth_provider.dart';
import '../data/dispute_repository.dart';
import '../data/supabase_dispute_repository.dart';

final disputeRepositoryProvider = Provider<DisputeRepository>(
  (ref) => SupabaseDisputeRepository(ref.watch(supabaseClientProvider)),
);

final disputeControllerProvider =
    AsyncNotifierProvider<DisputeController, void>(DisputeController.new);

/// Controller aksi sengketa. State `AsyncValue<void>` untuk loading & error.
class DisputeController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  String _uid() {
    final id = ref.read(supabaseClientProvider).auth.currentUser?.id;
    if (id == null) {
      throw const AppException('Sesi tidak ditemukan. Silakan masuk ulang.');
    }
    return id;
  }

  /// Ajukan sengketa: unggah bukti lalu simpan baris `disputes`.
  Future<bool> submit({
    required String bookingId,
    String? againstId,
    required String reason,
    String? description,
    required List<EvidenceUpload> evidences,
  }) async {
    state = const AsyncLoading();
    try {
      final uid = _uid();
      final repo = ref.read(disputeRepositoryProvider);

      // Cegah sengketa ganda untuk booking yang sama.
      if (await repo.hasActiveDispute(bookingId)) {
        throw const AppException(
            'Sudah ada sengketa aktif untuk transaksi ini.');
      }

      // Kompres + unggah semua bukti secara berurutan.
      final urls = <String>[];
      for (var i = 0; i < evidences.length; i++) {
        final e = evidences[i];
        final compressed = await _compress(e.bytes, e.fileExtension);
        final url = await repo.uploadEvidence(
          userId: uid,
          bookingId: bookingId,
          file: EvidenceUpload(
              bytes: compressed, fileExtension: e.fileExtension),
          index: i,
        );
        urls.add(url);
      }

      await repo.submitDispute(
        bookingId: bookingId,
        openedBy: uid,
        againstId: againstId,
        reason: reason,
        description: description,
        evidenceUrls: urls,
      );

      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e.toAppException(), st);
      return false;
    }
  }

  Future<Uint8List> _compress(Uint8List bytes, String ext) async {
    final isPng = ext.toLowerCase() == 'png';
    final out = await FlutterImageCompress.compressWithList(
      bytes,
      quality: 75,
      minWidth: 1280,
      minHeight: 1280,
      format: isPng ? CompressFormat.png : CompressFormat.jpeg,
    );
    return out;
  }
}