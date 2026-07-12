import 'package:flutter_test/flutter_test.dart';
import 'package:assetsphere/features/assets/presentation/controllers/asset_registration_controller.dart';
import 'package:assetsphere/features/assets/data/repositories/asset_repository_impl.dart';
import 'package:assetsphere/features/assets/data/datasources/assets_mock_datasource.dart';
import 'package:assetsphere/features/assets/domain/usecases/add_asset_usecase.dart';
import 'package:assetsphere/features/assets/domain/entities/asset_condition.dart';

void main() {
  late AssetRegistrationController controller;
  late AssetRepositoryImpl repository;

  setUp(() {
    final dataSource = AssetsMockDataSource();
    repository = AssetRepositoryImpl(dataSource: dataSource);
    final addAssetUseCase = AddAssetUseCase(repository);
    controller = AssetRegistrationController(
      repository: repository,
      addAsset: addAssetUseCase,
    );
  });

  test('should update generated tag when preparing registration', () async {
    await controller.prepareRegistration();
    expect(controller.generatedTag, isNotEmpty);
    expect(controller.isLoading, false);
  });

  test('should return true on successful registration', () async {
    await controller.prepareRegistration();
    final success = await controller.submitRegistration(
      name: 'Test Asset',
      serialNumber: 'SN123',
      category: 'IT',
      location: 'Office',
      department: 'HR',
      purchaseDate: DateTime.now(),
      purchaseCost: 100.0,
      condition: AssetCondition.newCondition,
      isShared: false,
      isBookable: false,
    );
    expect(success, true);
  });
}
