import 'package:assetsphere/features/organization/domain/entities/asset_category.dart';
import 'package:assetsphere/features/organization/domain/entities/record_status.dart';
import 'package:assetsphere/features/organization/domain/repositories/organization_repository.dart';

class SaveAssetCategory {
  final OrganizationRepository repository;

  SaveAssetCategory(this.repository);

  Future<AssetCategory> call({
    String? id,
    required String name,
    required String description,
    int? warrantyPeriodMonths,
    String? customFieldDescription,
    required RecordStatus status,
  }) {
    if (id == null) {
      return repository.createAssetCategory(
        name: name,
        description: description,
        warrantyPeriodMonths: warrantyPeriodMonths,
        customFieldDescription: customFieldDescription,
        status: status,
      );
    } else {
      return repository.updateAssetCategory(
        id: id,
        name: name,
        description: description,
        warrantyPeriodMonths: warrantyPeriodMonths,
        customFieldDescription: customFieldDescription,
        status: status,
      );
    }
  }
}
