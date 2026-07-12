import 'package:flutter_test/flutter_test.dart';
import 'package:assetsphere/features/assets/data/repositories/mock_asset_repository.dart';

void main() {
  late MockAssetRepository repository;

  setUp(() {
    repository = MockAssetRepository();
  });

  group('Asset Tag Generation', () {
    test('should generate tags in AF-000X format', () async {
      final tag1 = await repository.generateAssetTag();
      expect(tag1, matches(RegExp(r'^AF-\d{4}$')));
    });

    test('should increment tag number based on asset count', () async {
      final tag1 = await repository.generateAssetTag();
      expect(tag1, 'AF-0003'); // Mock repo starts with 2 assets
    });
  });
}
