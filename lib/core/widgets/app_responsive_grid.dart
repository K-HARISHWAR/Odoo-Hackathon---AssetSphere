import 'package:flutter/material.dart';
import '../constants/app_sizes.dart';

class AppResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double minItemWidth;
  final double spacing;

  const AppResponsiveGrid({
    super.key,
    required this.children,
    this.minItemWidth = 300,
    this.spacing = AppSizes.spacingLg,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = (constraints.maxWidth / minItemWidth)
            .floor()
            .clamp(1, 4);

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
            childAspectRatio:
                1, // Will be overridden if you use Wrap or other layouts, but GridView requires it or extent.
            // Actually, for arbitrary height items, Wrap is better.
          ),
          itemCount: children.length,
          itemBuilder: (context, index) => children[index],
        );
      },
    );
  }
}

class AppResponsiveWrap extends StatelessWidget {
  final List<Widget> children;
  final double minItemWidth;
  final double spacing;

  const AppResponsiveWrap({
    super.key,
    required this.children,
    this.minItemWidth = 300,
    this.spacing = AppSizes.spacingLg,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final columns = (availableWidth / minItemWidth).floor().clamp(1, 4);
        final itemWidth =
            (availableWidth - (spacing * (columns - 1))) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: children
              .map((child) => SizedBox(width: itemWidth, child: child))
              .toList(),
        );
      },
    );
  }
}
