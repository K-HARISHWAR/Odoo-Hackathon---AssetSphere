import 'dart:math';
import 'package:assetsphere/features/organization/data/models/department_model.dart';
import 'package:assetsphere/features/organization/data/models/asset_category_model.dart';
import 'package:assetsphere/features/organization/data/models/employee_model.dart';
import 'package:assetsphere/features/organization/domain/entities/employee_role.dart';
import 'package:assetsphere/features/organization/domain/entities/record_status.dart';

class MockOrganizationDataSource {
  final List<Map<String, dynamic>> _departments = [
    {
      'id': 'd1',
      'name': 'Information Technology',
      'code': 'IT',
      'parentDepartmentId': null,
      'departmentHeadId': 'e1',
      'status': RecordStatus.active,
      'createdAt': DateTime.now().subtract(const Duration(days: 365)),
      'updatedAt': DateTime.now(),
    },
    {
      'id': 'd2',
      'name': 'Human Resources',
      'code': 'HR',
      'parentDepartmentId': null,
      'departmentHeadId': 'e3',
      'status': RecordStatus.active,
      'createdAt': DateTime.now().subtract(const Duration(days: 365)),
      'updatedAt': DateTime.now(),
    },
    {
      'id': 'd3',
      'name': 'Finance',
      'code': 'FIN',
      'parentDepartmentId': null,
      'departmentHeadId': null,
      'status': RecordStatus.active,
      'createdAt': DateTime.now().subtract(const Duration(days: 365)),
      'updatedAt': DateTime.now(),
    },
    {
      'id': 'd4',
      'name': 'Operations',
      'code': 'OPS',
      'parentDepartmentId': null,
      'departmentHeadId': null,
      'status': RecordStatus.active,
      'createdAt': DateTime.now().subtract(const Duration(days: 365)),
      'updatedAt': DateTime.now(),
    },
    {
      'id': 'd5',
      'name': 'Administration',
      'code': 'ADMIN',
      'parentDepartmentId': null,
      'departmentHeadId': 'e4',
      'status': RecordStatus.active,
      'createdAt': DateTime.now().subtract(const Duration(days: 365)),
      'updatedAt': DateTime.now(),
    },
    {
      'id': 'd6',
      'name': 'Legacy Support',
      'code': 'LSUP',
      'parentDepartmentId': 'd1',
      'departmentHeadId': null,
      'status': RecordStatus.inactive,
      'createdAt': DateTime.now().subtract(const Duration(days: 730)),
      'updatedAt': DateTime.now().subtract(const Duration(days: 10)),
    },
  ];

  final List<Map<String, dynamic>> _categories = [
    {
      'id': 'c1',
      'name': 'Electronics',
      'description': 'Laptops, Monitors, Peripherals',
      'warrantyPeriodMonths': 24,
      'customFieldDescription': 'Serial Number required',
      'status': RecordStatus.active,
      'createdAt': DateTime.now(),
      'updatedAt': DateTime.now(),
    },
    {
      'id': 'c2',
      'name': 'Furniture',
      'description': 'Desks, Chairs, Cabinets',
      'warrantyPeriodMonths': 12,
      'customFieldDescription': null,
      'status': RecordStatus.active,
      'createdAt': DateTime.now(),
      'updatedAt': DateTime.now(),
    },
    {
      'id': 'c3',
      'name': 'Vehicles',
      'description': 'Company Cars and Vans',
      'warrantyPeriodMonths': 36,
      'customFieldDescription': 'License Plate required',
      'status': RecordStatus.active,
      'createdAt': DateTime.now(),
      'updatedAt': DateTime.now(),
    },
    {
      'id': 'c4',
      'name': 'Medical Equipment',
      'description': 'Specialized medical tools',
      'warrantyPeriodMonths': 24,
      'customFieldDescription': 'Calibration Date required',
      'status': RecordStatus.active,
      'createdAt': DateTime.now(),
      'updatedAt': DateTime.now(),
    },
    {
      'id': 'c5',
      'name': 'Office Supplies',
      'description': 'Stationery and consumables',
      'warrantyPeriodMonths': null,
      'customFieldDescription': null,
      'status': RecordStatus.active,
      'createdAt': DateTime.now(),
      'updatedAt': DateTime.now(),
    },
  ];

