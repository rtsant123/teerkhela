import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../utils/app_theme.dart';

/// Professional shimmer loading widgets for the app
/// Uses AppTheme colors for consistent look

/// Base shimmer widget with app theme colors
class AppShimmer extends StatelessWidget {
  final Widget child;
  final bool enabled;

  const AppShimmer({
    Key? key,
    required this.child,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child;

    return Shimmer.fromColors(
      baseColor: AppTheme.surfaceVariant,
      highlightColor: Colors.white,
      period: const Duration(milliseconds: 1200),
      child: child,
    );
  }
}

/// Generic card-shaped shimmer placeholder
class ShimmerCard extends StatelessWidget {
  final double? height;
  final double? width;
  final EdgeInsets? margin;
  final EdgeInsets? padding;

  const ShimmerCard({
    Key? key,
    this.height,
    this.width,
    this.margin,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      height: height ?? size.width * 0.3,
      width: width,
      margin: margin ?? EdgeInsets.only(bottom: size.width * 0.04),
      padding: padding ?? EdgeInsets.all(size.width * 0.04),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        boxShadow: AppTheme.cardShadow,
      ),
      child: AppShimmer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header line
            Container(
              width: size.width * 0.4,
              height: size.width * 0.04,
              decoration: BoxDecoration(
                color: AppTheme.surfaceVariant,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            SizedBox(height: AppTheme.space12),
            // Content lines
            Container(
              width: double.infinity,
              height: size.width * 0.03,
              decoration: BoxDecoration(
                color: AppTheme.surfaceVariant,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            SizedBox(height: AppTheme.space8),
            Container(
              width: size.width * 0.6,
              height: size.width * 0.03,
              decoration: BoxDecoration(
                color: AppTheme.surfaceVariant,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// List of shimmer cards
class ShimmerList extends StatelessWidget {
  final int itemCount;
  final double? itemHeight;
  final EdgeInsets? padding;

  const ShimmerList({
    Key? key,
    this.itemCount = 5,
    this.itemHeight,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return ListView.builder(
      padding: padding ?? EdgeInsets.all(size.width * 0.04),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return ShimmerCard(height: itemHeight);
      },
    );
  }
}

/// Shimmer placeholder for result cards on home screen
class ShimmerResultCard extends StatelessWidget {
  final Size size;

  const ShimmerResultCard({
    Key? key,
    required this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cardPadding = size.width * 0.035;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        boxShadow: AppTheme.cardShadow,
      ),
      child: AppShimmer(
        child: Padding(
          padding: EdgeInsets.all(cardPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Game Name
              Row(
                children: [
                  Container(
                    width: 3,
                    height: size.width * 0.045,
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  SizedBox(width: AppTheme.space8),
                  Container(
                    width: size.width * 0.25,
                    height: size.width * 0.036,
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),

              // FR & SR in Row
              Row(
                children: [
                  // FR Box
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        vertical: size.width * 0.025,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: size.width * 0.08,
                            height: size.width * 0.025,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          SizedBox(height: AppTheme.space4),
                          Container(
                            width: size.width * 0.1,
                            height: size.width * 0.06,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: AppTheme.space8),
                  // SR Box
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        vertical: size.width * 0.025,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: size.width * 0.08,
                            height: size.width * 0.025,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          SizedBox(height: AppTheme.space4),
                          Container(
                            width: size.width * 0.1,
                            height: size.width * 0.06,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // View History Button
              Container(
                width: double.infinity,
                constraints: BoxConstraints(
                  minHeight: size.width * 0.08,
                  maxHeight: size.width * 0.1,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Shimmer placeholder for prediction cards
class ShimmerPredictionCard extends StatelessWidget {
  final Size size;

  const ShimmerPredictionCard({
    Key? key,
    required this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cardPadding = size.width * 0.04;

    return Container(
      margin: EdgeInsets.only(bottom: size.width * 0.04),
      decoration: AppTheme.elevatedCard,
      child: AppShimmer(
        child: Padding(
          padding: EdgeInsets.all(cardPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with title and confidence badge
              Row(
                children: [
                  Expanded(
                    child: Container(
                      width: size.width * 0.35,
                      height: size.width * 0.045,
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  Container(
                    width: size.width * 0.15,
                    height: size.width * 0.06,
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppTheme.space16),

              // FR Section Label
              Container(
                width: size.width * 0.4,
                height: size.width * 0.033,
                decoration: BoxDecoration(
                  color: AppTheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              SizedBox(height: AppTheme.space8),

              // FR Number chips
              Wrap(
                spacing: AppTheme.space8,
                runSpacing: AppTheme.space8,
                children: List.generate(5, (index) {
                  return Container(
                    width: size.width * 0.12,
                    height: size.width * 0.09,
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                    ),
                  );
                }),
              ),
              SizedBox(height: AppTheme.space16),

              // SR Section Label
              Container(
                width: size.width * 0.45,
                height: size.width * 0.033,
                decoration: BoxDecoration(
                  color: AppTheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              SizedBox(height: AppTheme.space8),

              // SR Number chips
              Wrap(
                spacing: AppTheme.space8,
                runSpacing: AppTheme.space8,
                children: List.generate(5, (index) {
                  return Container(
                    width: size.width * 0.12,
                    height: size.width * 0.09,
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                    ),
                  );
                }),
              ),
              SizedBox(height: AppTheme.space16),

              // Analysis Box
              Container(
                padding: EdgeInsets.all(cardPadding * 0.75),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: size.width * 0.25,
                      height: size.width * 0.033,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    SizedBox(height: AppTheme.space8),
                    Container(
                      width: double.infinity,
                      height: size.width * 0.032,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    SizedBox(height: AppTheme.space4),
                    Container(
                      width: size.width * 0.7,
                      height: size.width * 0.032,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Shimmer for forum post cards
class ShimmerForumCard extends StatelessWidget {
  final Size size;

  const ShimmerForumCard({
    Key? key,
    required this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: size.width * 0.04),
      padding: EdgeInsets.all(size.width * 0.04),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        boxShadow: AppTheme.cardShadow,
      ),
      child: AppShimmer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Avatar and user info
            Row(
              children: [
                Container(
                  width: size.width * 0.1,
                  height: size.width * 0.1,
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceVariant,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: AppTheme.space12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: size.width * 0.3,
                        height: size.width * 0.035,
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      SizedBox(height: AppTheme.space8),
                      Container(
                        width: size.width * 0.2,
                        height: size.width * 0.03,
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: AppTheme.space16),

            // Number chips placeholder
            Container(
              width: double.infinity,
              height: size.width * 0.1,
              decoration: BoxDecoration(
                color: AppTheme.surfaceVariant,
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              ),
            ),
            SizedBox(height: AppTheme.space12),

            // Description lines
            Container(
              width: double.infinity,
              height: size.width * 0.03,
              decoration: BoxDecoration(
                color: AppTheme.surfaceVariant,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            SizedBox(height: AppTheme.space8),
            Container(
              width: size.width * 0.6,
              height: size.width * 0.03,
              decoration: BoxDecoration(
                color: AppTheme.surfaceVariant,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shimmer for common numbers card
class ShimmerCommonNumbersCard extends StatelessWidget {
  final Size size;

  const ShimmerCommonNumbersCard({
    Key? key,
    required this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppTheme.space12),
      decoration: AppTheme.cardDecoration,
      child: AppShimmer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section header
            Row(
              children: [
                Container(
                  width: size.width * 0.08,
                  height: size.width * 0.08,
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                SizedBox(width: AppTheme.space8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: size.width * 0.35,
                        height: size.width * 0.042,
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      SizedBox(height: AppTheme.space4),
                      Container(
                        width: size.width * 0.25,
                        height: size.width * 0.03,
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: AppTheme.space12),

            // Number chips grid
            Wrap(
              spacing: AppTheme.space8,
              runSpacing: AppTheme.space8,
              children: List.generate(6, (index) {
                return Container(
                  width: (size.width - AppTheme.space12 * 2 - AppTheme.space8 * 2) / 3,
                  height: size.width * 0.15,
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
