import 'package:assetsphere/core/utils/database_enum_mappers.dart';
import 'package:assetsphere/core/utils/supabase_error_mapper.dart';
import 'package:assetsphere/features/authentication/domain/entities/authenticated_user.dart';
import 'package:assetsphere/features/authentication/domain/repositories/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseAuthRepositoryImpl implements AuthRepository {
  final SupabaseClient _supabase;

  SupabaseAuthRepositoryImpl({required SupabaseClient supabaseClient})
    : _supabase = supabaseClient;

  @override
  Future<AuthenticatedUser> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user == null) {
        throw Exception('Login succeeded but user is null.');
      }

      return await _loadUserProfile(user.id, user.email ?? email);
    } catch (e) {
      throw Exception(SupabaseErrorMapper.mapError(e));
    }
  }

  @override
  Future<AuthenticatedUser> signupEmployee({
    required String fullName,
    required String email,
    required String password,
    required String departmentName,
  }) async {
    try {
      // Get department ID if we can (but signup might happen before we are logged in so RLS might block this)
      // Actually, standard employee signup via UI usually assumes an open registration or admin invites.
      // Since it's a mock UI, let's just create the user.
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName},
      );

      final user = response.user;
      if (user == null) {
        throw Exception('Signup succeeded but user is null.');
      }

      // Wait a bit for the handle_new_user trigger to create the profile.
      await Future.delayed(const Duration(seconds: 1));

      return await _loadUserProfile(user.id, user.email ?? email);
    } catch (e) {
      throw Exception(SupabaseErrorMapper.mapError(e));
    }
  }

  @override
  Future<void> requestPasswordReset({required String email}) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
    } catch (e) {
      throw Exception(SupabaseErrorMapper.mapError(e));
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      throw Exception(SupabaseErrorMapper.mapError(e));
    }
  }

  @override
  Future<AuthenticatedUser?> restoreSession() async {
    try {
      final session = _supabase.auth.currentSession;
      if (session == null) {
        return null;
      }

      final user = session.user;
      return await _loadUserProfile(user.id, user.email ?? '');
    } catch (e) {
      // If restore fails, they need to log in again
      await logout();
      return null;
    }
  }

  Future<AuthenticatedUser> _loadUserProfile(
    String userId,
    String email,
  ) async {
    // Load profile (without ambiguous join to departments)
    final profileData = await _supabase
        .from('profiles')
        .select('''
          id,
          full_name,
          status,
          department_id
        ''')
        .eq('id', userId)
        .maybeSingle();

    if (profileData == null) {
      throw Exception('Your account profile could not be loaded.');
    }

    if (profileData['status'] != 'active') {
      throw Exception(
        'Account is inactive. Please contact your administrator.',
      );
    }

    final fullName = profileData['full_name'] as String? ?? 'Unknown User';

    String departmentName = 'No Department';
    if (profileData['department_id'] != null) {
      final deptId = profileData['department_id'] as String;
      final deptData = await _supabase
          .from('departments')
          .select('name')
          .eq('id', deptId)
          .maybeSingle();
      if (deptData != null && deptData['name'] != null) {
        departmentName = deptData['name'] as String;
      }
    }

    // Load role
    final roleData = await _supabase
        .from('user_roles')
        .select('roles ( code )')
        .eq('user_id', userId)
        .maybeSingle();

    AuthRole role = AuthRole.employee;
    if (roleData != null && roleData['roles'] != null) {
      final roleCode = roleData['roles']['code'] as String;
      try {
        role = DatabaseEnumMappers.authRoleFromDatabase(roleCode);
      } catch (_) {
        // Fallback to employee if unknown role
        role = AuthRole.employee;
      }
    }

    return AuthenticatedUser(
      id: userId,
      fullName: fullName,
      email: email,
      role: role,
      departmentName: departmentName,
      isActive: true,
    );
  }
}