  final List<Map<String, dynamic>> _employees = [
    {
      'id': 'e1',
      'employeeCode': 'EMP001',
      'fullName': 'Ananya Rao',
      'email': 'ananya.rao@assetsphere.com',
      'departmentId': 'd1',
      'role': EmployeeRole.departmentHead,
      'status': RecordStatus.active,
      'createdAt': DateTime.now(),
      'updatedAt': DateTime.now(),
    },
    {
      'id': 'e2',
      'employeeCode': 'EMP002',
      'fullName': 'Karthik Raman',
      'email': 'karthik.raman@assetsphere.com',
      'departmentId': 'd1',
      'role': EmployeeRole.assetManager,
      'status': RecordStatus.active,
      'createdAt': DateTime.now(),
      'updatedAt': DateTime.now(),
    },
    {
      'id': 'e3',
      'employeeCode': 'EMP003',
      'fullName': 'Priya Sharma',
      'email': 'priya.sharma@assetsphere.com',
      'departmentId': 'd2',
      'role': EmployeeRole.employee,
      'status': RecordStatus.active,
      'createdAt': DateTime.now(),
      'updatedAt': DateTime.now(),
    },
    {
      'id': 'e4',
      'employeeCode': 'EMP004',
      'fullName': 'Raj Kumar',
      'email': 'raj.kumar@assetsphere.com',
      'departmentId': 'd5',
      'role': EmployeeRole.admin,
      'status': RecordStatus.active,
      'createdAt': DateTime.now(),
      'updatedAt': DateTime.now(),
    },
    {
      'id': 'e5',
      'employeeCode': 'EMP005',
      'fullName': 'Meera Nair',
      'email': 'meera.nair@assetsphere.com',
      'departmentId': 'd3',
      'role': EmployeeRole.employee,
      'status': RecordStatus.active,
      'createdAt': DateTime.now(),
      'updatedAt': DateTime.now(),
    },
    {
      'id': 'e6',
      'employeeCode': 'EMP006',
      'fullName': 'Arjun Patel',
      'email': 'arjun.patel@assetsphere.com',
      'departmentId': 'd4',
      'role': EmployeeRole.employee,
      'status': RecordStatus.inactive,
      'createdAt': DateTime.now(),
      'updatedAt': DateTime.now(),
    },
    {
      'id': 'e7',
      'employeeCode': 'EMP007',
      'fullName': 'Kavya Iyer',
      'email': 'kavya.iyer@assetsphere.com',
      'departmentId': 'd2',
      'role': EmployeeRole.employee,
      'status': RecordStatus.active,
      'createdAt': DateTime.now(),
      'updatedAt': DateTime.now(),
    },
    {
      'id': 'e8',
      'employeeCode': 'EMP008',
      'fullName': 'Rahul Verma',
      'email': 'rahul.verma@assetsphere.com',
      'departmentId': 'd1',
      'role': EmployeeRole.employee,
      'status': RecordStatus.active,
      'createdAt': DateTime.now(),
      'updatedAt': DateTime.now(),
    },
  ];

  Future<void> _simulateDelay() async {
    final delay = 300 + Random().nextInt(300);
    await Future.delayed(Duration(milliseconds: delay));
  }

  String _getDeptName(String? deptId) {
    if (deptId == null) return '';
    final d = _departments.cast<Map<String, dynamic>?>().firstWhere(
      (d) => d?['id'] == deptId,
      orElse: () => null,
    );
    return d?['name'] as String? ?? '';
  }

  String _getEmpName(String? empId) {
    if (empId == null) return '';
    final e = _employees.cast<Map<String, dynamic>?>().firstWhere(
      (e) => e?['id'] == empId,
      orElse: () => null,
    );
    return e?['fullName'] as String? ?? '';
  }

  // DEPARTMENTS
  Future<List<DepartmentModel>> getDepartments() async {
    await _simulateDelay();
    return _departments.map((d) {
      return DepartmentModel(
        id: d['id'],
        name: d['name'],
        code: d['code'],
        parentDepartmentId: d['parentDepartmentId'],
        parentDepartmentName: _getDeptName(d['parentDepartmentId']),
        departmentHeadId: d['departmentHeadId'],
        departmentHeadName: _getEmpName(d['departmentHeadId']),
        status: d['status'],
        createdAt: d['createdAt'],
        updatedAt: d['updatedAt'],
      );
    }).toList();
  }

