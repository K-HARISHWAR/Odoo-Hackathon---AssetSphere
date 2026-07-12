import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../domain/entities/asset.dart';
import '../../domain/entities/asset_status.dart';
import '../../data/datasources/assets_mock_datasource.dart';
import '../../data/repositories/asset_repository_impl.dart';
import '../../domain/usecases/get_assets_usecase.dart';
import '../controllers/asset_directory_controller.dart';
import 'asset_details_page.dart';

class AssetDirectoryPage extends StatefulWidget {
  final String? initialSearchQuery;
  final AssetDirectoryController? controller;
  
  const AssetDirectoryPage({
    super.key, 
    this.initialSearchQuery,
    this.controller,
  });

  @override
  State<AssetDirectoryPage> createState() => _AssetDirectoryPageState();
}

class _AssetDirectoryPageState extends State<AssetDirectoryPage> {
  late final AssetDirectoryController _controller;
  bool _ownsController = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _controller = widget.controller!;
    } else {
      _ownsController = true;
      final dataSource = AssetsMockDataSource();
      final repository = AssetRepositoryImpl(dataSource: dataSource);
      final useCase = GetAssetsUseCase(repository);
      _controller = AssetDirectoryController(getAssets: useCase);
    }

    if (widget.initialSearchQuery != null) {
      _controller.setSearchQuery(widget.initialSearchQuery!);
    }

    if (_controller.assets.isEmpty && !_controller.isLoading) {
      _controller.loadAssets();
    }
  }

  @override
  void dispose() {
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface.withAlpha(245),
      appBar: AppBar(
        toolbarHeight: 70,
        leadingWidth: 70,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Center(
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 20,
                color: Colors.white,
              ),
              style: IconButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: const Text(
          'Asset Directory',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        surfaceTintColor: Colors.transparent,
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(
            height: 1,
            color: theme.colorScheme.outlineVariant.withAlpha(100),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => _controller.loadAssets(),
            icon: const Icon(Icons.refresh_rounded),
          ),
          const SizedBox(width: AppSizes.spacingMd),
        ],
      ),
      body: Column(
        children: [
          _buildFilterBar(theme),
          Expanded(
            child: ListenableBuilder(
              listenable: _controller,
              builder: (context, _) {
                if (_controller.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (_controller.assets.isEmpty) {
                  return _buildEmptyState(theme);
                }

                return LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth > 900) {
                      return _buildDesktopTable(context, theme);
                    } else if (constraints.maxWidth > 600) {
                      return _buildTabletGrid(context);
                    } else {
                      return _buildMobileList(context);
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.spacingLg),
      color: theme.colorScheme.surface,
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: TextFormField(
              initialValue: widget.initialSearchQuery,
              decoration: InputDecoration(
                hintText: 'Search by tag, name or serial...',
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest.withAlpha(
                  100,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.spacingMd,
                ),
              ),
              onChanged: _controller.setSearchQuery,
            ),
          ),
          const SizedBox(width: AppSizes.spacingMd),
          Expanded(
            child: DropdownButtonFormField<AssetStatus>(
              decoration: InputDecoration(
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest.withAlpha(
                  100,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.spacingMd,
                ),
              ),
              hint: const Text('Status'),
              items: [
                const DropdownMenuItem(value: null, child: Text('All Status')),
                ...AssetStatus.values.map(
                  (s) => DropdownMenuItem(value: s, child: Text(s.displayName)),
                ),
              ],
              onChanged: _controller.setStatusFilter,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 80,
            color: theme.colorScheme.outlineVariant,
          ),
          const SizedBox(height: AppSizes.spacingMd),
          Text('No assets found', style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or filters',
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopTable(BuildContext context, ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.spacingLg),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(
              theme.colorScheme.surfaceContainerHighest.withAlpha(50),
            ),
            showCheckboxColumn: false,
            columns: const [
              DataColumn(
                label: Text(
                  'ASSET TAG',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
              DataColumn(
                label: Text(
                  'ASSET NAME',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
              DataColumn(
                label: Text(
                  'CATEGORY',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
              DataColumn(
                label: Text(
                  'DEPARTMENT',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
              DataColumn(
                label: Text(
                  'STATUS',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
              DataColumn(
                label: Text(
                  'ACTIONS',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ],
            rows: _controller.assets
                .map(
                  (asset) => DataRow(
                    onSelectChanged: (_) => _navigateToDetails(asset),
                    cells: [
                      DataCell(
                        Text(
                          asset.assetTag,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                      DataCell(Text(asset.name)),
                      DataCell(Text(asset.category)),
                      DataCell(Text(asset.department)),
                      DataCell(_StatusBadge(status: asset.status)),
                      DataCell(
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_forward_rounded,
                            size: 20,
                          ),
                          onPressed: () => _navigateToDetails(asset),
                        ),
                      ),
                    ],
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildTabletGrid(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(AppSizes.spacingLg),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSizes.spacingLg,
        mainAxisSpacing: AppSizes.spacingLg,
        mainAxisExtent: 130,
      ),
      itemCount: _controller.assets.length,
      itemBuilder: (context, index) => _AssetModernCard(
        asset: _controller.assets[index],
        onTap: () => _navigateToDetails(_controller.assets[index]),
      ),
    );
  }

  Widget _buildMobileList(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSizes.spacingLg),
      itemCount: _controller.assets.length,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: AppSizes.spacingMd),
        child: _AssetModernCard(
          asset: _controller.assets[index],
          onTap: () => _navigateToDetails(_controller.assets[index]),
        ),
      ),
    );
  }

  void _navigateToDetails(Asset asset) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AssetDetailsPage(assetId: asset.id),
      ),
    );
  }
}

class _AssetModernCard extends StatelessWidget {
  final Asset asset;
  final VoidCallback onTap;

  const _AssetModernCard({required this.asset, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.spacingLg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Hero(
                      tag: 'tag-${asset.id}',
                      child: Material(
                        color: Colors.transparent,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.withAlpha(20),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            asset.assetTag,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ),
                    ),
                    _StatusBadge(status: asset.status),
                  ],
                ),
                const SizedBox(height: AppSizes.spacingMd),
                Text(
                  asset.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.category_outlined,
                      size: 14,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(asset.category, style: theme.textTheme.bodySmall),
                    const SizedBox(width: 12),
                    Icon(
                      Icons.business_outlined,
                      size: 14,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(asset.department, style: theme.textTheme.bodySmall),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final AssetStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _getColor().withAlpha(30),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: _getColor(),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            status.displayName,
            style: TextStyle(
              color: _getColor(),
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Color _getColor() {
    switch (status) {
      case AssetStatus.available:
        return Colors.green;
      case AssetStatus.allocated:
        return Colors.blue;
      case AssetStatus.maintenance:
        return Colors.orange;
      case AssetStatus.lost:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
