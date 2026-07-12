import 'package:flutter/material.dart';
import 'package:assetsphere/features/organization/domain/entities/employee.dart';
import 'package:assetsphere/features/organization/domain/entities/employee_role.dart';
import 'package:assetsphere/features/organization/presentation/providers/organization_controller.dart';

class EmployeeRoleDialog extends StatefulWidget {
  final Employee employee;
  final OrganizationController controller;

  const EmployeeRoleDialog({
    super.key,
    required this.employee,
    required this.controller,
  });

  @override
  State<EmployeeRoleDialog> createState() => _EmployeeRoleDialogState();
}

class _EmployeeRoleDialogState extends State<EmployeeRoleDialog> {
  late EmployeeRole _selectedRole;

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.employee.role;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Change Employee Role'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Employee: ${widget.employee.fullName}'),
            const SizedBox(height: 8),
            Text('Current role: ${widget.employee.role.name}'),
            const SizedBox(height: 16),
            const Text(
              'Elevated roles grant additional permissions. Please confirm before assigning.',
              style: TextStyle(color: Colors.orange, fontSize: 12),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<EmployeeRole>(
              initialValue: _selectedRole,
              decoration: const InputDecoration(
                labelText: 'New Role',
                border: OutlineInputBorder(),
              ),
              items: EmployeeRole.values.map((role) {
                return DropdownMenuItem(value: role, child: Text(role.name));
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedRole = val);
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
          onPressed: () async {
            if (_selectedRole == widget.employee.role) {
              Navigator.pop(context); // no change
              return;
            }
            final success = await widget.controller.updateEmployeeRole(
              id: widget.employee.id,
              newRole: _selectedRole,
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
