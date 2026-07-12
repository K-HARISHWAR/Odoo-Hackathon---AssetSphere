import '../entities/asset.dart';
import '../repositories/asset_repository.dart';

class AddAssetUseCase {
  final AssetRepository repository;

  AddAssetUseCase(this.repository);

  Future<void> execute(Asset asset) async {
    return await repository.registerAsset(asset);
  }
}
