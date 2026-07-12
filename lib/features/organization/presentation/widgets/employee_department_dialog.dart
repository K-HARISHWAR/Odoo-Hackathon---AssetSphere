import 'package:flutter/material.dart';
import 'package:assetsphere/features/organization/domain/entities/employee.dart';
import 'package:assetsphere/features/organization/domain/entities/record_status.dart';
import 'package:assetsphere/features/organization/presentation/providers/organization_controller.dart';

class EmployeeDepartmentDialog extends StatefulWidget {
  final Employee employee;
  final OrganizationController controller;

  const EmployeeDepartmentDialog({
    super.key,
    required this.employee,
    required this.controller,
  });

  @override
  State<EmployeeDepartmentDialog> createState() =>
      _EmployeeDepartmentDialogState();
}

class _EmployeeDepartmentDialogState extends State<EmployeeDepartmentDialog> {
  late String? _selectedDepartmentId;

  @override
  void initState() {
    super.initState();
    _selectedDepartmentId = widget.employee.departmentId;
  }

  @override
  Widget build(BuildContext context) {
    final activeDepartments = widget.controller.departments
        .where((d) => d.status == RecordStatus.active)
        .toList();

    return AlertDialog(
      title: const Text('Change Department'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Employee: ${widget.employee.fullName}'),
            const SizedBox(height: 8),
            Text('Current department: ${widget.employee.departmentName}'),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue:
                  activeDepartments.any((d) => d.id == _selectedDepartmentId)
                  ? _selectedDepartmentId
                  : null,
              decoration: const InputDecoration(
                labelText: 'New Department',
                border: OutlineInputBorder(),
              ),
              items: activeDepartments.map((dept) {
                return DropdownMenuItem(value: dept.id, child: Text(dept.name));
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedDepartmentId = val);
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _selectedDepartmentId == null
              ? null
              : () async {
                  if (_selectedDepartmentId == widget.employee.departmentId) {
                    Navigator.pop(context); // no change
                    return;
                  }
                  final success = await widget.controller
                      .updateEmployeeDepartment(
                        id: widget.employee.id,
                        newDepartmentId: _selectedDepartmentId!,
                      );
                  if (success && context.mounted) {
                    Navigator.pop(context);
                  }
                },
          child: const Text('Confirm'),
        ),
      ],
    );
  }
}
