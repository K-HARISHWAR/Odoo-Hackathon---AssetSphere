import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../data/datasources/dashboard_mock_datasource.dart';
import '../../data/repositories/dashboard_repository_impl.dart';
import '../../domain/usecases/get_dashboard_data_usecase.dart';
import '../controllers/dashboard_controller.dart';
import '../widgets/kpi_card.dart';
import '../widgets/quick_action_button.dart';
import '../widgets/recent_activity_item.dart';
import '../widgets/asset_status_chart.dart';

class HomePage extends StatefulWidget {
  final VoidCallback? onRegisterAsset;
  final VoidCallback? onViewDirectory;
  final VoidCallback? onBookResource;
  final VoidCallback? onMaintenanceRequest;
  final Function(String)? onSearch;

  const HomePage({
    super.key,
    this.onRegisterAsset,
    this.onViewDirectory,
    this.onBookResource,
    this.onMaintenanceRequest,
    this.onSearch,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final DashboardController _controller;

  @override
  void initState() {
    super.initState();
    // Manual Dependency Injection (as per Developer 2 constraints: no GetIt)
    final dataSource = DashboardMockDataSource();
    final repository = DashboardRepositoryImpl(dataSource: dataSource);
    final useCase = GetDashboardDataUseCase(repository);

    _controller = DashboardController(getDashboardData: useCase);
    _controller.loadDashboardData();
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
      backgroundColor: theme.colorScheme.surface.withAlpha(240),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        title: Text(
          AppStrings.appName,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        actions: [
          _buildSearchField(),
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Notifications module will be implemented by Developer 1',
                  ),
                ),
              );
            },
            icon: Badge(
              isLabelVisible:
                  false, // Set to false to remove fake notification count
              label: const Text('0'),
              child: Icon(
                Icons.notifications_outlined,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: AppSizes.spacingMd),
          const CircleAvatar(
            radius: 18,
            backgroundColor: Colors.blueAccent,
            child: Text(
              'AD',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
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

          return SingleChildScrollView(
            child: Center(
              child: Container(
                constraints: const BoxConstraints(
                  maxWidth: AppSizes.maxDesktopContentWidth,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.spacingLg,
                  vertical: AppSizes.spacingLg,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildWelcomeHeader(theme),
                    const SizedBox(height: AppSizes.spacingXl),
                    _buildKPIGrid(),
                    const SizedBox(height: AppSizes.spacingXl),
                    _buildMainContent(theme),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      width: 250,
      height: 40,
      margin: const EdgeInsets.only(right: AppSizes.spacingMd),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withAlpha(100),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      child: TextField(
        onSubmitted: (value) => widget.onSearch?.call(value),
        decoration: const InputDecoration(
          hintText: 'Search assets...',
          hintStyle: TextStyle(fontSize: 13),
          prefixIcon: Icon(Icons.search, size: 18),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 10),
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Good Morning, Admin',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Overview of your enterprise assets and resources.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildKPIGrid() {
    final kpiMetadata = [
      {'icon': Icons.inventory_2_outlined, 'color': Colors.blue},
      {'icon': Icons.assignment_ind_outlined, 'color': Colors.green},
      {'icon': Icons.build_circle_outlined, 'color': Colors.orange},
      {'icon': Icons.swap_horiz_outlined, 'color': Colors.purple},
      {'icon': Icons.event_available_outlined, 'color': Colors.teal},
      {'icon': Icons.bookmark_outline, 'color': Colors.indigo},
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = constraints.maxWidth > 1000
            ? 3
            : (constraints.maxWidth > 600 ? 2 : 1);

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: AppSizes.spacingLg,
            mainAxisSpacing: AppSizes.spacingLg,
            mainAxisExtent: 160,
          ),
          itemCount: _controller.kpis.length,
          itemBuilder: (context, index) {
            final kpi = _controller.kpis[index];
            final meta = kpiMetadata[index % kpiMetadata.length];
            return TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: Duration(milliseconds: 400 + (index * 100)),
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 20 * (1 - value)),
                    child: child,
                  ),
                );
              },
              child: KPICard(
                title: kpi.title,
                value: kpi.value,
                trend: kpi.trend,
                icon: meta['icon'] as IconData,
                color: meta['color'] as Color,
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMainContent(ThemeData theme) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 900) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 2, child: _buildDashboardBody(theme)),
              const SizedBox(width: AppSizes.spacingXl),
              Expanded(child: _buildDashboardSide(theme)),
            ],
          );
        } else {
          return Column(
            children: [
              _buildQuickActions(theme),
              const SizedBox(height: AppSizes.spacingLg),
              _buildDashboardSide(theme),
              const SizedBox(height: AppSizes.spacingLg),
              _buildRecentActivity(theme),
            ],
          );
        }
      },
    );
  }

  Widget _buildDashboardBody(ThemeData theme) {
    return Column(
      children: [
        _buildQuickActions(theme),
        const SizedBox(height: AppSizes.spacingXl),
        _buildRecentActivity(theme),
      ],
    );
  }

  Widget _buildDashboardSide(ThemeData theme) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.spacingLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Asset Distribution',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSizes.spacingLg),
              AssetStatusChart(summary: _controller.statusSummary),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Operations',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSizes.spacingMd),
        Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: Material(
            color: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.spacingLg),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  QuickActionButton(
                    icon: Icons.add_circle_outline,
                    label: 'Register',
                    onTap: () => widget.onRegisterAsset?.call(),
                  ),
                  QuickActionButton(
                    icon: Icons.inventory_outlined,
                    label: 'Inventory',
                    onTap: () => widget.onViewDirectory?.call(),
                  ),
                  QuickActionButton(
                    icon: Icons.calendar_today_outlined,
                    label: 'Booking',
                    onTap: () => widget.onBookResource?.call(),
                  ),
                  QuickActionButton(
                    icon: Icons.settings_suggest_outlined,
                    label: 'Service',
                    onTap: () => widget.onMaintenanceRequest?.call(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivity(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Activities',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(onPressed: () {}, child: const Text('See all log')),
          ],
        ),
        const SizedBox(height: AppSizes.spacingMd),
        Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: Material(
            color: Colors.transparent,
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _controller.activities.length,
              separatorBuilder: (context, index) =>
                  Divider(height: 1, color: theme.colorScheme.outlineVariant),
              itemBuilder: (context, index) {
                return TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: Duration(milliseconds: 600 + (index * 150)),
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(30 * (1 - value), 0),
                        child: child,
                      ),
                    );
                  },
                  child: RecentActivityItem(
                    activity: _controller.activities[index],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
