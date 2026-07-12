import 'package:flutter/foundation.dart';
import '../../domain/entities/asset.dart';
import '../../domain/entities/asset_history.dart';
import '../../domain/repositories/asset_repository.dart';

class AssetDetailsController extends ChangeNotifier {
  final AssetRepository repository;

  AssetDetailsController({required this.repository});

  Asset? _asset;
  Asset? get asset => _asset;

  List<AssetHistory> _history = [];
  List<AssetHistory> get history => _history;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> loadAssetDetails(String id) async {
    _isLoading = true;
    notifyListeners();
    try {
      _asset = await repository.getAssetById(id);
      if (_asset != null) {
        _history = await repository.getAssetHistory(id);
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
