import 'package:flutter/material.dart';
import '../themes/app_theme.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? elevation;
  final VoidCallback? onTap;
  final double? borderRadius;
  final Color? backgroundColor;
  final Border? border;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.elevation,
    this.onTap,
    this.borderRadius,
    this.backgroundColor,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = backgroundColor ?? 
        (isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight);
    final radius = borderRadius ?? AppTheme.radiusSm;
    final cardElevation = elevation ?? 0.0;

    Widget cardContent = Container(
      padding: padding ?? const EdgeInsets.all(AppTheme.spacingLg),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(radius),
        border: border ?? Border.all(
          color: isDark ? AppTheme.dividerDark : AppTheme.dividerLight,
          width: 0.5,
        ),
        boxShadow: cardElevation > 0
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
                  blurRadius: cardElevation * 2,
                  offset: Offset(0, cardElevation),
                ),
              ]
            : null,
      ),
      child: child,
    );

    if (onTap != null) {
      cardContent = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(radius),
          child: cardContent,
        ),
      );
    }

    if (margin != null) {
      cardContent = Padding(
        padding: margin!,
        child: cardContent,
      );
    }

    return cardContent;
  }
}
