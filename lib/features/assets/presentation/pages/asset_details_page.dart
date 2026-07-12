import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../domain/entities/asset_status.dart';
import '../../data/repositories/asset_repository_impl.dart';
import '../../data/datasources/assets_mock_datasource.dart';
import '../controllers/asset_details_controller.dart';

class AssetDetailsPage extends StatefulWidget {
  final String assetId;

  const AssetDetailsPage({super.key, required this.assetId});

  @override
  State<AssetDetailsPage> createState() => _AssetDetailsPageState();
}

class _AssetDetailsPageState extends State<AssetDetailsPage> {
  late final AssetDetailsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AssetDetailsController(
      repository: AssetRepositoryImpl(dataSource: AssetsMockDataSource()),
    );
    _controller.loadAssetDetails(widget.assetId);
  }

  @override
  void dispose() {
    _controller.dispose();
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
          'Asset Profile',
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
            onPressed: () {},
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit',
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.share_outlined),
            tooltip: 'Share',
          ),
          const SizedBox(width: AppSizes.spacingMd),
        ],
      ),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          if (_controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          final asset = _controller.asset;
          if (asset == null) {
            return const Center(child: Text('Asset not found'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.spacingLg),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTopBanner(theme, asset),
                    const SizedBox(height: AppSizes.spacingLg),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        if (constraints.maxWidth > 750) {
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 3,
                                child: _buildInfoGrid(theme, asset),
                              ),
                              const SizedBox(width: AppSizes.spacingLg),
                              Expanded(
                                flex: 2,
                                child: _buildTimelineSide(theme),
                              ),
                            ],
                          );
                        } else {
                          return Column(
                            children: [
                              _buildInfoGrid(theme, asset),
                              const SizedBox(height: AppSizes.spacingLg),
                              _buildTimelineSide(theme),
                            ],
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTopBanner(ThemeData theme, dynamic asset) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.spacingLg),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withAlpha(100),
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            ),
            child: Icon(
              Icons.devices_other,
              size: 48,
              color: theme.colorScheme.primary.withAlpha(150),
            ),
          ),
          const SizedBox(width: AppSizes.spacingLg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _StatusBadge(status: asset.status),
                    const SizedBox(width: 8),
                    Hero(
                      tag: 'tag-${asset.id}',
                      child: Material(
                        color: Colors.transparent,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer.withAlpha(
                              100,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            asset.assetTag,
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  asset.name,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  asset.category,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoGrid(ThemeData theme, dynamic asset) {
    return Column(
      children: [
        _buildInfoCard(
          theme: theme,
          title: 'Deployment Details',
          icon: Icons.location_on_outlined,
          items: [
            {'label': 'Location', 'value': asset.location},
            {'label': 'Department', 'value': asset.department},
            {
              'label': 'Serial Number',
              'value': asset.serialNumber ?? 'Not assigned',
            },
          ],
        ),
        const SizedBox(height: AppSizes.spacingLg),
        _buildInfoCard(
          theme: theme,
          title: 'Lifecycle & Value',
          icon: Icons.history_edu_outlined,
          items: [
            {
              'label': 'Purchase Date',
              'value':
                  '${asset.purchaseDate.day}/${asset.purchaseDate.month}/${asset.purchaseDate.year}',
            },
            {
              'label': 'Purchase Cost',
              'value': '₹${asset.purchaseCost.toStringAsFixed(2)}',
            },
            {
              'label': 'Warranty Exp.',
              'value': asset.warrantyExpiry != null
                  ? '${asset.warrantyExpiry!.day}/${asset.warrantyExpiry!.month}/${asset.warrantyExpiry!.year}'
                  : 'No warranty',
            },
            {
              'label': 'Current Condition',
              'value': asset.condition.name.toUpperCase(),
            },
          ],
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required ThemeData theme,
    required String title,
    required IconData icon,
    required List<Map<String, String>> items,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.spacingLg),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Divider(height: 32),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    item['label']!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    item['value']!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineSide(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.spacingLg),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Activity Timeline',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSizes.spacingLg),
          ..._controller.history.map(
            (h) => _TimelineItem(
              title: h.action,
              subtitle: h.description,
              time:
                  '${h.timestamp.day}/${h.timestamp.month} ${h.timestamp.hour}:${h.timestamp.minute}',
              isLast: _controller.history.last == h,
            ),
          ),
        ],
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
      child: Text(
        status.displayName.toUpperCase(),
        style: TextStyle(
          color: _getColor(),
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
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

class _TimelineItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final String time;
  final bool isLast;

  const _TimelineItem({
    required this.title,
    required this.subtitle,
    required this.time,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return IntrinsicHeight(
      child: Row(
        children: [
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: theme.colorScheme.primaryContainer,
                    width: 2,
                  ),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: VerticalDivider(
                    thickness: 1.5,
                    color: theme.colorScheme.outlineVariant,
                  ),
                ),
            ],
          ),
          const SizedBox(width: AppSizes.spacingMd),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppSizes.spacingLg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(subtitle, style: theme.textTheme.bodySmall),
                  Text(
                    time,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
