import 'package:flutter/material.dart';
import 'package:assetsphere/core/constants/app_strings.dart';
import 'package:assetsphere/core/constants/app_sizes.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.appName)),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppSizes.maxDesktopContentWidth,
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSizes.spacingMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: AppSizes.spacingLg),
                  Text(
                    'AssetSphere Setup Completed',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSizes.spacingSm),
                  Text(
                    AppStrings.appDescription,
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSizes.spacingLg),
                  const Text(
                    'Flutter project initialization was successful.',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSizes.spacingXl),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      int crossAxisCount = 1;
                      if (constraints.maxWidth > 900) {
                        crossAxisCount = 4;
                      } else if (constraints.maxWidth > 600) {
                        crossAxisCount = 2;
                      }

                      return GridView.count(
                        crossAxisCount: crossAxisCount,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: AppSizes.spacingMd,
                        mainAxisSpacing: AppSizes.spacingMd,
                        childAspectRatio: 1.5,
                        children: const [
                          _OverviewCard(
                            icon: Icons.inventory,
                            title: 'Assets',
                            description:
                                'Register and manage organizational assets.',
                          ),
                          _OverviewCard(
                            icon: Icons.assignment_turned_in,
                            title: 'Allocations',
                            description:
                                'Track asset allocation, return, and transfer.',
                          ),
                          _OverviewCard(
                            icon: Icons.event_available,
                            title: 'Bookings',
                            description:
                                'Book shared resources without time conflicts.',
                          ),
                          _OverviewCard(
                            icon: Icons.build,
                            title: 'Maintenance',
                            description:
                                'Track maintenance requests and repair workflows.',
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _OverviewCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.spacingMd),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: AppSizes.spacingSm),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSizes.spacingXs),
            Text(
              description,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
