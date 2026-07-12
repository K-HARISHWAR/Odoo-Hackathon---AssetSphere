import 'package:flutter/foundation.dart';
import '../../domain/entities/asset.dart';
import '../../domain/entities/asset_status.dart';
import '../../domain/usecases/get_assets_usecase.dart';

class AssetDirectoryController extends ChangeNotifier {
  final GetAssetsUseCase getAssets;

  AssetDirectoryController({required this.getAssets});

  List<Asset> _allAssets = [];
  List<Asset> _filteredAssets = [];
  List<Asset> get assets => _filteredAssets;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _searchQuery = '';
  AssetStatus? _statusFilter;

  Future<void> loadAssets() async {
    _isLoading = true;
    notifyListeners();
    try {
      _allAssets = await getAssets.execute();
      _applyFilters();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  void setStatusFilter(AssetStatus? status) {
    _statusFilter = status;
    _applyFilters();
  }

  void _applyFilters() {
    _filteredAssets = _allAssets.where((asset) {
      final matchesSearch =
          asset.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          asset.assetTag.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (asset.serialNumber?.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ) ??
              false);

      final matchesStatus =
          _statusFilter == null || asset.status == _statusFilter;

      return matchesSearch && matchesStatus;
    }).toList();
    notifyListeners();
  }
}
