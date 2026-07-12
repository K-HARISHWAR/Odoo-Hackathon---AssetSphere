enum AssetStatus {
  available,
  allocated,
  reserved,
  maintenance,
  lost,
  retired,
  disposed,
}

extension AssetStatusX on AssetStatus {
  String get displayName {
    switch (this) {
      case AssetStatus.available: return 'Available';
      case AssetStatus.allocated: return 'Allocated';
      case AssetStatus.reserved: return 'Reserved';
      case AssetStatus.maintenance: return 'Maintenance';
      case AssetStatus.lost: return 'Lost';
      case AssetStatus.retired: return 'Retired';
      case AssetStatus.disposed: return 'Disposed';
    }
  }
}
