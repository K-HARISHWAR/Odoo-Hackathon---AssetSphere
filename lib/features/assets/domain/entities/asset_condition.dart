enum AssetCondition { newCondition, good, fair, damaged, unusable }

extension AssetConditionX on AssetCondition {
  String get displayName {
    switch (this) {
      case AssetCondition.newCondition:
        return 'New';
      case AssetCondition.good:
        return 'Good';
      case AssetCondition.fair:
        return 'Fair';
      case AssetCondition.damaged:
        return 'Damaged';
      case AssetCondition.unusable:
        return 'Unusable';
    }
  }
}
