import 'package:flutter/material.dart';
import 'package:assetsphere/app/theme/app_theme.dart';
import 'package:assetsphere/core/constants/app_strings.dart';
import 'package:assetsphere/features/dashboard/presentation/pages/home_page.dart';

class AssetSphereApp extends StatelessWidget {
  const AssetSphereApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppStrings.appName,
      theme: AppTheme.lightTheme,
      home: const HomePage(),
    );
  }
}
