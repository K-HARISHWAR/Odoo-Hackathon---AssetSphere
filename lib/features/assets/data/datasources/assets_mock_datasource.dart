import '../models/asset_model.dart';
import '../../domain/entities/asset_status.dart';
import '../../domain/entities/asset_condition.dart';
import '../../domain/entities/asset_history.dart';

abstract class AssetsDataSource {
  Future<List<AssetModel>> getAssets();
  Future<AssetModel?> getAssetById(String id);
  Future<void> saveAsset(AssetModel asset);
  Future<String> getNextAssetTag();
  Future<List<AssetHistory>> getAssetHistory(String assetId);
}

class AssetsMockDataSource implements AssetsDataSource {
  final List<AssetModel> _assets = [];

  @override
  Future<List<AssetModel>> getAssets() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _assets;
  }

  @override
  Future<AssetModel?> getAssetById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _assets.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveAsset(AssetModel asset) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _assets.add(asset);
  }

  @override
  Future<String> getNextAssetTag() async {
    await Future.delayed(const Duration(milliseconds: 100));
    final nextId = _assets.length + 1;
    return 'AF-${nextId.toString().padLeft(4, '0')}';
  }

  @override
  Future<List<AssetHistory>> getAssetHistory(String assetId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return [];
  }
}
