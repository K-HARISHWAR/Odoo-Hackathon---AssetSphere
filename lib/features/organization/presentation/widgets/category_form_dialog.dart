import 'package:flutter/material.dart';
import 'package:assetsphere/features/organization/domain/entities/asset_category.dart';
import 'package:assetsphere/features/organization/domain/entities/record_status.dart';
import 'package:assetsphere/features/organization/presentation/providers/organization_controller.dart';

class CategoryFormDialog extends StatefulWidget {
  final OrganizationController controller;
  final AssetCategory? category;

  const CategoryFormDialog({
    super.key,
    required this.controller,
    this.category,
  });

  @override
  State<CategoryFormDialog> createState() => _CategoryFormDialogState();
}

class _CategoryFormDialogState extends State<CategoryFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _warrantyController;
  late TextEditingController _customFieldController;
  late RecordStatus _status;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name ?? '');
    _descController = TextEditingController(
      text: widget.category?.description ?? '',
    );
    _warrantyController = TextEditingController(
      text: widget.category?.warrantyPeriodMonths != null
          ? widget.category!.warrantyPeriodMonths.toString()
          : '',
    );
    _customFieldController = TextEditingController(
      text: widget.category?.customFieldDescription ?? '',
    );
    _status = widget.category?.status ?? RecordStatus.active;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _warrantyController.dispose();
    _customFieldController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text;
    final desc = _descController.text;
    final warranty = int.tryParse(_warrantyController.text);
    final customField = _customFieldController.text.isNotEmpty
        ? _customFieldController.text
        : null;

    bool success;
    if (widget.category == null) {
      success = await widget.controller.createCategory(
        name: name,
        description: desc,
        warrantyPeriodMonths: warranty,
        customFieldDescription: customField,
        status: _status,
      );
    } else {
      success = await widget.controller.updateCategory(
        id: widget.category!.id,
        name: name,
        description: desc,
        warrantyPeriodMonths: warranty,
        customFieldDescription: customField,
        status: _status,
      );
    }

    if (success && mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.category == null ? 'Add Category' : 'Edit Category'),
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
                controller: _descController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _warrantyController,
                decoration: const InputDecoration(
                  labelText: 'Warranty (Months)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return null;
                  final num = int.tryParse(value);
                  if (num == null) return 'Must be a valid number';
                  if (num < 0) return 'Cannot be negative';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _customFieldController,
                decoration: const InputDecoration(
                  labelText: 'Custom Field Description (Optional)',
                  border: OutlineInputBorder(),
                ),
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
