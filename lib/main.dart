import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:assetsphere/app/app.dart';
import 'package:assetsphere/app/di/app_dependencies.dart';
import 'package:assetsphere/app/session/app_session_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  const supabasePublishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
  );

  if (supabaseUrl.isEmpty || supabasePublishableKey.isEmpty) {
    throw StateError(
      'Missing SUPABASE_URL or SUPABASE_PUBLISHABLE_KEY. Please provide them via --dart-define.',
    );
  }

  await Supabase.initialize(
    url: supabaseUrl,
    publishableKey: supabasePublishableKey,
  );

  final dependencies = AppDependencies.production(Supabase.instance.client);
  final sessionController = AppSessionController(
    authRepository: dependencies.authController.repository,
  );

  runApp(
    AssetSphereApp(
      dependencies: dependencies,
      sessionController: sessionController,
    ),
  );
}
