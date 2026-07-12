import 'package:flutter/material.dart';
import 'package:assetsphere/app/session/app_session_controller.dart';
import 'package:assetsphere/features/authentication/presentation/providers/auth_controller.dart';
import 'package:assetsphere/app/router/app_routes.dart';
import 'package:assetsphere/app/permissions/app_permissions.dart';

class MainAppShell extends StatefulWidget {
  final AppSessionController sessionController;
  final AuthController authController;
  final Widget child;

  const MainAppShell({
    super.key,
    required this.sessionController,
    required this.authController,
    required this.child,
  });

  @override
  State<MainAppShell> createState() => _MainAppShellState();
}

class _MainAppShellState extends State<MainAppShell> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > 900;
        
        return Scaffold(
          appBar: isDesktop ? null : _buildMobileAppBar(context),
          drawer: isDesktop ? null : _buildDrawer(context),
          body: Row(
            children: [
              if (isDesktop) _buildSideNav(context),
              Expanded(child: widget.child),
            ],
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildMobileAppBar(BuildContext context) {
    return AppBar(
      title: const Text('AssetSphere', style: TextStyle(fontWeight: FontWeight.bold)),
      elevation: 0,
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: _buildNavigationItems(context, isDrawer: true),
    );
  }

  Widget _buildSideNav(BuildContext context) {
    return Container(
      width: 250,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          right: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant.withAlpha(50),
          ),
        ),
      ),
      child: _buildNavigationItems(context, isDrawer: false),
    );
  }

  Widget _buildNavigationItems(BuildContext context, {required bool isDrawer}) {
    final user = widget.sessionController.currentUser;
    final role = user?.role;
    
    return ListenableBuilder(
      listenable: widget.sessionController,
      builder: (context, _) {
        final currentSection = widget.sessionController.currentSection;
        
        return Column(
          children: [
            if (isDrawer)
              UserAccountsDrawerHeader(
                accountName: Text(user?.fullName ?? 'User'),
                accountEmail: Text(user?.email ?? ''),
                currentAccountPicture: const CircleAvatar(
                  child: Icon(Icons.person),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.blur_on, 
                      color: Theme.of(context).colorScheme.primary,
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'AssetSphere',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _NavItem(
                    icon: Icons.dashboard_rounded,
                    label: 'Dashboard',
                    isSelected: currentSection == 'dashboard',
                    onTap: () {
                      if (isDrawer) Navigator.pop(context);
                      Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
                    },
                  ),
                  
                  if (role != null && AppPermissions.canAccessAssets(role))
                    _NavItem(
                      icon: Icons.inventory_2_rounded,
                      label: 'Asset Directory',
                      isSelected: currentSection == 'assets',
                      onTap: () {
                        if (isDrawer) Navigator.pop(context);
                        Navigator.pushReplacementNamed(context, AppRoutes.assets);
                      },
                    ),
                    
                  if (role != null && AppPermissions.canAccessOrganizationSetup(role))
                    _NavItem(
                      icon: Icons.business_rounded,
                      label: 'Organization Setup',
                      isSelected: currentSection == 'organization',
                      onTap: () {
                        if (isDrawer) Navigator.pop(context);
                        Navigator.pushReplacementNamed(context, AppRoutes.organization);
                      },
                    ),
                ],
              ),
            ),
            
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout', style: TextStyle(color: Colors.red)),
              onTap: () async {
                if (isDrawer) Navigator.pop(context);
                await widget.authController.logout();
                widget.sessionController.logout();
                if (context.mounted) {
                  Navigator.pushNamedAndRemoveUntil(
                    context, 
                    AppRoutes.login, 
                    (route) => false,
                  );
                }
              },
            ),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        selected: isSelected,
        selectedTileColor: theme.colorScheme.primaryContainer.withAlpha(100),
        leading: Icon(
          icon,
          color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
        ),
        title: Text(
          label,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
