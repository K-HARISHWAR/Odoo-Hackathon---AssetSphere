import 'package:flutter/material.dart';
import '../../domain/entities/recent_activity.dart';
import '../../../../core/constants/app_sizes.dart';

class RecentActivityItem extends StatelessWidget {
  final RecentActivity activity;

  const RecentActivityItem({super.key, required this.activity});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.spacingLg,
        vertical: AppSizes.spacingMd,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSizes.spacingSm),
            decoration: BoxDecoration(
              color: _getIconColor().withAlpha(30),
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
            child: Icon(_getIcon(), size: 20, color: _getIconColor()),
          ),
          const SizedBox(width: AppSizes.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      activity.title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _formatTimestamp(activity.timestamp),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  activity.description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIcon() {
    switch (activity.type) {
      case ActivityType.registration:
        return Icons.add_business_outlined;
      case ActivityType.allocation:
        return Icons.assignment_turned_in_outlined;
      case ActivityType.transfer:
        return Icons.move_up_outlined;
      case ActivityType.maintenance:
        return Icons.build_circle_outlined;
      case ActivityType.audit:
        return Icons.fact_check_outlined;
    }
  }

  Color _getIconColor() {
    switch (activity.type) {
      case ActivityType.registration:
        return Colors.blue;
      case ActivityType.allocation:
        return Colors.green;
      case ActivityType.transfer:
        return Colors.orange;
      case ActivityType.maintenance:
        return Colors.red;
      case ActivityType.audit:
        return Colors.purple;
    }
  }

  String _formatTimestamp(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
