import 'package:flutter/material.dart';
import 'package:assetsphere/core/constants/app_sizes.dart';

class AuthFormContainer extends StatelessWidget {
  final Widget child;

  const AuthFormContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        final cardWidth = isMobile ? constraints.maxWidth * 0.9 : 420.0;

        return Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              vertical: AppSizes.spacingXl,
              horizontal: AppSizes.spacingLg,
            ),
            child: SizedBox(
              width: cardWidth,
              child: isMobile
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: AppSizes.spacingXl),
                      child: child,
                    )
                  : Card(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSizes.spacingXl),
                        child: child,
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }
}
