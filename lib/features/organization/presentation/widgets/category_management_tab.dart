import 'package:flutter/material.dart';
import 'package:assetsphere/features/organization/domain/entities/record_status.dart';
import 'package:assetsphere/features/organization/presentation/providers/organization_controller.dart';
import 'package:assetsphere/features/organization/presentation/widgets/category_form_dialog.dart';
import 'package:assetsphere/features/organization/presentation/widgets/organization_filter_bar.dart';
import 'package:assetsphere/features/organization/presentation/widgets/status_badge.dart';

class CategoryManagementTab extends StatelessWidget {
  final OrganizationController controller;

  const CategoryManagementTab({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        if (controller.isLoading && controller.assetCategories.isEmpty) {
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
                      searchHint: 'Search categories...',
                      onSearchChanged: (val) =>
                          controller.applyCategoryFilters(query: val),
                      filterDropdown: DropdownButton<RecordStatus?>(
                        hint: const Text('Status'),
                        value: null,
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
                            controller.applyCategoryFilters(status: val),
                      ),
                      onClearFilters: controller.clearCategoryFilters,
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) =>
                            CategoryFormDialog(controller: controller),
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add Category'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: controller.filteredAssetCategories.isEmpty
                  ? const Center(child: Text('No asset categories found.'))
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SingleChildScrollView(
                        child: DataTable(
                          columns: const [
                            DataColumn(label: Text('Name')),
                            DataColumn(label: Text('Description')),
                            DataColumn(label: Text('Warranty (Months)')),
                            DataColumn(label: Text('Status')),
                            DataColumn(label: Text('Actions')),
                          ],
                          rows: controller.filteredAssetCategories.map((cat) {
                            return DataRow(
                              cells: [
                                DataCell(Text(cat.name)),
                                DataCell(Text(cat.description)),
                                DataCell(
                                  Text(
                                    cat.warrantyPeriodMonths?.toString() ?? '-',
                                  ),
                                ),
                                DataCell(StatusBadge(status: cat.status)),
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
                                                CategoryFormDialog(
                                                  controller: controller,
                                                  category: cat,
                                                ),
                                          );
                                        },
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          cat.status == RecordStatus.active
                                              ? Icons.block
                                              : Icons.check_circle,
                                          size: 20,
                                          color:
                                              cat.status == RecordStatus.active
                                              ? Colors.red
                                              : Colors.green,
                                        ),
                                        tooltip:
                                            cat.status == RecordStatus.active
                                            ? 'Deactivate'
                                            : 'Activate',
                                        onPressed: () async {
                                          final confirm = await showDialog<bool>(
                                            context: context,
                                            builder: (ctx) => AlertDialog(
                                              title: Text(
                                                '${cat.status == RecordStatus.active ? 'Deactivate' : 'Activate'} Category?',
                                              ),
                                              content: Text(
                                                'Are you sure you want to change the status of ${cat.name}?',
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
                                            controller.toggleCategoryStatus(
                                              cat.id,
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
