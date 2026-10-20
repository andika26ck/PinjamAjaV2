import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../auth/providers/auth_provider.dart';
import '../data/admin_repository.dart';
import '../data/supabase_admin_repository.dart';

part 'admin_repository_provider.g.dart';

@Riverpod(keepAlive: true)
AdminRepository adminRepository(AdminRepositoryRef ref) =>
    SupabaseAdminRepository(ref.watch(supabaseClientProvider));