  Future<DepartmentModel> createDepartment({
    required String name,
    required String code,
    String? parentDepartmentId,
    String? departmentHeadId,
    required RecordStatus status,
  }) async {
    await _simulateDelay();

    final upperCode = code.toUpperCase().trim();
    if (_departments.any((d) => d['code'] == upperCode)) {
      throw Exception('A department with code $upperCode already exists.');
    }

    final newDept = {
      'id': 'd${DateTime.now().millisecondsSinceEpoch}',
      'name': name.trim(),
      'code': upperCode,
      'parentDepartmentId': parentDepartmentId,
      'departmentHeadId': departmentHeadId,
      'status': status,
      'createdAt': DateTime.now(),
      'updatedAt': DateTime.now(),
    };

    _departments.add(newDept);

    return DepartmentModel(
      id: newDept['id'] as String,
      name: newDept['name'] as String,
      code: newDept['code'] as String,
      parentDepartmentId: newDept['parentDepartmentId'] as String?,
      parentDepartmentName: _getDeptName(
        newDept['parentDepartmentId'] as String?,
      ),
      departmentHeadId: newDept['departmentHeadId'] as String?,
      departmentHeadName: _getEmpName(newDept['departmentHeadId'] as String?),
      status: newDept['status'] as RecordStatus,
      createdAt: newDept['createdAt'] as DateTime,
      updatedAt: newDept['updatedAt'] as DateTime,
    );
  }

  Future<DepartmentModel> updateDepartment({
    required String id,
    required String name,
    required String code,
    String? parentDepartmentId,
    String? departmentHeadId,
    required RecordStatus status,
  }) async {
    await _simulateDelay();

    if (id == parentDepartmentId) {
      throw Exception('A department cannot be its own parent.');
    }

    final upperCode = code.toUpperCase().trim();
    if (_departments.any((d) => d['code'] == upperCode && d['id'] != id)) {
      throw Exception('A department with code $upperCode already exists.');
    }

    final index = _departments.indexWhere((d) => d['id'] == id);
    if (index == -1) throw Exception('Department not found.');

    final existing = _departments[index];
    existing['name'] = name.trim();
    existing['code'] = upperCode;
    existing['parentDepartmentId'] = parentDepartmentId;
    existing['departmentHeadId'] = departmentHeadId;
    existing['status'] = status;
    existing['updatedAt'] = DateTime.now();

    return DepartmentModel(
      id: existing['id'],
      name: existing['name'],
      code: existing['code'],
      parentDepartmentId: existing['parentDepartmentId'],
      parentDepartmentName: _getDeptName(existing['parentDepartmentId']),
      departmentHeadId: existing['departmentHeadId'],
      departmentHeadName: _getEmpName(existing['departmentHeadId']),
      status: existing['status'],
      createdAt: existing['createdAt'],
      updatedAt: existing['updatedAt'],
    );
  }

  Future<DepartmentModel> updateDepartmentStatus({
    required String id,
    required RecordStatus status,
  }) async {
    await _simulateDelay();
    final index = _departments.indexWhere((d) => d['id'] == id);
    if (index == -1) throw Exception('Department not found.');

    _departments[index]['status'] = status;
    _departments[index]['updatedAt'] = DateTime.now();

    final d = _departments[index];
    return DepartmentModel(
      id: d['id'],
      name: d['name'],
      code: d['code'],
      parentDepartmentId: d['parentDepartmentId'],
      parentDepartmentName: _getDeptName(d['parentDepartmentId']),
      departmentHeadId: d['departmentHeadId'],
      departmentHeadName: _getEmpName(d['departmentHeadId']),
      status: d['status'],
      createdAt: d['createdAt'],
      updatedAt: d['updatedAt'],
    );
  }

