import 'package:flutter/material.dart';
import 'package:assetsphere/features/organization/domain/entities/employee_role.dart';
import 'package:assetsphere/features/organization/domain/entities/record_status.dart';
import 'package:assetsphere/features/organization/presentation/providers/organization_controller.dart';
import 'package:assetsphere/features/organization/presentation/widgets/employee_department_dialog.dart';
import 'package:assetsphere/features/organization/presentation/widgets/employee_role_dialog.dart';
import 'package:assetsphere/features/organization/presentation/widgets/organization_filter_bar.dart';
import 'package:assetsphere/features/organization/presentation/widgets/status_badge.dart';

class EmployeeDirectoryTab extends StatelessWidget {
  final OrganizationController controller;

  const EmployeeDirectoryTab({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        if (controller.isLoading && controller.employees.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: OrganizationFilterBar(
                      searchHint: 'Search employees...',
                      onSearchChanged: (val) =>
                          controller.applyEmployeeFilters(query: val),
                      filterDropdown: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(width: 16),
                          DropdownButton<EmployeeRole?>(
                            hint: const Text('Role'),
                            value: null,
                            items: [
                              const DropdownMenuItem(
                                value: null,
                                child: Text('All Roles'),
                              ),
                              ...EmployeeRole.values.map(
                                (r) => DropdownMenuItem(
                                  value: r,
                                  child: Text(r.displayName),
                                ),
                              ),
                            ],
                            onChanged: (val) =>
                                controller.applyEmployeeFilters(role: val),
                          ),
                          const SizedBox(width: 16),
                          DropdownButton<RecordStatus?>(
                            hint: const Text('Status'),
                            value: null,
                            items: const [
                              DropdownMenuItem(
                                value: null,
                                child: Text('All Status'),
                              ),
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
                                controller.applyEmployeeFilters(status: val),
                          ),
                        ],
                      ),
                      onClearFilters: controller.clearEmployeeFilters,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: controller.filteredEmployees.isEmpty
                  ? const Center(child: Text('No employees found.'))
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        if (constraints.maxWidth < 600) {
                          // Mobile layout
                          return ListView.builder(
                            itemCount: controller.filteredEmployees.length,
                            itemBuilder: (context, index) {
                              final emp = controller.filteredEmployees[index];
                              return Card(
                                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                child: ListTile(
                                  title: Text(emp.fullName),
                                  subtitle: Text('${emp.role.displayName} • ${emp.departmentName}'),
                                  trailing: StatusBadge(status: emp.status),
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (ctx) => EmployeeRoleDialog(
                                        controller: controller,
                                        employee: emp,
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          );
                        }

                        // Desktop layout
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: SingleChildScrollView(
                              child: DataTable(
                                headingRowColor: WidgetStateProperty.all(
                                  Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                                ),
                                columns: const [
                                  DataColumn(label: Text('Code')),
                                  DataColumn(label: Text('Name')),
                                  DataColumn(label: Text('Email')),
                                  DataColumn(label: Text('Department')),
                                  DataColumn(label: Text('Role')),
                                  DataColumn(label: Text('Status')),
                                  DataColumn(label: Text('Actions')),
                                ],
                                rows: controller.filteredEmployees.map((emp) {
                                  final isInactive = emp.status == RecordStatus.inactive;
                                  return DataRow(
                                    color: isInactive
                                        ? WidgetStateProperty.all(
                                            Colors.grey.withValues(alpha: 0.05),
                                          )
                                        : null,
                                    cells: [
                                      DataCell(
                                        Text(
                                          emp.employeeCode,
                                          style: TextStyle(
                                            color: isInactive ? Colors.grey : null,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          emp.fullName,
                                          style: TextStyle(
                                            color: isInactive ? Colors.grey : null,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          emp.email,
                                          style: TextStyle(
                                            color: isInactive ? Colors.grey : null,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          emp.departmentName,
                                          style: TextStyle(
                                            color: isInactive ? Colors.grey : null,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          emp.role.displayName,
                                          style: TextStyle(
                                            color: isInactive ? Colors.grey : null,
                                          ),
                                        ),
                                      ),
                                      DataCell(StatusBadge(status: emp.status)),
                                      DataCell(
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.business, size: 20),
                                              tooltip: 'Change Department',
                                              onPressed: () {
                                                showDialog(
                                                  context: context,
                                                  builder: (ctx) => EmployeeDepartmentDialog(
                                                    controller: controller,
                                                    employee: emp,
                                                  ),
                                                );
                                              },
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.admin_panel_settings, size: 20),
                                              tooltip: 'Change Role',
                                              onPressed: () {
                                                showDialog(
                                                  context: context,
                                                  builder: (ctx) => EmployeeRoleDialog(
                                                    controller: controller,
                                                    employee: emp,
                                                  ),
                                                );
                                              },
                                            ),
                                            IconButton(
                                              icon: Icon(
                                                emp.status == RecordStatus.active
                                                    ? Icons.block
                                                    : Icons.check_circle,
                                                size: 20,
                                                color: emp.status == RecordStatus.active
                                                    ? Colors.red
                                                    : Colors.green,
                                              ),
                                              tooltip: emp.status == RecordStatus.active
                                                  ? 'Deactivate'
                                                  : 'Activate',
                                              onPressed: () async {
                                                final confirm = await showDialog<bool>(
                                                  context: context,
                                                  builder: (ctx) => AlertDialog(
                                                    title: Text(
                                                      '${emp.status == RecordStatus.active ? 'Deactivate' : 'Activate'} Employee?',
                                                    ),
                                                    content: Text(
                                                      'Are you sure you want to change the status of ${emp.fullName}?',
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () => Navigator.pop(ctx, false),
                                                        child: const Text('Cancel'),
                                                      ),
                                                      ElevatedButton(
                                                        onPressed: () => Navigator.pop(ctx, true),
                                                        child: const Text('Confirm'),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                                if (confirm == true) {
                                                  controller.updateEmployeeStatus(
                                                    id: emp.id,
                                                    status: emp.status == RecordStatus.active
                                                        ? RecordStatus.inactive
                                                        : RecordStatus.active,
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
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}
