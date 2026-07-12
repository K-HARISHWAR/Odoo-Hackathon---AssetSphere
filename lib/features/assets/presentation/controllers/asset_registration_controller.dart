import 'package:flutter/foundation.dart';
import '../../domain/entities/asset.dart';
import '../../domain/entities/asset_status.dart';
import '../../domain/entities/asset_condition.dart';
import '../../domain/repositories/asset_repository.dart';
import '../../domain/usecases/add_asset_usecase.dart';

class AssetRegistrationController extends ChangeNotifier {
  final AssetRepository repository;
  final AddAssetUseCase addAsset;

  AssetRegistrationController({
    required this.repository,
    required this.addAsset,
  });

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  String _generatedTag = '';
  String get generatedTag => _generatedTag;

  Future<void> prepareRegistration() async {
    _isLoading = true;
    notifyListeners();
    try {
      _generatedTag = await repository.generateAssetTag();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> submitRegistration({
    required String name,
    required String? serialNumber,
    required String category,
    required String location,
    required String department,
    required DateTime purchaseDate,
    required double purchaseCost,
    DateTime? warrantyExpiry,
    required AssetCondition condition,
    required bool isShared,
    required bool isBookable,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final asset = Asset(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        assetTag: _generatedTag,
        name: name,
        serialNumber: serialNumber,
        category: category,
        location: location,
        department: department,
        purchaseDate: purchaseDate,
        purchaseCost: purchaseCost,
        warrantyExpiry: warrantyExpiry,
        condition: condition,
        status: AssetStatus.available,
        isShared: isShared,
        isBookable: isBookable,
      );

      await addAsset.execute(asset);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