  // CATEGORIES
  Future<List<AssetCategoryModel>> getAssetCategories() async {
    await _simulateDelay();
    return _categories
        .map(
          (c) => AssetCategoryModel(
            id: c['id'],
            name: c['name'],
            description: c['description'],
            warrantyPeriodMonths: c['warrantyPeriodMonths'],
            customFieldDescription: c['customFieldDescription'],
            status: c['status'],
            createdAt: c['createdAt'],
            updatedAt: c['updatedAt'],
          ),
        )
        .toList();
  }

  Future<AssetCategoryModel> createAssetCategory({
    required String name,
    required String description,
    int? warrantyPeriodMonths,
    String? customFieldDescription,
    required RecordStatus status,
  }) async {
    await _simulateDelay();

    if (warrantyPeriodMonths != null && warrantyPeriodMonths < 0) {
      throw Exception('Warranty period cannot be negative.');
    }

    final trimmedName = name.trim();
    if (_categories.any(
      (c) => c['name'].toString().toLowerCase() == trimmedName.toLowerCase(),
    )) {
      throw Exception('A category with this name already exists.');
    }

    final newCat = {
      'id': 'c${DateTime.now().millisecondsSinceEpoch}',
      'name': trimmedName,
      'description': description.trim(),
      'warrantyPeriodMonths': warrantyPeriodMonths,
      'customFieldDescription': customFieldDescription?.trim(),
      'status': status,
      'createdAt': DateTime.now(),
      'updatedAt': DateTime.now(),
    };

    _categories.add(newCat);
    return AssetCategoryModel(
      id: newCat['id'] as String,
      name: newCat['name'] as String,
      description: newCat['description'] as String,
      warrantyPeriodMonths: newCat['warrantyPeriodMonths'] as int?,
      customFieldDescription: newCat['customFieldDescription'] as String?,
      status: newCat['status'] as RecordStatus,
      createdAt: newCat['createdAt'] as DateTime,
      updatedAt: newCat['updatedAt'] as DateTime,
    );
  }

  Future<AssetCategoryModel> updateAssetCategory({
    required String id,
    required String name,
    required String description,
    int? warrantyPeriodMonths,
    String? customFieldDescription,
    required RecordStatus status,
  }) async {
    await _simulateDelay();

    if (warrantyPeriodMonths != null && warrantyPeriodMonths < 0) {
      throw Exception('Warranty period cannot be negative.');
    }

    final trimmedName = name.trim();
    if (_categories.any(
      (c) =>
          c['name'].toString().toLowerCase() == trimmedName.toLowerCase() &&
          c['id'] != id,
    )) {
      throw Exception('A category with this name already exists.');
    }

    final index = _categories.indexWhere((c) => c['id'] == id);
    if (index == -1) throw Exception('Category not found.');

    final existing = _categories[index];
    existing['name'] = trimmedName;
    existing['description'] = description.trim();
    existing['warrantyPeriodMonths'] = warrantyPeriodMonths;
    existing['customFieldDescription'] = customFieldDescription?.trim();
    existing['status'] = status;
    existing['updatedAt'] = DateTime.now();

    return AssetCategoryModel(
      id: existing['id'],
      name: existing['name'],
      description: existing['description'],
      warrantyPeriodMonths: existing['warrantyPeriodMonths'],
      customFieldDescription: existing['customFieldDescription'],
      status: existing['status'],
      createdAt: existing['createdAt'],
      updatedAt: existing['updatedAt'],
    );
  }

  Future<AssetCategoryModel> updateAssetCategoryStatus({
    required String id,
    required RecordStatus status,
  }) async {
    await _simulateDelay();
    final index = _categories.indexWhere((c) => c['id'] == id);
    if (index == -1) throw Exception('Category not found.');

    _categories[index]['status'] = status;
    _categories[index]['updatedAt'] = DateTime.now();

    final c = _categories[index];
    return AssetCategoryModel(
      id: c['id'],
      name: c['name'],
      description: c['description'],
      warrantyPeriodMonths: c['warrantyPeriodMonths'],
      customFieldDescription: c['customFieldDescription'],
      status: c['status'],
      createdAt: c['createdAt'],
      updatedAt: c['updatedAt'],
    );
  }

