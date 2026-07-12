import 'package:flutter/material.dart';
import 'package:assetsphere/app/theme/app_theme.dart';
import 'package:assetsphere/core/constants/app_strings.dart';
import 'package:assetsphere/app/di/app_dependencies.dart';
import 'package:assetsphere/app/session/app_session_controller.dart';
import 'package:assetsphere/app/router/app_router.dart';
import 'package:assetsphere/app/router/app_routes.dart';

class AssetSphereApp extends StatefulWidget {
  final AppDependencies dependencies;
  final AppSessionController sessionController;

  const AssetSphereApp({
    super.key,
    required this.dependencies,
    required this.sessionController,
  });

  @override
  State<AssetSphereApp> createState() => _AssetSphereAppState();
}

class _AssetSphereAppState extends State<AssetSphereApp> {
  late final AppRouter _appRouter;

  @override
  void initState() {
    super.initState();
    _appRouter = AppRouter(
      dependencies: widget.dependencies,
      sessionController: widget.sessionController,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.sessionController,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: AppStrings.appName,
          theme: AppTheme.lightTheme,
          initialRoute: AppRoutes.login,
          onGenerateRoute: _appRouter.onGenerateRoute,
        );
      },
    );
  }
}
