import 'package:assetsphere/features/organization/domain/entities/record_status.dart';

class AssetCategory {
  final String id;
  final String name;
  final String description;
  final int? warrantyPeriodMonths;
  final String? customFieldDescription;
  final RecordStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AssetCategory({
    required this.id,
    required this.name,
    required this.description,
    this.warrantyPeriodMonths,
    this.customFieldDescription,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });
}
