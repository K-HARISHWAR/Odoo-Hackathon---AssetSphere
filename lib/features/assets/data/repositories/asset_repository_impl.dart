import '../../domain/entities/asset.dart';
import '../../domain/entities/asset_history.dart';
import '../../domain/repositories/asset_repository.dart';
import '../datasources/assets_mock_datasource.dart';
import '../models/asset_model.dart';

class AssetRepositoryImpl implements AssetRepository {
  final AssetsDataSource dataSource;

  AssetRepositoryImpl({required this.dataSource});

  @override
  Future<List<Asset>> getAssets() async {
    return await dataSource.getAssets();
  }

  @override
  Future<Asset?> getAssetById(String id) async {
    return await dataSource.getAssetById(id);
  }

  @override
  Future<void> registerAsset(Asset asset) async {
    return await dataSource.saveAsset(AssetModel.fromEntity(asset));
  }

  @override
  Future<String> generateAssetTag() async {
    return await dataSource.getNextAssetTag();
  }

  @override
  Future<List<AssetHistory>> getAssetHistory(String assetId) async {
    return await dataSource.getAssetHistory(assetId);
  }
}
