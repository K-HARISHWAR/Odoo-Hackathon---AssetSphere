import 'package:flutter/material.dart';
import 'package:assetsphere/features/organization/domain/entities/record_status.dart';
import 'package:assetsphere/features/organization/presentation/providers/organization_controller.dart';
import 'package:assetsphere/features/organization/presentation/widgets/department_form_dialog.dart';
import 'package:assetsphere/features/organization/presentation/widgets/organization_filter_bar.dart';
import 'package:assetsphere/features/organization/presentation/widgets/status_badge.dart';

class DepartmentManagementTab extends StatelessWidget {
  final OrganizationController controller;

  const DepartmentManagementTab({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        if (controller.isLoading && controller.departments.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: OrganizationFilterBar(
                      searchHint: 'Search departments...',
                      onSearchChanged: (val) =>
                          controller.applyDepartmentFilters(query: val),
                      filterDropdown: DropdownButton<RecordStatus?>(
                        hint: const Text('Status'),
                        value:
                            null, // Since we don't expose individual filters cleanly, we'll just bind onChange
                        items: const [
                          DropdownMenuItem(value: null, child: Text('All')),
                          DropdownMenuItem(
                            value: RecordStatus.active,
                            child: Text('Active'),
                          ),
                          DropdownMenuItem(
                            value: RecordStatus.inactive,
                            child: Text('Inactive'),
                          ),
                        ],
                        onChanged: (val) =>
                            controller.applyDepartmentFilters(status: val),
                      ),
                      onClearFilters: controller.clearDepartmentFilters,
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) =>
                            DepartmentFormDialog(controller: controller),
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add Department'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: controller.filteredDepartments.isEmpty
                  ? const Center(child: Text('No departments found.'))
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SingleChildScrollView(
                        child: DataTable(
                          columns: const [
                            DataColumn(label: Text('Code')),
                            DataColumn(label: Text('Name')),
                            DataColumn(label: Text('Parent Department')),
                            DataColumn(label: Text('Head')),
                            DataColumn(label: Text('Status')),
                            DataColumn(label: Text('Actions')),
                          ],
                          rows: controller.filteredDepartments.map((dept) {
                            return DataRow(
                              cells: [
                                DataCell(Text(dept.code)),
                                DataCell(Text(dept.name)),
                                DataCell(
                                  Text(dept.parentDepartmentName ?? '-'),
                                ),
                                DataCell(Text(dept.departmentHeadName ?? '-')),
                                DataCell(StatusBadge(status: dept.status)),
                                DataCell(
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit, size: 20),
                                        tooltip: 'Edit',
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (ctx) =>
                                                DepartmentFormDialog(
                                                  controller: controller,
                                                  department: dept,
                                                ),
                                          );
                                        },
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          dept.status == RecordStatus.active
                                              ? Icons.block
                                              : Icons.check_circle,
                                          size: 20,
                                          color:
                                              dept.status == RecordStatus.active
                                              ? Colors.red
                                              : Colors.green,
                                        ),
                                        tooltip:
                                            dept.status == RecordStatus.active
                                            ? 'Deactivate'
                                            : 'Activate',
                                        onPressed: () async {
                                          final confirm = await showDialog<bool>(
                                            context: context,
                                            builder: (ctx) => AlertDialog(
                                              title: Text(
                                                '${dept.status == RecordStatus.active ? 'Deactivate' : 'Activate'} Department?',
                                              ),
                                              content: Text(
                                                'Are you sure you want to change the status of ${dept.name}?',
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(ctx, false),
                                                  child: const Text('Cancel'),
                                                ),
                                                ElevatedButton(
                                                  onPressed: () =>
                                                      Navigator.pop(ctx, true),
                                                  child: const Text('Confirm'),
                                                ),
                                              ],
                                            ),
                                          );
                                          if (confirm == true) {
                                            controller.toggleDepartmentStatus(
                                              dept.id,
                                            );
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }
}
