import 'package:flutter/foundation.dart';
import 'package:assetsphere/features/organization/domain/entities/department.dart';
import 'package:assetsphere/features/organization/domain/entities/asset_category.dart';
import 'package:assetsphere/features/organization/domain/entities/employee.dart';
import 'package:assetsphere/features/organization/domain/entities/employee_role.dart';
import 'package:assetsphere/features/organization/domain/entities/record_status.dart';
import 'package:assetsphere/features/organization/domain/use_cases/get_departments.dart';
import 'package:assetsphere/features/organization/domain/use_cases/save_department.dart';
import 'package:assetsphere/features/organization/domain/use_cases/get_asset_categories.dart';
import 'package:assetsphere/features/organization/domain/use_cases/save_asset_category.dart';
import 'package:assetsphere/features/organization/domain/use_cases/get_employees.dart';
import 'package:assetsphere/features/organization/domain/use_cases/update_employee_role.dart';
import 'package:assetsphere/features/organization/domain/use_cases/update_employee_department.dart';
import 'package:assetsphere/features/organization/domain/use_cases/update_employee_status.dart';

class RoleChangeActivity {
  final String employeeId;
  final String employeeName;
  final EmployeeRole oldRole;
  final EmployeeRole newRole;
  final DateTime changedAt;
  final String description;

  RoleChangeActivity({
    required this.employeeId,
    required this.employeeName,
    required this.oldRole,
    required this.newRole,
    required this.changedAt,
    required this.description,
  });
}

class OrganizationController extends ChangeNotifier {
  final GetDepartments _getDepartments;
  final SaveDepartment _saveDepartment;
  final GetAssetCategories _getAssetCategories;
  final SaveAssetCategory _saveAssetCategory;
  final GetEmployees _getEmployees;
  final UpdateEmployeeRole _updateEmployeeRole;
  final UpdateEmployeeDepartment _updateEmployeeDepartment;
  final UpdateEmployeeStatus _updateEmployeeStatus;

  OrganizationController({
    required GetDepartments getDepartments,
    required SaveDepartment saveDepartment,
    required GetAssetCategories getAssetCategories,
    required SaveAssetCategory saveAssetCategory,
    required GetEmployees getEmployees,
    required UpdateEmployeeRole updateEmployeeRole,
    required UpdateEmployeeDepartment updateEmployeeDepartment,
    required UpdateEmployeeStatus updateEmployeeStatus,
  }) : _getDepartments = getDepartments,
       _saveDepartment = saveDepartment,
       _getAssetCategories = getAssetCategories,
       _saveAssetCategory = saveAssetCategory,
       _getEmployees = getEmployees,
       _updateEmployeeRole = updateEmployeeRole,
       _updateEmployeeDepartment = updateEmployeeDepartment,
       _updateEmployeeStatus = updateEmployeeStatus;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _successMessage;
  String? get successMessage => _successMessage;

  int _selectedTabIndex = 0;
  int get selectedTabIndex => _selectedTabIndex;

  // Data
  List<Department> _departments = [];
  List<Department> get departments => List.unmodifiable(_departments);
  List<Department> _filteredDepartments = [];
  List<Department> get filteredDepartments =>
      List.unmodifiable(_filteredDepartments);

  List<AssetCategory> _assetCategories = [];
  List<AssetCategory> get assetCategories =>
      List.unmodifiable(_assetCategories);
  List<AssetCategory> _filteredAssetCategories = [];
  List<AssetCategory> get filteredAssetCategories =>
      List.unmodifiable(_filteredAssetCategories);

  List<Employee> _employees = [];
  List<Employee> get employees => List.unmodifiable(_employees);
  List<Employee> _filteredEmployees = [];
  List<Employee> get filteredEmployees => List.unmodifiable(_filteredEmployees);

  final List<RoleChangeActivity> _roleChangeActivity = [];
  List<RoleChangeActivity> get roleChangeActivity =>
      List.unmodifiable(_roleChangeActivity);

  // Filters state
  String _departmentSearchQuery = '';
  RecordStatus? _departmentStatusFilter;

  String _categorySearchQuery = '';
  RecordStatus? _categoryStatusFilter;

  String _employeeSearchQuery = '';
  String? _employeeDepartmentFilter;
  EmployeeRole? _employeeRoleFilter;
  RecordStatus? _employeeStatusFilter;

