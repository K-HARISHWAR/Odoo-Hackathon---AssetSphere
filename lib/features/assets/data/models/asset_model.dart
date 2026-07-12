import '../../domain/entities/asset.dart';
import '../../domain/entities/asset_status.dart';
import '../../domain/entities/asset_condition.dart';

class AssetModel extends Asset {
  const AssetModel({
    required super.id,
    required super.assetTag,
    required super.name,
    super.serialNumber,
    required super.category,
    required super.location,
    required super.department,
    required super.purchaseDate,
    required super.purchaseCost,
    super.warrantyExpiry,
    required super.condition,
    required super.status,
    super.isShared,
    super.isBookable,
    super.photoUrl,
    super.documentUrls,
  });

  factory AssetModel.fromEntity(Asset entity) {
    return AssetModel(
      id: entity.id,
      assetTag: entity.assetTag,
      name: entity.name,
      serialNumber: entity.serialNumber,
      category: entity.category,
      location: entity.location,
      department: entity.department,
      purchaseDate: entity.purchaseDate,
      purchaseCost: entity.purchaseCost,
      warrantyExpiry: entity.warrantyExpiry,
      condition: entity.condition,
      status: entity.status,
      isShared: entity.isShared,
      isBookable: entity.isBookable,
      photoUrl: entity.photoUrl,
      documentUrls: entity.documentUrls,
    );
  }

  factory AssetModel.fromJson(Map<String, dynamic> json) {
    return AssetModel(
      id: json['id'],
      assetTag: json['assetTag'],
      name: json['name'],
      serialNumber: json['serialNumber'],
      category: json['category'],
      location: json['location'],
      department: json['department'],
      purchaseDate: DateTime.parse(json['purchaseDate']),
      purchaseCost: (json['purchaseCost'] as num).toDouble(),
      warrantyExpiry: json['warrantyExpiry'] != null
          ? DateTime.parse(json['warrantyExpiry'])
          : null,
      condition: AssetCondition.values.firstWhere(
        (e) => e.toString() == json['condition'],
      ),
      status: AssetStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
      ),
      isShared: json['isShared'] ?? false,
      isBookable: json['isBookable'] ?? false,
      photoUrl: json['photoUrl'],
      documentUrls: List<String>.from(json['documentUrls'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'assetTag': assetTag,
      'name': name,
      'serialNumber': serialNumber,
      'category': category,
      'location': location,
      'department': department,
      'purchaseDate': purchaseDate.toIso8601String(),
      'purchaseCost': purchaseCost,
      'warrantyExpiry': warrantyExpiry?.toIso8601String(),
      'condition': condition.toString(),
      'status': status.toString(),
      'isShared': isShared,
      'isBookable': isBookable,
      'photoUrl': photoUrl,
      'documentUrls': documentUrls,
    };
  }
}
