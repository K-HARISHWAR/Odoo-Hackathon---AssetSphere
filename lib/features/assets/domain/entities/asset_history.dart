class AssetHistory {
  final String id;
  final String assetId;
  final String action;
  final String description;
  final DateTime timestamp;
  final String performedBy;

  const AssetHistory({
    required this.id,
    required this.assetId,
    required this.action,
    required this.description,
    required this.timestamp,
    required this.performedBy,
  });
}