  void setTabIndex(int index) {
    _selectedTabIndex = index;
    notifyListeners();
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  String _parseError(Object error) {
    return error.toString().replaceAll('Exception: ', '');
  }

  Future<void> initialize() async {
    _setLoading(true);
    clearMessages();
    try {
      await Future.wait([
        _loadDepartmentsInternal(),
        _loadCategoriesInternal(),
        _loadEmployeesInternal(),
      ]);
      _applyDepartmentFiltersInternal();
      _applyCategoryFiltersInternal();
      _applyEmployeeFiltersInternal();
    } catch (e) {
      _errorMessage = _parseError(e);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _loadDepartmentsInternal() async {
    _departments = await _getDepartments();
  }

  Future<void> _loadCategoriesInternal() async {
    _assetCategories = await _getAssetCategories();
  }

  Future<void> _loadEmployeesInternal() async {
    _employees = await _getEmployees();
  }

  Future<void> loadDepartments() async {
    _setLoading(true);
    clearMessages();
    try {
      await _loadDepartmentsInternal();
      _applyDepartmentFiltersInternal();
    } catch (e) {
      _errorMessage = _parseError(e);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadCategories() async {
    _setLoading(true);
    clearMessages();
    try {
      await _loadCategoriesInternal();
      _applyCategoryFiltersInternal();
    } catch (e) {
      _errorMessage = _parseError(e);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadEmployees() async {
    _setLoading(true);
    clearMessages();
    try {
      await _loadEmployeesInternal();
      _applyEmployeeFiltersInternal();
    } catch (e) {
      _errorMessage = _parseError(e);
    } finally {
      _setLoading(false);
    }
  }

  // --- Department Mutations ---
  Future<bool> createDepartment({
    required String name,
    required String code,
    String? parentDepartmentId,
    String? departmentHeadId,
    required RecordStatus status,
  }) async {
    _setLoading(true);
    clearMessages();
    try {
      await _saveDepartment(
        name: name,
        code: code,
        parentDepartmentId: parentDepartmentId,
        departmentHeadId: departmentHeadId,
        status: status,
      );
      _successMessage = 'Department created successfully.';
      await _loadDepartmentsInternal();
      _applyDepartmentFiltersInternal();
      return true;
    } catch (e) {
      _errorMessage = _parseError(e);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateDepartment({
    required String id,
    required String name,
    required String code,
    String? parentDepartmentId,
    String? departmentHeadId,
    required RecordStatus status,
  }) async {
    _setLoading(true);
    clearMessages();
    try {
      await _saveDepartment(
        id: id,
        name: name,
        code: code,
        parentDepartmentId: parentDepartmentId,
        departmentHeadId: departmentHeadId,
        status: status,
      );
      _successMessage = 'Department updated successfully.';
      await _loadDepartmentsInternal();
      _applyDepartmentFiltersInternal();
      return true;
    } catch (e) {
      _errorMessage = _parseError(e);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> toggleDepartmentStatus(String id) async {
    final dept = _departments.firstWhere((d) => d.id == id);
    final newStatus = dept.status == RecordStatus.active
        ? RecordStatus.inactive
        : RecordStatus.active;
    return updateDepartment(
      id: id,
      name: dept.name,
      code: dept.code,
      parentDepartmentId: dept.parentDepartmentId,
      departmentHeadId: dept.departmentHeadId,
      status: newStatus,
    );
  }

  // --- Category Mutations ---
  Future<bool> createCategory({
    required String name,
    required String description,
    int? warrantyPeriodMonths,
    String? customFieldDescription,
    required RecordStatus status,
  }) async {
    _setLoading(true);
    clearMessages();
    try {
      await _saveAssetCategory(
        name: name,
        description: description,
        warrantyPeriodMonths: warrantyPeriodMonths,
        customFieldDescription: customFieldDescription,
        status: status,
      );
      _successMessage = 'Asset category created successfully.';
      await _loadCategoriesInternal();
      _applyCategoryFiltersInternal();
      return true;
    } catch (e) {
      _errorMessage = _parseError(e);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateCategory({
    required String id,
    required String name,
    required String description,
    int? warrantyPeriodMonths,
    String? customFieldDescription,
    required RecordStatus status,
  }) async {
    _setLoading(true);
    clearMessages();
    try {
      await _saveAssetCategory(
        id: id,
        name: name,
        description: description,
        warrantyPeriodMonths: warrantyPeriodMonths,
        customFieldDescription: customFieldDescription,
        status: status,
      );
      _successMessage = 'Asset category updated successfully.';
      await _loadCategoriesInternal();
      _applyCategoryFiltersInternal();
      return true;
    } catch (e) {
      _errorMessage = _parseError(e);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> toggleCategoryStatus(String id) async {
    final cat = _assetCategories.firstWhere((c) => c.id == id);
    final newStatus = cat.status == RecordStatus.active
        ? RecordStatus.inactive
        : RecordStatus.active;
    return updateCategory(
      id: id,
      name: cat.name,
      description: cat.description,
      warrantyPeriodMonths: cat.warrantyPeriodMonths,
      customFieldDescription: cat.customFieldDescription,
      status: newStatus,
    );
  }

  // --- Employee Mutations ---
  Future<bool> updateEmployeeRole({
    required String id,
    required EmployeeRole newRole,
  }) async {
    _setLoading(true);
    clearMessages();
    try {
      final oldEmp = _employees.firstWhere((e) => e.id == id);
      if (oldEmp.role == newRole) {
        _setLoading(false);
        return true;
      }

      final updatedEmp = await _updateEmployeeRole(id: id, newRole: newRole);

      _roleChangeActivity.add(
        RoleChangeActivity(
          employeeId: id,
          employeeName: updatedEmp.fullName,
          oldRole: oldEmp.role,
          newRole: newRole,
          changedAt: DateTime.now(),
          description:
              'Role changed from ${oldEmp.role.displayName} to ${newRole.displayName}',
        ),
      );

      _successMessage = 'Employee role updated successfully.';
      await _loadEmployeesInternal();
      _applyEmployeeFiltersInternal();
      return true;
    } catch (e) {
      _errorMessage = _parseError(e);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateEmployeeDepartment({
    required String id,
    required String newDepartmentId,
  }) async {
    _setLoading(true);
    clearMessages();
    try {
      await _updateEmployeeDepartment(id: id, newDepartmentId: newDepartmentId);
      _successMessage = 'Employee department updated successfully.';
      await _loadEmployeesInternal();
      _applyEmployeeFiltersInternal();
      return true;
    } catch (e) {
      _errorMessage = _parseError(e);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateEmployeeStatus({
    required String id,
    required RecordStatus status,
  }) async {
    _setLoading(true);
    clearMessages();
    try {
      await _updateEmployeeStatus(id: id, status: status);
      _successMessage = 'Employee status updated successfully.';
      await _loadEmployeesInternal();
      _applyEmployeeFiltersInternal();
      return true;
    } catch (e) {
      _errorMessage = _parseError(e);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // --- Filters ---
  void applyDepartmentFilters({String? query, RecordStatus? status}) {
    if (query != null) _departmentSearchQuery = query;
    if (status != null) _departmentStatusFilter = status;
    _applyDepartmentFiltersInternal();
    notifyListeners();
  }

  void clearDepartmentFilters() {
    _departmentSearchQuery = '';
    _departmentStatusFilter = null;
    _applyDepartmentFiltersInternal();
    notifyListeners();
  }

  void _applyDepartmentFiltersInternal() {
    _filteredDepartments = _departments.where((d) {
      final matchesSearch =
          _departmentSearchQuery.isEmpty ||
          d.name.toLowerCase().contains(_departmentSearchQuery.toLowerCase()) ||
          d.code.toLowerCase().contains(_departmentSearchQuery.toLowerCase());
      final matchesStatus =
          _departmentStatusFilter == null ||
          d.status == _departmentStatusFilter;
      return matchesSearch && matchesStatus;
    }).toList();
  }

  void applyCategoryFilters({String? query, RecordStatus? status}) {
    if (query != null) _categorySearchQuery = query;
    if (status != null) _categoryStatusFilter = status;
    _applyCategoryFiltersInternal();
    notifyListeners();
  }

  void clearCategoryFilters() {
    _categorySearchQuery = '';
    _categoryStatusFilter = null;
    _applyCategoryFiltersInternal();
    notifyListeners();
  }

  void _applyCategoryFiltersInternal() {
    _filteredAssetCategories = _assetCategories.where((c) {
      final matchesSearch =
          _categorySearchQuery.isEmpty ||
          c.name.toLowerCase().contains(_categorySearchQuery.toLowerCase());
      final matchesStatus =
          _categoryStatusFilter == null || c.status == _categoryStatusFilter;
      return matchesSearch && matchesStatus;
    }).toList();
  }

  void applyEmployeeFilters({
    String? query,
    String? departmentId,
    EmployeeRole? role,
    RecordStatus? status,
  }) {
    if (query != null) _employeeSearchQuery = query;
    if (departmentId != null) _employeeDepartmentFilter = departmentId;
    if (role != null) _employeeRoleFilter = role;
    if (status != null) _employeeStatusFilter = status;
    _applyEmployeeFiltersInternal();
    notifyListeners();
  }

  void clearEmployeeFilters() {
    _employeeSearchQuery = '';
    _employeeDepartmentFilter = null;
    _employeeRoleFilter = null;
    _employeeStatusFilter = null;
    _applyEmployeeFiltersInternal();
    notifyListeners();
  }

  void _applyEmployeeFiltersInternal() {
    _filteredEmployees = _employees.where((e) {
      final matchesSearch =
          _employeeSearchQuery.isEmpty ||
          e.fullName.toLowerCase().contains(
            _employeeSearchQuery.toLowerCase(),
          ) ||
          e.employeeCode.toLowerCase().contains(
            _employeeSearchQuery.toLowerCase(),
          ) ||
          e.email.toLowerCase().contains(_employeeSearchQuery.toLowerCase());
      final matchesDept =
          _employeeDepartmentFilter == null ||
          e.departmentId == _employeeDepartmentFilter;
      final matchesRole =
          _employeeRoleFilter == null || e.role == _employeeRoleFilter;
      final matchesStatus =
          _employeeStatusFilter == null || e.status == _employeeStatusFilter;
      return matchesSearch && matchesDept && matchesRole && matchesStatus;
    }).toList();
  }
}
