import 'package:flutter/material.dart';
import 'package:assetsphere/features/organization/domain/entities/department.dart';
import 'package:assetsphere/features/organization/domain/entities/record_status.dart';
import 'package:assetsphere/features/organization/presentation/providers/organization_controller.dart';

class DepartmentFormDialog extends StatefulWidget {
  final OrganizationController controller;
  final Department? department; // If null, it's a create operation

  const DepartmentFormDialog({
    super.key,
    required this.controller,
    this.department,
  });

  @override
  State<DepartmentFormDialog> createState() => _DepartmentFormDialogState();
}

class _DepartmentFormDialogState extends State<DepartmentFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _codeController;
  String? _selectedParentId;
  String? _selectedHeadId;
  late RecordStatus _status;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.department?.name ?? '',
    );
    _codeController = TextEditingController(
      text: widget.department?.code ?? '',
    );
    _selectedParentId = widget.department?.parentDepartmentId;
    _selectedHeadId = widget.department?.departmentHeadId;
    _status = widget.department?.status ?? RecordStatus.active;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text;
    final code = _codeController.text;

    bool success;
    if (widget.department == null) {
      success = await widget.controller.createDepartment(
        name: name,
        code: code,
        parentDepartmentId: _selectedParentId,
        departmentHeadId: _selectedHeadId,
        status: _status,
      );
    } else {
      success = await widget.controller.updateDepartment(
        id: widget.department!.id,
        name: name,
        code: code,
        parentDepartmentId: _selectedParentId,
        departmentHeadId: _selectedHeadId,
        status: _status,
      );
    }

    if (success && mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final availableParents = widget.controller.departments
        .where((d) => d.id != widget.department?.id)
        .toList();
    final availableHeads = widget.controller.employees
        .where((e) => e.status == RecordStatus.active)
        .toList();

    return AlertDialog(
      title: Text(
        widget.department == null ? 'Add Department' : 'Edit Department',
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.controller.errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(8),
                  margin: const EdgeInsets.only(bottom: 16),
                  color: Colors.red.withValues(alpha: 0.1),
                  child: Text(
                    widget.controller.errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Name is required'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _codeController,
                decoration: const InputDecoration(
                  labelText: 'Code',
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.characters,
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Code is required'
                    : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String?>(
                initialValue:
                    availableParents.any((d) => d.id == _selectedParentId)
                    ? _selectedParentId
                    : null,
                decoration: const InputDecoration(
                  labelText: 'Parent Department',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('None'),
                  ),
                  ...availableParents.map(
                    (d) => DropdownMenuItem(value: d.id, child: Text(d.name)),
                  ),
                ],
                onChanged: (val) => setState(() => _selectedParentId = val),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String?>(
                initialValue: availableHeads.any((e) => e.id == _selectedHeadId)
                    ? _selectedHeadId
                    : null,
                decoration: const InputDecoration(
                  labelText: 'Department Head',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('None'),
                  ),
                  ...availableHeads.map(
                    (e) =>
                        DropdownMenuItem(value: e.id, child: Text(e.fullName)),
                  ),
                ],
                onChanged: (val) => setState(() => _selectedHeadId = val),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Active'),
                value: _status == RecordStatus.active,
                onChanged: (val) {
                  setState(
                    () => _status = val
                        ? RecordStatus.active
                        : RecordStatus.inactive,
                  );
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            widget.controller.clearMessages();
            Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: widget.controller.isLoading ? null : _submit,
          child: widget.controller.isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save'),
        ),
      ],
    );
  }
}
