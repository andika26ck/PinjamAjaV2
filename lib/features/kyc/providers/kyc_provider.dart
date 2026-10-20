import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/app_exception.dart';
import '../../auth/providers/auth_provider.dart';
import '../data/kyc_repository.dart';
import '../data/supabase_kyc_repository.dart';

final kycRepositoryProvider = Provider<KycRepository>(
  (ref) => SupabaseKycRepository(ref.watch(supabaseClientProvider)),
);

final kycControllerProvider =
    AsyncNotifierProvider<KycController, void>(KycController.new);

/// Controller aksi KYC. State `AsyncValue<void>` untuk loading & error.
class KycController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  String _uid() {
    final id = ref.read(supabaseClientProvider).auth.currentUser?.id;
    if (id == null) {
      throw const AppException('Sesi tidak ditemukan. Silakan masuk ulang.');
    }
    return id;
  }

  /// Kompres + unggah KTP & selfie, lalu simpan pengajuan (status -> pending).
  Future<bool> submit({
    required String fullName,
    required String idNumber,
    required Uint8List idPhotoBytes,
    required String idPhotoExt,
    required Uint8List selfieBytes,
    required String selfieExt,
  }) async {
    state = const AsyncLoading();
    try {
      final uid = _uid();
      final repo = ref.read(kycRepositoryProvider);

      final idPhoto = await _compress(idPhotoBytes, idPhotoExt);
      final selfie = await _compress(selfieBytes, selfieExt);

      final idUrl = await repo.uploadDocument(
        userId: uid,
        slot: 'ktp',
        file: KycUpload(bytes: idPhoto, fileExtension: idPhotoExt),
      );
      final selfieUrl = await repo.uploadDocument(
        userId: uid,
        slot: 'selfie',
        file: KycUpload(bytes: selfie, fileExtension: selfieExt),
      );

      await repo.submitKyc(
        userId: uid,
        fullName: fullName,
        idNumber: idNumber,
        idPhotoUrl: idUrl,
        selfieUrl: selfieUrl,
      );

      // Segarkan profil global -> status KYC di UI ikut ter-update.
      await ref.read(appAuthProvider.notifier).refreshProfile();
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