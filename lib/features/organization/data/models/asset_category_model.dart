import 'package:assetsphere/features/organization/domain/entities/asset_category.dart';
import 'package:assetsphere/features/organization/domain/entities/record_status.dart';

class AssetCategoryModel extends AssetCategory {
  const AssetCategoryModel({
    required super.id,
    required super.name,
    required super.description,
    super.warrantyPeriodMonths,
    super.customFieldDescription,
    required super.status,
    required super.createdAt,
    required super.updatedAt,
  });

  factory AssetCategoryModel.fromEntity(AssetCategory entity) {
    return AssetCategoryModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      warrantyPeriodMonths: entity.warrantyPeriodMonths,
      customFieldDescription: entity.customFieldDescription,
      status: entity.status,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  AssetCategory toEntity() {
    return AssetCategory(
      id: id,
      name: name,
      description: description,
      warrantyPeriodMonths: warrantyPeriodMonths,
      customFieldDescription: customFieldDescription,
      status: status,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
