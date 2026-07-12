import 'package:assetsphere/core/utils/database_enum_mappers.dart';
import 'package:assetsphere/core/utils/supabase_error_mapper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/asset.dart';
import '../../domain/entities/asset_history.dart';
import '../../domain/repositories/asset_repository.dart';

class SupabaseAssetRepositoryImpl implements AssetRepository {
  final SupabaseClient _supabase;

  SupabaseAssetRepositoryImpl({required SupabaseClient supabaseClient})
    : _supabase = supabaseClient;

  @override
  Future<List<Asset>> getAssets() async {
    final response = await _supabase
        .from('assets')
        .select('''
      *,
      asset_categories (name),
      locations (name),
      departments (name)
    ''')
        .order('created_at', ascending: false);

    return (response as List<dynamic>).map((row) => _mapToAsset(row)).toList();
  }

  @override
  Future<Asset?> getAssetById(String id) async {
    final response = await _supabase
        .from('assets')
        .select('''
      *,
      asset_categories (name),
      locations (name),
      departments (name)
    ''')
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;
    return _mapToAsset(response);
  }

  @override
  Future<String> generateAssetTag() async {
    // Return empty since backend generates this via the RPC.
    return '';
  }

  @override
  Future<void> registerAsset(Asset asset) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('Authentication missing');
      }

      final profile = await _supabase
          .from('profiles')
          .select('organization_id')
          .eq('id', user.id)
          .maybeSingle();
      if (profile == null) {
        throw Exception('User profile not found');
      }
      final orgId = profile['organization_id'] as String;

      final categoryId = await _resolveCategoryId(asset.category, orgId);
      final locationId = asset.location.isNotEmpty
          ? await _resolveLocationId(asset.location, orgId)
          : null;
      final departmentId = asset.department.isNotEmpty
          ? await _resolveDepartmentId(asset.department, orgId)
          : null;

      await _supabase.rpc(
        'register_asset',
        params: {
          'p_name': asset.name,
          'p_category_id': categoryId,
          'p_condition': DatabaseEnumMappers.assetConditionToDatabase(
            asset.condition,
          ),
          'p_serial_number': asset.serialNumber?.isEmpty == true
              ? null
              : asset.serialNumber,
          'p_acquisition_date': asset.purchaseDate.toIso8601String().split(
            'T',
          )[0],
          'p_acquisition_cost': asset.purchaseCost,
          'p_location_id': locationId,
          'p_department_id': departmentId,
          'p_is_shared': asset.isShared,
          'p_is_bookable': asset.isBookable,
          'p_warranty_expiry_date': asset.warrantyExpiry
              ?.toIso8601String()
              .split('T')[0],
          'p_notes': null,
        },
      );
    } catch (e) {
      throw Exception(SupabaseErrorMapper.mapError(e));
    }
  }

  @override
  Future<List<AssetHistory>> getAssetHistory(String assetId) async {
    final response = await _supabase
        .from('asset_status_history')
        .select('''
      *,
      profiles:changed_by (full_name)
    ''')
        .eq('asset_id', assetId)
        .order('changed_at', ascending: false);

    return (response as List<dynamic>).map((row) {
      return AssetHistory(
        id: row['id'] as String,
        assetId: row['asset_id'] as String,
        action:
            'Status changed to ${DatabaseEnumMappers.assetStatusFromDatabase(row['new_status'] as String).name}',
        description: row['reason'] as String? ?? 'No reason provided',
        timestamp: DateTime.parse(row['changed_at'] as String),
        performedBy: (row['profiles'] != null)
            ? (row['profiles']['full_name'] as String? ?? 'Unknown')
            : 'Unknown',
      );
    }).toList();
  }

  Future<String> _resolveCategoryId(String name, String orgId) async {
    final res = await _supabase
        .from('asset_categories')
        .select('id')
        .eq('organization_id', orgId)
        .ilike('name', name)
        .maybeSingle();
    if (res != null) return res['id'] as String;

    final insertRes = await _supabase
        .from('asset_categories')
        .insert({'name': name, 'organization_id': orgId})
        .select('id')
        .single();
    return insertRes['id'] as String;
  }

  Future<String> _resolveLocationId(String name, String orgId) async {
    final res = await _supabase
        .from('locations')
        .select('id')
        .eq('organization_id', orgId)
        .ilike('name', name)
        .maybeSingle();
    if (res != null) return res['id'] as String;

    final insertRes = await _supabase
        .from('locations')
        .insert({
          'name': name,
          'code': _generateCode(name),
          'organization_id': orgId,
        })
        .select('id')
        .single();
    return insertRes['id'] as String;
  }

  Future<String> _resolveDepartmentId(String name, String orgId) async {
    final res = await _supabase
        .from('departments')
        .select('id')
        .eq('organization_id', orgId)
        .ilike('name', name)
        .maybeSingle();
    if (res != null) return res['id'] as String;

    final insertRes = await _supabase
        .from('departments')
        .insert({
          'name': name,
          'code': _generateCode(name),
          'organization_id': orgId,
        })
        .select('id')
        .single();
    return insertRes['id'] as String;
  }

  String _generateCode(String name) {
    return name
        .toUpperCase()
        .replaceAll(RegExp(r'[^A-Z0-9]'), '')
        .substring(0, name.length < 3 ? name.length : 3);
  }

  Asset _mapToAsset(Map<String, dynamic> row) {
    return Asset(
      id: row['id'] as String,
      assetTag: row['asset_tag'] as String,
      name: row['name'] as String,
      serialNumber: row['serial_number'] as String?,
      category: (row['asset_categories'] != null)
          ? row['asset_categories']['name'] as String
          : 'Unknown',
      location: (row['locations'] != null)
          ? row['locations']['name'] as String
          : 'Unknown',
      department: (row['departments'] != null)
          ? row['departments']['name'] as String
          : 'Unknown',
      purchaseDate: row['acquisition_date'] != null
          ? DateTime.parse(row['acquisition_date'] as String)
          : DateTime.now(),
      purchaseCost: row['acquisition_cost'] != null
          ? double.parse(row['acquisition_cost'].toString())
          : 0.0,
      warrantyExpiry: row['warranty_expiry_date'] != null
          ? DateTime.parse(row['warranty_expiry_date'] as String)
          : null,
      condition: DatabaseEnumMappers.assetConditionFromDatabase(
        row['condition'] as String,
      ),
      status: DatabaseEnumMappers.assetStatusFromDatabase(
        row['status'] as String,
      ),
      isShared: row['is_shared'] as bool? ?? false,
      isBookable: row['is_bookable'] as bool? ?? false,
      photoUrl: row['photo_path'] as String?,
    );
  }
}
