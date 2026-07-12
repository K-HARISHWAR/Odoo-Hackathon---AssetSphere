import 'package:flutter/material.dart';
import 'package:assetsphere/features/organization/presentation/providers/organization_controller.dart';
import 'package:assetsphere/features/organization/presentation/widgets/category_management_tab.dart';
import 'package:assetsphere/features/organization/presentation/widgets/department_management_tab.dart';
import 'package:assetsphere/features/organization/presentation/widgets/employee_directory_tab.dart';

class OrganizationSetupPage extends StatefulWidget {
  final OrganizationController? controller;
  final VoidCallback? onBack;

  const OrganizationSetupPage({super.key, this.controller, this.onBack});

  @override
  State<OrganizationSetupPage> createState() => _OrganizationSetupPageState();
}

class _OrganizationSetupPageState extends State<OrganizationSetupPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    if (widget.controller != null) {
      _tabController.index = widget.controller!.selectedTabIndex;
      _tabController.addListener(() {
        widget.controller!.setTabIndex(_tabController.index);
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.controller!.initialize();
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.controller == null) {
      return const Scaffold(
        body: Center(child: Text('Organization Controller is not provided.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: widget.onBack != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: widget.onBack,
              )
            : null,
        title: const Text('Organization Setup'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Departments', icon: Icon(Icons.business)),
            Tab(text: 'Asset Categories', icon: Icon(Icons.category)),
            Tab(text: 'Employee Directory', icon: Icon(Icons.people)),
          ],
        ),
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: widget.controller!,
          builder: (context, _) {
            if (widget.controller!.errorMessage != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted && widget.controller!.errorMessage != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(widget.controller!.errorMessage!),
                      backgroundColor: Theme.of(context).colorScheme.error,
                    ),
                  );
                  widget.controller!.clearMessages();
                }
              });
            }

            if (widget.controller!.successMessage != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted && widget.controller!.successMessage != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(widget.controller!.successMessage!),
                      backgroundColor: Colors.green,
                    ),
                  );
                  widget.controller!.clearMessages();
                }
              });
            }

            return TabBarView(
              controller: _tabController,
              children: [
                DepartmentManagementTab(controller: widget.controller!),
                CategoryManagementTab(controller: widget.controller!),
                EmployeeDirectoryTab(controller: widget.controller!),
              ],
            );
          },
        ),
      ),
    );
  }
}
