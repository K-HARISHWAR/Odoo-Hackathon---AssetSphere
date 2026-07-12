import '../entities/asset.dart';
import '../entities/asset_history.dart';

abstract class AssetRepository {
  Future<List<Asset>> getAssets();
  Future<Asset?> getAssetById(String id);
  Future<void> registerAsset(Asset asset);
  Future<String> generateAssetTag();
  Future<List<AssetHistory>> getAssetHistory(String assetId);
}
