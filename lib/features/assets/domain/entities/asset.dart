import 'asset_status.dart';
import 'asset_condition.dart';

class Asset {
  final String id;
  final String assetTag;
  final String name;
  final String? serialNumber;
  final String category;
  final String location;
  final String department;
  final DateTime purchaseDate;
  final double purchaseCost;
  final DateTime? warrantyExpiry;
  final AssetCondition condition;
  final AssetStatus status;
  final bool isShared;
  final bool isBookable;
  final String? photoUrl;
  final List<String> documentUrls;

  const Asset({
    required this.id,
    required this.assetTag,
    required this.name,
    this.serialNumber,
    required this.category,
    required this.location,
    required this.department,
    required this.purchaseDate,
    required this.purchaseCost,
    this.warrantyExpiry,
    required this.condition,
    required this.status,
    this.isShared = false,
    this.isBookable = false,
    this.photoUrl,
    this.documentUrls = const [],
  });

  Asset copyWith({
    String? id,
    String? assetTag,
    String? name,
    String? serialNumber,
    String? category,
    String? location,
    String? department,
    DateTime? purchaseDate,
    double? purchaseCost,
    DateTime? warrantyExpiry,
    AssetCondition? condition,
    AssetStatus? status,
    bool? isShared,
    bool? isBookable,
    String? photoUrl,
    List<String>? documentUrls,
  }) {
    return Asset(
      id: id ?? this.id,
      assetTag: assetTag ?? this.assetTag,
      name: name ?? this.name,
      serialNumber: serialNumber ?? this.serialNumber,
      category: category ?? this.category,
      location: location ?? this.location,
      department: department ?? this.department,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      purchaseCost: purchaseCost ?? this.purchaseCost,
      warrantyExpiry: warrantyExpiry ?? this.warrantyExpiry,
      condition: condition ?? this.condition,
      status: status ?? this.status,
      isShared: isShared ?? this.isShared,
      isBookable: isBookable ?? this.isBookable,
      photoUrl: photoUrl ?? this.photoUrl,
      documentUrls: documentUrls ?? this.documentUrls,
    );
  }
}
