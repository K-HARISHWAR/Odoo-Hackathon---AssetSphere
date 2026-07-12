enum AssetCondition { newCondition, excellent, good, fair, damaged }

extension AssetConditionX on AssetCondition {
  String get displayName {
    switch (this) {
      case AssetCondition.newCondition:
        return 'New';
      case AssetCondition.excellent:
        return 'Excellent';
      case AssetCondition.good:
        return 'Good';
      case AssetCondition.fair:
        return 'Fair';
      case AssetCondition.damaged:
        return 'Damaged';
    }
  }
}
