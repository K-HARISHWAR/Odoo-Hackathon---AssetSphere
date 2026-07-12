import 'package:flutter/material.dart';
import '../constants/app_sizes.dart';
import '../constants/app_colors.dart';
import '../../features/assets/domain/entities/asset_status.dart';
import '../../features/assets/domain/entities/asset_condition.dart';

class AppStatusChip extends StatelessWidget {
  final String label;
  final Color color;

  const AppStatusChip({
    super.key,
    required this.label,
    required this.color,
  });

  factory AppStatusChip.fromAssetStatus(AssetStatus status) {
    Color color;
    switch (status) {
      case AssetStatus.available:
        color = AppColors.statusAvailable;
        break;
      case AssetStatus.allocated:
        color = AppColors.statusAllocated;
        break;
      case AssetStatus.maintenance:
        color = AppColors.statusMaintenance;
        break;
      case AssetStatus.reserved:
        color = AppColors.statusReserved;
        break;
      case AssetStatus.lost:
        color = AppColors.statusLost;
        break;
      case AssetStatus.retired:
        color = AppColors.statusRetired;
        break;
      case AssetStatus.disposed:
        color = AppColors.statusDisposed;
        break;
    }
    return AppStatusChip(label: status.displayName, color: color);
  }

  factory AppStatusChip.fromAssetCondition(AssetCondition condition) {
    Color color;
    switch (condition) {
      case AssetCondition.newCondition:
      case AssetCondition.excellent:
        color = AppColors.success;
        break;
      case AssetCondition.good:
        color = AppColors.info;
        break;
      case AssetCondition.fair:
        color = AppColors.warning;
        break;
      case AssetCondition.damaged:
        color = AppColors.error;
        break;
    }
    return AppStatusChip(label: condition.displayName, color: color);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.spacingMd,
        vertical: AppSizes.spacingXs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}
