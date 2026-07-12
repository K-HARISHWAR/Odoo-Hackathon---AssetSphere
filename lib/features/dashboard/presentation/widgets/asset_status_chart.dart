import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';

class AssetStatusChart extends StatelessWidget {
  final Map<String, int> summary;

  const AssetStatusChart({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final total = summary.values.fold(0, (sum, val) => sum + val);

    return Column(
      children: [
        Center(
          child: SizedBox(
            height: 180,
            width: 180,
            child: Stack(
              children: [
                Center(
                  child: SizedBox(
                    width: 150,
                    height: 150,
                    child: CircularProgressIndicator(
                      value: total > 0 ? 1.0 : 0.0,
                      strokeWidth: 12,
                      backgroundColor: Theme.of(context).colorScheme.outlineVariant,
                      color: Theme.of(context).colorScheme.primary,
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$total',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                      ),
                      Text(
                        'Total Assets',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSizes.spacingXl),
        ...summary.entries.map((e) => _StatusProgressRow(
              label: e.key,
              count: e.value,
              total: total,
              color: _getStatusColor(e.key),
            )),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Available':
        return Colors.green;
      case 'Allocated':
        return Colors.blue;
      case 'Maintenance':
        return Colors.orange;
      case 'Lost':
        return Colors.red;
      case 'Retired':
        return Colors.grey;
      default:
        return Colors.blueGrey;
    }
  }
}

class _StatusProgressRow extends StatelessWidget {
  final String label;
  final int count;
  final int total;
  final Color color;

  const _StatusProgressRow({
    required this.label,
    required this.count,
    required this.total,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = total > 0 ? count / total : 0.0;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.spacingMd),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: AppSizes.spacingSm),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Text(
                '$count',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 6),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: percentage),
            duration: const Duration(milliseconds: 1200),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: value,
                  backgroundColor: color.withAlpha(30),
                  color: color,
                  minHeight: 4,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
