import 'package:flutter/material.dart';
import 'package:assetsphere/app/session/app_session_controller.dart';
import 'package:assetsphere/features/authentication/presentation/providers/auth_controller.dart';
import 'package:assetsphere/app/router/app_routes.dart';
import 'package:assetsphere/app/permissions/app_permissions.dart';
import 'package:assetsphere/features/authentication/domain/entities/authenticated_user.dart';
import 'package:assetsphere/core/constants/app_sizes.dart';

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
  int _getSelectedIndex(String section, AuthRole? role) {
    if (section == 'dashboard') return 0;
    if (section == 'assets' && role != null && AppPermissions.canAccessAssets(role)) return 1;
    if (section == 'organization' && role != null && AppPermissions.canAccessOrganizationSetup(role)) {
      return AppPermissions.canAccessAssets(role) ? 2 : 1;
    }
    return 0;
  }

  void _onDestinationSelected(int index, AuthRole? role) {
    if (index == 0) {
      Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
    } else if (index == 1) {
      if (role != null && AppPermissions.canAccessAssets(role)) {
        Navigator.pushReplacementNamed(context, AppRoutes.assets);
      } else if (role != null && AppPermissions.canAccessOrganizationSetup(role)) {
        Navigator.pushReplacementNamed(context, AppRoutes.organization);
      }
    } else if (index == 2) {
      Navigator.pushReplacementNamed(context, AppRoutes.organization);
    }
  }

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
              if (isDesktop) _buildDesktopNav(context, constraints.maxWidth),
              Expanded(
                child: ClipRect(
                  child: widget.child,
                ),
              ),
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
      child: ListenableBuilder(
        listenable: widget.sessionController,
        builder: (context, _) {
          final user = widget.sessionController.currentUser;
          final role = user?.role;
          final currentSection = widget.sessionController.currentSection;
          
          return Column(
            children: [
              UserAccountsDrawerHeader(
                accountName: Text(user?.fullName ?? 'User'),
                accountEmail: Text(user?.email ?? ''),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  child: Icon(
                    Icons.person,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    _DrawerNavItem(
                      icon: Icons.dashboard_rounded,
                      label: 'Dashboard',
                      isSelected: currentSection == 'dashboard',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
                      },
                    ),
                    if (role != null && AppPermissions.canAccessAssets(role))
                      _DrawerNavItem(
                        icon: Icons.inventory_2_rounded,
                        label: 'Asset Directory',
                        isSelected: currentSection == 'assets',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushReplacementNamed(context, AppRoutes.assets);
                        },
                      ),
                    if (role != null && AppPermissions.canAccessOrganizationSetup(role))
                      _DrawerNavItem(
                        icon: Icons.business_rounded,
                        label: 'Organization Setup',
                        isSelected: currentSection == 'organization',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushReplacementNamed(context, AppRoutes.organization);
                        },
                      ),
                  ],
                ),
              ),
              const Divider(),
              ListTile(
                leading: Icon(Icons.logout, color: Theme.of(context).colorScheme.error),
                title: Text('Logout', style: TextStyle(color: Theme.of(context).colorScheme.error)),
                onTap: _handleLogout,
              ),
              const SizedBox(height: AppSizes.spacingLg),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDesktopNav(BuildContext context, double maxWidth) {
    final isExtended = maxWidth > 1200; // Extend rail on very large screens

    return ListenableBuilder(
      listenable: widget.sessionController,
      builder: (context, _) {
        final user = widget.sessionController.currentUser;
        final role = user?.role;
        final currentSection = widget.sessionController.currentSection;
        final selectedIndex = _getSelectedIndex(currentSection, role);

        final destinations = <NavigationRailDestination>[
          const NavigationRailDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard_rounded),
            label: Text('Dashboard'),
          ),
        ];

        if (role != null && AppPermissions.canAccessAssets(role)) {
          destinations.add(
            const NavigationRailDestination(
              icon: Icon(Icons.inventory_2_outlined),
              selectedIcon: Icon(Icons.inventory_2_rounded),
              label: Text('Assets'),
            ),
          );
        }

        if (role != null && AppPermissions.canAccessOrganizationSetup(role)) {
          destinations.add(
            const NavigationRailDestination(
              icon: Icon(Icons.business_outlined),
              selectedIcon: Icon(Icons.business_rounded),
              label: Text('Organization'),
            ),
          );
        }

        return Container(
          decoration: BoxDecoration(
            border: Border(
              right: BorderSide(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              ),
            ),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSizes.spacingLg),
                child: Icon(
                  Icons.blur_on,
                  color: Theme.of(context).colorScheme.primary,
                  size: isExtended ? 40 : 32,
                ),
              ),
              Expanded(
                child: NavigationRail(
                  extended: isExtended,
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (index) => _onDestinationSelected(index, role),
                  destinations: destinations,
                  labelType: isExtended ? NavigationRailLabelType.none : NavigationRailLabelType.all,
                  leading: const SizedBox(height: AppSizes.spacingMd),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: AppSizes.spacingLg),
                child: IconButton(
                  icon: Icon(Icons.logout, color: Theme.of(context).colorScheme.error),
                  tooltip: 'Logout',
                  onPressed: _handleLogout,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleLogout() async {
    await widget.authController.logout();
    widget.sessionController.logout();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
      (route) => false,
    );
  }
}

class _DrawerNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _DrawerNavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.spacingMd,
        vertical: AppSizes.spacingXs,
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        ),
        selected: isSelected,
        selectedTileColor: theme.colorScheme.primaryContainer.withValues(alpha: 0.2),
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
