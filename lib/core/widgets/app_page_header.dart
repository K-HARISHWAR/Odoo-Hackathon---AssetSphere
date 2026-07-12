import 'package:flutter/material.dart';
import '../constants/app_sizes.dart';

class AppPageHeader extends StatelessWidget {
  final String title;
  final String? description;
  final Widget? action;
  final Widget? icon;

  const AppPageHeader({
    super.key,
    required this.title,
    this.description,
    this.action,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.spacingLg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            icon!,
            const SizedBox(width: AppSizes.spacingMd),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.headlineMedium),
                if (description != null) ...[
                  const SizedBox(height: AppSizes.spacingSm),
                  Text(
                    description!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (action != null) ...[
            const SizedBox(width: AppSizes.spacingMd),
            action!,
          ],
        ],
      ),
    );
  }
}
