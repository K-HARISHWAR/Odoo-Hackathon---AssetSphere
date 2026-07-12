import 'package:flutter/material.dart';
import 'package:assetsphere/app/theme/app_theme.dart';
import 'package:assetsphere/core/constants/app_strings.dart';
import 'package:assetsphere/features/dashboard/presentation/pages/home_page.dart';
import 'package:assetsphere/features/assets/presentation/pages/asset_directory_page.dart';
import 'package:assetsphere/features/assets/presentation/pages/register_asset_page.dart';

class AssetSphereApp extends StatelessWidget {
  const AssetSphereApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppStrings.appName,
      theme: AppTheme.lightTheme,
      home: Builder(
        builder: (context) => HomePage(
          onRegisterAsset: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RegisterAssetPage(
                  onSuccess: () => Navigator.pop(context),
                ),
              ),
            );
          },
          onViewDirectory: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AssetDirectoryPage()),
            );
          },
          onBookResource: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Bookings module will be implemented by Developer 1'),
              ),
            );
          },
          onMaintenanceRequest: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Maintenance module will be implemented by Developer 1'),
              ),
            );
          },
          onSearch: (query) {
            if (query.trim().isEmpty) return;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AssetDirectoryPage(initialSearchQuery: query),
              ),
            );
          },
        ),
      ),
    );
  }
}
