import 'package:flutter/material.dart';
import 'package:assetsphere/app/app.dart';

import 'package:assetsphere/app/di/app_dependencies.dart';
import 'package:assetsphere/app/session/app_session_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final dependencies = AppDependencies.create();
  final sessionController = AppSessionController();
  
  runApp(AssetSphereApp(
    dependencies: dependencies,
    sessionController: sessionController,
  ));
}
