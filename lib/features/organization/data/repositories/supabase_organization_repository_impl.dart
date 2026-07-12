import 'package:assetsphere/core/utils/database_enum_mappers.dart';
import 'package:assetsphere/core/utils/supabase_error_mapper.dart';
import 'package:assetsphere/features/organization/domain/entities/asset_category.dart';
import 'package:assetsphere/features/organization/domain/entities/department.dart';
import 'package:assetsphere/features/organization/domain/entities/employee.dart';
import 'package:assetsphere/features/organization/domain/entities/employee_role.dart';
import 'package:assetsphere/features/organization/domain/entities/record_status.dart';
import 'package:assetsphere/features/organization/domain/repositories/organization_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseOrganizationRepositoryImpl implements OrganizationRepository {
  final SupabaseClient _supabase;

  SupabaseOrganizationRepositoryImpl({required SupabaseClient supabaseClient})
    : _supabase = supabaseClient;

  String _requireUser() {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw Exception('Authentication missing');
    }
    return user.id;
  }

  // --- Departments ---

  @override
  Future<List<Department>> getDepartments() async {
    _requireUser();
    try {
      final response = await _supabase
          .from('departments')
          .select('''
            id,
            name,
            code,
            parent_department_id,
            department_head_id,
            status,
            created_at,
            updated_at
          ''')
          .order('name');

      return (response as List).map((row) => _mapDepartment(row)).toList();
    } catch (e) {
      throw Exception(SupabaseErrorMapper.mapError(e));
    }
  }

  @override
  Future<Department> createDepartment({
    required String name,
    required String code,
    String? parentDepartmentId,
    String? departmentHeadId,
    required RecordStatus status,
  }) async {
    _requireUser();
    try {
      // Organization ID is derived via RLS or we must pass it?
      // departments table has organization_id. Since we don't have an RPC for creating departments,
      // we must get the current organization_id first.
      final orgId = await _getCurrentOrgId();

      final response = await _supabase
          .from('departments')
          .insert({
            'organization_id': orgId,
            'name': name,
            'code': code,
            'parent_department_id': parentDepartmentId,
            'department_head_id': departmentHeadId,
            'status': DatabaseEnumMappers.recordStatusToDatabase(status),
          })
          .select()
          .single();

      return _mapDepartment(response);
    } catch (e) {
      throw Exception(SupabaseErrorMapper.mapError(e));
    }
  }

  @override
  Future<Department> updateDepartment({
    required String id,
    required String name,
    required String code,
    String? parentDepartmentId,
    String? departmentHeadId,
    required RecordStatus status,
  }) async {
    _requireUser();
    try {
      final response = await _supabase
          .from('departments')
          .update({
            'name': name,
            'code': code,
            'parent_department_id': parentDepartmentId,
            'department_head_id': departmentHeadId,
            'status': DatabaseEnumMappers.recordStatusToDatabase(status),
          })
          .eq('id', id)
          .select()
          .single();

      return _mapDepartment(response);
    } catch (e) {
      throw Exception(SupabaseErrorMapper.mapError(e));
    }
  }

  @override
  Future<Department> updateDepartmentStatus({
    required String id,
    required RecordStatus status,
  }) async {
    _requireUser();
    try {
      final response = await _supabase
          .from('departments')
          .update({
            'status': DatabaseEnumMappers.recordStatusToDatabase(status),
          })
          .eq('id', id)
          .select()
          .single();

      return _mapDepartment(response);
    } catch (e) {
      throw Exception(SupabaseErrorMapper.mapError(e));
    }
  }

  // --- Asset Categories ---

  @override
  Future<List<AssetCategory>> getAssetCategories() async {
    _requireUser();
    try {
      final response = await _supabase
          .from('asset_categories')
          .select('''
            id,
            name,
            description,
            warranty_period_months,
            custom_field_description,
            status,
            created_at,
            updated_at
          ''')
          .order('name');

      return (response as List).map((row) => _mapAssetCategory(row)).toList();
    } catch (e) {
      throw Exception(SupabaseErrorMapper.mapError(e));
    }
  }

  @override
  Future<AssetCategory> createAssetCategory({
    required String name,
    required String description,
    int? warrantyPeriodMonths,
    String? customFieldDescription,
    required RecordStatus status,
  }) async {
    _requireUser();
    try {
      final orgId = await _getCurrentOrgId();
      final response = await _supabase
          .from('asset_categories')
          .insert({
            'organization_id': orgId,
            'name': name,
            'description': description,
            'warranty_period_months': warrantyPeriodMonths,
            'custom_field_description': customFieldDescription,
            'status': DatabaseEnumMappers.recordStatusToDatabase(status),
          })
          .select()
          .single();

      return _mapAssetCategory(response);
    } catch (e) {
      throw Exception(SupabaseErrorMapper.mapError(e));
    }
  }

  @override
  Future<AssetCategory> updateAssetCategory({
    required String id,
    required String name,
    required String description,
    int? warrantyPeriodMonths,
    String? customFieldDescription,
    required RecordStatus status,
  }) async {
    _requireUser();
    try {
      final response = await _supabase
          .from('asset_categories')
          .update({
            'name': name,
            'description': description,
            'warranty_period_months': warrantyPeriodMonths,
            'custom_field_description': customFieldDescription,
            'status': DatabaseEnumMappers.recordStatusToDatabase(status),
          })
          .eq('id', id)
          .select()
          .single();

      return _mapAssetCategory(response);
    } catch (e) {
      throw Exception(SupabaseErrorMapper.mapError(e));
    }
  }

  @override
  Future<AssetCategory> updateAssetCategoryStatus({
    required String id,
    required RecordStatus status,
  }) async {
    _requireUser();
    try {
      final response = await _supabase
          .from('asset_categories')
          .update({
            'status': DatabaseEnumMappers.recordStatusToDatabase(status),
          })
          .eq('id', id)
          .select()
          .single();

      return _mapAssetCategory(response);
    } catch (e) {
      throw Exception(SupabaseErrorMapper.mapError(e));
    }
  }

  // --- Employees ---

  @override
  Future<List<Employee>> getEmployees() async {
    _requireUser();
    try {
      // Need to join profiles with departments and user_roles to get all required data.
      final response = await _supabase
          .from('profiles')
          .select('''
            id,
            employee_code,
            full_name,
            email,
            status,
            created_at,
            updated_at,
            department_id,
            user_roles ( roles ( code ) )
          ''')
          .order('full_name');

      // Fetch departments for mapping
      final depts = await getDepartments();
      final deptMap = {for (var d in depts) d.id: d.name};

      return (response as List)
          .map((row) => _mapEmployee(row, deptMap))
          .toList();
    } catch (e) {
      throw Exception(SupabaseErrorMapper.mapError(e));
    }
  }

  @override
  Future<Employee> updateEmployeeRole({
    required String id,
    required EmployeeRole newRole,
  }) async {
    _requireUser();
    try {
      final roleCode = DatabaseEnumMappers.employeeRoleToDatabase(newRole);

      // We use the secure RPC to change role
      await _supabase.rpc(
        'assign_user_role',
        params: {'p_user_id': id, 'p_role_code': roleCode},
      );

      // Refetch the employee
      return await _getEmployeeById(id);
    } catch (e) {
      throw Exception(SupabaseErrorMapper.mapError(e));
    }
  }

  @override
  Future<Employee> updateEmployeeDepartment({
    required String id,
    required String newDepartmentId,
  }) async {
    _requireUser();
    try {
      await _supabase
          .from('profiles')
          .update({'department_id': newDepartmentId})
          .eq('id', id);

      return await _getEmployeeById(id);
    } catch (e) {
      throw Exception(SupabaseErrorMapper.mapError(e));
    }
  }

  @override
  Future<Employee> updateEmployeeStatus({
    required String id,
    required RecordStatus status,
  }) async {
    _requireUser();
    try {
      await _supabase
          .from('profiles')
          .update({
            'status': DatabaseEnumMappers.recordStatusToDatabase(status),
          })
          .eq('id', id);

      return await _getEmployeeById(id);
    } catch (e) {
      throw Exception(SupabaseErrorMapper.mapError(e));
    }
  }

  // --- Helpers ---

  Future<String> _getCurrentOrgId() async {
    final uid = _requireUser();
    final profile = await _supabase
        .from('profiles')
        .select('organization_id')
        .eq('id', uid)
        .single();
    return profile['organization_id'] as String;
  }

  Future<Employee> _getEmployeeById(String id) async {
    final response = await _supabase
        .from('profiles')
        .select('''
            id,
            employee_code,
            full_name,
            email,
            status,
            created_at,
            updated_at,
            department_id,
            user_roles ( roles ( code ) )
          ''')
        .eq('id', id)
        .single();

    final depts = await getDepartments();
    final deptMap = {for (var d in depts) d.id: d.name};

    return _mapEmployee(response, deptMap);
  }

  Department _mapDepartment(Map<String, dynamic> row) {
    return Department(
      id: row['id'],
      name: row['name'],
      code: row['code'],
      parentDepartmentId: row['parent_department_id'],
      departmentHeadId: row['department_head_id'],
      status: DatabaseEnumMappers.recordStatusFromDatabase(row['status']),
      createdAt: DateTime.parse(row['created_at']),
      updatedAt: DateTime.parse(row['updated_at']),
    );
  }

  AssetCategory _mapAssetCategory(Map<String, dynamic> row) {
    return AssetCategory(
      id: row['id'],
      name: row['name'],
      description: row['description'] ?? '',
      warrantyPeriodMonths: row['warranty_period_months'],
      customFieldDescription: row['custom_field_description'],
      status: DatabaseEnumMappers.recordStatusFromDatabase(row['status']),
      createdAt: DateTime.parse(row['created_at']),
      updatedAt: DateTime.parse(row['updated_at']),
    );
  }

  Employee _mapEmployee(Map<String, dynamic> row, Map<String, String> deptMap) {
    final departmentId = row['department_id'] as String? ?? '';
    final departmentName = deptMap[departmentId] ?? 'No Department';

    EmployeeRole role = EmployeeRole.employee;
    final urList = row['user_roles'] as List?;
    if (urList != null && urList.isNotEmpty) {
      final roleMap = urList.first['roles'];
      if (roleMap != null) {
        try {
          role = DatabaseEnumMappers.employeeRoleFromDatabase(roleMap['code']);
        } catch (_) {}
      }
    }

    return Employee(
      id: row['id'],
      employeeCode: row['employee_code'] ?? '',
      fullName: row['full_name'],
      email: row['email'],
      departmentId: departmentId,
      departmentName: departmentName,
      role: role,
      status: DatabaseEnumMappers.recordStatusFromDatabase(row['status']),
      createdAt: DateTime.parse(row['created_at']),
      updatedAt: DateTime.parse(row['updated_at']),
    );
  }
}
