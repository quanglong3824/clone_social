import 'package:flutter/material.dart';
import '../themes/app_theme.dart';

/// Base shimmer loading widget with customizable dimensions
class ShimmerLoading extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerLoading({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = AppTheme.radiusSm,
  });

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? AppTheme.surfaceDark : AppTheme.backgroundLight;
    final highlightColor = isDark 
        ? AppTheme.dividerDark 
        : AppTheme.dividerLight.withOpacity(0.5);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment(_animation.value - 1, 0),
              end: Alignment(_animation.value + 1, 0),
              colors: [
                baseColor,
                highlightColor,
                baseColor,
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
    );
  }
}


/// Shimmer placeholder for post items in feed
class PostShimmer extends StatelessWidget {
  const PostShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingLg),
      margin: const EdgeInsets.only(bottom: AppTheme.spacingSm),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppTheme.dividerDark : AppTheme.dividerLight,
            width: 0.5,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Avatar + Name + Time
          Row(
            children: [
              const ShimmerLoading(
                width: 40,
                height: 40,
                borderRadius: 20,
              ),
              const SizedBox(width: AppTheme.spacingMd),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  ShimmerLoading(width: 120, height: 14),
                  SizedBox(height: AppTheme.spacingXs),
                  ShimmerLoading(width: 80, height: 12),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingMd),
          // Content text
          const ShimmerLoading(width: double.infinity, height: 14),
          const SizedBox(height: AppTheme.spacingXs),
          const ShimmerLoading(width: 200, height: 14),
          const SizedBox(height: AppTheme.spacingMd),
          // Image placeholder
          const ShimmerLoading(
            width: double.infinity,
            height: 200,
            borderRadius: AppTheme.radiusSm,
          ),
          const SizedBox(height: AppTheme.spacingMd),
          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              ShimmerLoading(width: 60, height: 20),
              ShimmerLoading(width: 60, height: 20),
              ShimmerLoading(width: 60, height: 20),
            ],
          ),
        ],
      ),
    );
  }
}

/// Shimmer placeholder for story items
class StoryShimmer extends StatelessWidget {
  const StoryShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      margin: const EdgeInsets.only(right: AppTheme.spacingSm),
      child: Column(
        children: const [
          ShimmerLoading(
            width: 64,
            height: 64,
            borderRadius: 32,
          ),
          SizedBox(height: AppTheme.spacingXs),
          ShimmerLoading(width: 60, height: 12),
        ],
      ),
    );
  }
}

/// Shimmer placeholder for chat list items
class ChatShimmer extends StatelessWidget {
  const ChatShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingLg,
        vertical: AppTheme.spacingMd,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
      ),
      child: Row(
        children: [
          const ShimmerLoading(
            width: 56,
            height: 56,
            borderRadius: 28,
          ),
          const SizedBox(width: AppTheme.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                ShimmerLoading(width: 140, height: 16),
                SizedBox(height: AppTheme.spacingXs),
                ShimmerLoading(width: 200, height: 14),
              ],
            ),
          ),
          const ShimmerLoading(width: 40, height: 12),
        ],
      ),
    );
  }
}

/// Shimmer placeholder for product items in marketplace
class ProductShimmer extends StatelessWidget {
  const ProductShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        border: Border.all(
          color: isDark ? AppTheme.dividerDark : AppTheme.dividerLight,
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product image
          const ShimmerLoading(
            width: double.infinity,
            height: 150,
            borderRadius: AppTheme.radiusSm,
          ),
          Padding(
            padding: const EdgeInsets.all(AppTheme.spacingSm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                // Price
                ShimmerLoading(width: 80, height: 18),
                SizedBox(height: AppTheme.spacingXs),
                // Title
                ShimmerLoading(width: double.infinity, height: 14),
                SizedBox(height: AppTheme.spacingXs),
                // Location
                ShimmerLoading(width: 100, height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
