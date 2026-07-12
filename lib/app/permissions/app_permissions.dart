import 'package:assetsphere/features/authentication/domain/entities/authenticated_user.dart';

class AppPermissions {
  static bool canAccessOrganizationSetup(AuthRole role) {
    return role == AuthRole.admin;
  }

  static bool canRegisterAsset(AuthRole role) {
    return role == AuthRole.admin || role == AuthRole.assetManager;
  }

  static bool canAccessDashboard(AuthRole role) {
    return true; // All roles can access dashboard
  }

  static bool canAccessAssets(AuthRole role) {
    return true; // All roles can access assets
  }
}
