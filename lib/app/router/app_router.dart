import 'package:flutter/material.dart';
import 'package:assetsphere/app/di/app_dependencies.dart';
import 'package:assetsphere/app/session/app_session_controller.dart';
import 'package:assetsphere/app/permissions/app_permissions.dart';
import 'package:assetsphere/app/router/app_routes.dart';
import 'package:assetsphere/app/pages/not_found_page.dart';
import 'package:assetsphere/app/pages/unauthorized_page.dart';
import 'package:assetsphere/app/shell/main_app_shell.dart';

import 'package:assetsphere/features/authentication/presentation/pages/login_page.dart';
import 'package:assetsphere/features/authentication/presentation/pages/signup_page.dart';
import 'package:assetsphere/features/authentication/presentation/pages/forgot_password_page.dart';

import 'package:assetsphere/features/dashboard/presentation/pages/home_page.dart';
import 'package:assetsphere/features/organization/presentation/pages/organization_setup_page.dart';
import 'package:assetsphere/features/assets/presentation/pages/asset_directory_page.dart';
import 'package:assetsphere/features/assets/presentation/pages/register_asset_page.dart';
import 'package:assetsphere/features/assets/presentation/pages/asset_details_page.dart';

class AppRouter {
  final AppDependencies dependencies;
  final AppSessionController sessionController;

  AppRouter({required this.dependencies, required this.sessionController});

  Route<dynamic> onGenerateRoute(RouteSettings settings) {
    // Unauthenticated routes
    if (!sessionController.isAuthenticated) {
      if (settings.name == AppRoutes.signup) {
        return MaterialPageRoute(
          builder: (context) => SignupPage(
            controller: dependencies.authController,
            onBackToLogin: () => Navigator.pop(context),
            onSignupSuccess: (user) {
              Navigator.pop(context);
            },
          ),
        );
      }

      if (settings.name == AppRoutes.forgotPassword) {
        return MaterialPageRoute(
          builder: (context) => ForgotPasswordPage(
            controller: dependencies.authController,
            onBackToLogin: () => Navigator.pop(context),
            onResetRequested: (email) {
              Navigator.pop(context);
            },
          ),
        );
      }

      // Default to login if not authenticated
      return MaterialPageRoute(
        builder: (context) => LoginPage(
          controller: dependencies.authController,
          onCreateAccount: () => Navigator.pushNamed(context, AppRoutes.signup),
          onForgotPassword: () =>
              Navigator.pushNamed(context, AppRoutes.forgotPassword),
          onLoginSuccess: (user) {
            sessionController.authenticate(user);
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.dashboard,
              (route) => false,
            );
          },
        ),
      );
    }

    // Authenticated routes
    final user = sessionController.currentUser;
    if (user == null) {
      // Failsafe
      sessionController.logout();
      return _errorRoute();
    }

    switch (settings.name) {
      case AppRoutes.dashboard:
      case '/':
        sessionController.selectSection('dashboard');
        return _buildShellRoute(
          child: Builder(
            builder: (ctx) => HomePage(
              controller: dependencies.dashboardController,
              onRegisterAsset: () =>
                  Navigator.pushNamed(ctx, AppRoutes.registerAsset),
              onViewDirectory: () =>
                  Navigator.pushReplacementNamed(ctx, AppRoutes.assets),
              onBookResource: () {},
              onMaintenanceRequest: () {},
              onSearch: (query) {
                if (query.trim().isNotEmpty) {
                  Navigator.pushNamed(ctx, AppRoutes.assets, arguments: query);
                }
              },
            ),
          ),
        );

      case AppRoutes.organization:
        if (!AppPermissions.canAccessOrganizationSetup(user.role)) {
          return MaterialPageRoute(builder: (_) => const UnauthorizedPage());
        }
        sessionController.selectSection('organization');
        return _buildShellRoute(
          child: Builder(
            builder: (ctx) => OrganizationSetupPage(
              controller: dependencies.organizationController,
              onBack: () => Navigator.pop(ctx),
            ),
          ),
        );

      case AppRoutes.assets:
        if (!AppPermissions.canAccessAssets(user.role)) {
          return MaterialPageRoute(builder: (_) => const UnauthorizedPage());
        }
        sessionController.selectSection('assets');

        final initialQuery = settings.arguments as String?;
        return _buildShellRoute(
          child: Builder(
            builder: (ctx) => AssetDirectoryPage(
              controller: dependencies.assetDirectoryController,
              initialSearchQuery: initialQuery,
            ),
          ),
        );

      case AppRoutes.registerAsset:
        if (!AppPermissions.canRegisterAsset(user.role)) {
          return MaterialPageRoute(builder: (_) => const UnauthorizedPage());
        }
        return MaterialPageRoute(
          builder: (context) => RegisterAssetPage(
            repository: dependencies.assetRepository,
            onSuccess: () => Navigator.pop(context),
            onCancel: () => Navigator.pop(context),
          ),
        );

      case AppRoutes.assetDetails:
        if (!AppPermissions.canAccessAssets(user.role)) {
          return MaterialPageRoute(builder: (_) => const UnauthorizedPage());
        }
        final assetId = settings.arguments as String?;
        if (assetId == null) return _errorRoute();

        return MaterialPageRoute(
          builder: (context) => AssetDetailsPage(
            assetId: assetId,
            repository: dependencies.assetRepository,
            onBack: () => Navigator.pop(context),
          ),
        );

      default:
        return MaterialPageRoute(builder: (_) => const NotFoundPage());
    }
  }

  Route<dynamic> _buildShellRoute({required Widget child}) {
    return MaterialPageRoute(
      builder: (ctx) => MainAppShell(
        sessionController: sessionController,
        authController: dependencies.authController,
        child: child,
      ),
    );
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(builder: (_) => const NotFoundPage());
  }
}
