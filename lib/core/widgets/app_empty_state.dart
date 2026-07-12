import 'package:flutter/material.dart';
import '../constants/app_sizes.dart';

class AppEmptyState extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Widget? action;

  const AppEmptyState({
    super.key,
    required this.title,
    required this.description,
    this.icon = Icons.inbox_outlined,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.spacingXl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: AppSizes.spacingLg),
            Text(
              title,
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.spacingSm),
            Text(
              description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (action != null) ...[
              const SizedBox(height: AppSizes.spacingLg),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