  // EMPLOYEES
  Future<List<EmployeeModel>> getEmployees() async {
    await _simulateDelay();
    return _employees
        .map(
          (e) => EmployeeModel(
            id: e['id'],
            employeeCode: e['employeeCode'],
            fullName: e['fullName'],
            email: e['email'],
            departmentId: e['departmentId'],
            departmentName: _getDeptName(e['departmentId']),
            role: e['role'],
            status: e['status'],
            createdAt: e['createdAt'],
            updatedAt: e['updatedAt'],
          ),
        )
        .toList();
  }

  Future<EmployeeModel> updateEmployeeRole({
    required String id,
    required EmployeeRole newRole,
  }) async {
    await _simulateDelay();
    final index = _employees.indexWhere((e) => e['id'] == id);
    if (index == -1) throw Exception('Employee not found.');

    // Admin safety check
    final currentRole = _employees[index]['role'];
    final currentStatus = _employees[index]['status'];

    if (currentRole == EmployeeRole.admin &&
        currentStatus == RecordStatus.active &&
        newRole != EmployeeRole.admin) {
      final activeAdmins = _employees
          .where(
            (e) =>
                e['role'] == EmployeeRole.admin &&
                e['status'] == RecordStatus.active,
          )
          .length;

      if (activeAdmins <= 1) {
        throw Exception('At least one active Admin account must remain.');
      }
    }

    _employees[index]['role'] = newRole;
    _employees[index]['updatedAt'] = DateTime.now();

    final e = _employees[index];
    return EmployeeModel(
      id: e['id'],
      employeeCode: e['employeeCode'],
      fullName: e['fullName'],
      email: e['email'],
      departmentId: e['departmentId'],
      departmentName: _getDeptName(e['departmentId']),
      role: e['role'],
      status: e['status'],
      createdAt: e['createdAt'],
      updatedAt: e['updatedAt'],
    );
  }

  Future<EmployeeModel> updateEmployeeDepartment({
    required String id,
    required String newDepartmentId,
  }) async {
    await _simulateDelay();

    final dept = _departments.cast<Map<String, dynamic>?>().firstWhere(
      (d) => d?['id'] == newDepartmentId,
      orElse: () => null,
    );
    if (dept == null || dept['status'] != RecordStatus.active) {
      throw Exception('Selected department is invalid or inactive.');
    }

    final index = _employees.indexWhere((e) => e['id'] == id);
    if (index == -1) throw Exception('Employee not found.');

    _employees[index]['departmentId'] = newDepartmentId;
    _employees[index]['updatedAt'] = DateTime.now();

    final e = _employees[index];
    return EmployeeModel(
      id: e['id'],
      employeeCode: e['employeeCode'],
      fullName: e['fullName'],
      email: e['email'],
      departmentId: e['departmentId'],
      departmentName: _getDeptName(e['departmentId']),
      role: e['role'],
      status: e['status'],
      createdAt: e['createdAt'],
      updatedAt: e['updatedAt'],
    );
  }

  Future<EmployeeModel> updateEmployeeStatus({
    required String id,
    required RecordStatus status,
  }) async {
    await _simulateDelay();
    final index = _employees.indexWhere((e) => e['id'] == id);
    if (index == -1) throw Exception('Employee not found.');

    // Admin safety check
    final currentRole = _employees[index]['role'];
    final currentStatus = _employees[index]['status'];

    if (currentRole == EmployeeRole.admin &&
        currentStatus == RecordStatus.active &&
        status == RecordStatus.inactive) {
      final activeAdmins = _employees
          .where(
            (e) =>
                e['role'] == EmployeeRole.admin &&
                e['status'] == RecordStatus.active,
          )
          .length;

      if (activeAdmins <= 1) {
        throw Exception('At least one active Admin account must remain.');
      }
    }

    _employees[index]['status'] = status;
    _employees[index]['updatedAt'] = DateTime.now();

    final e = _employees[index];
    return EmployeeModel(
      id: e['id'],
      employeeCode: e['employeeCode'],
      fullName: e['fullName'],
      email: e['email'],
      departmentId: e['departmentId'],
      departmentName: _getDeptName(e['departmentId']),
      role: e['role'],
      status: e['status'],
      createdAt: e['createdAt'],
      updatedAt: e['updatedAt'],
    );
  }
}
