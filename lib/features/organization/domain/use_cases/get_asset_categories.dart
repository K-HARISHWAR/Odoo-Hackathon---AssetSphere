import 'package:assetsphere/features/organization/domain/entities/asset_category.dart';
import 'package:assetsphere/features/organization/domain/repositories/organization_repository.dart';

class GetAssetCategories {
  final OrganizationRepository repository;

  GetAssetCategories(this.repository);

  Future<List<AssetCategory>> call() {
    return repository.getAssetCategories();
  }
}
