import 'package:flutter/material.dart';
import '../themes/app_theme.dart';
import '../animations/app_animations.dart';

class AppCard extends StatefulWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? elevation;
  final VoidCallback? onTap;
  final double? borderRadius;
  final Color? backgroundColor;
  final Border? border;
  final bool enableAnimation;

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
    this.enableAnimation = true,
  });

  @override
  State<AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<AppCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppDurations.fast,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _elevationAnimation = Tween<double>(begin: 0.0, end: 4.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onTap != null && widget.enableAnimation) {
      setState(() => _isPressed = true);
      _controller.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.enableAnimation) {
      setState(() => _isPressed = false);
      _controller.reverse();
    }
  }

  void _onTapCancel() {
    if (widget.enableAnimation) {
      setState(() => _isPressed = false);
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = widget.backgroundColor ?? 
        (isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight);
    final radius = widget.borderRadius ?? AppTheme.radiusSm;
    final cardElevation = widget.elevation ?? 0.0;

    Widget cardContent = AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final totalElevation = cardElevation + _elevationAnimation.value;
        return Transform.scale(
          scale: widget.enableAnimation ? _scaleAnimation.value : 1.0,
          child: AnimatedContainer(
            duration: AppDurations.fast,
            padding: widget.padding ?? const EdgeInsets.all(AppTheme.spacingLg),
            decoration: BoxDecoration(
              color: _isPressed ? bgColor.withOpacity(0.95) : bgColor,
              borderRadius: BorderRadius.circular(radius),
              border: widget.border ?? Border.all(
                color: isDark ? AppTheme.dividerDark : AppTheme.dividerLight,
                width: 0.5,
              ),
              boxShadow: totalElevation > 0
                  ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
                        blurRadius: totalElevation * 2,
                        offset: Offset(0, totalElevation),
                      ),
                    ]
                  : null,
            ),
            child: child,
          ),
        );
      },
      child: widget.child,
    );

    if (widget.onTap != null) {
      cardContent = GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        onTap: widget.onTap,
        child: cardContent,
      );
    }

    if (widget.margin != null) {
      cardContent = Padding(
        padding: widget.margin!,
        child: cardContent,
      );
    }

    return cardContent;
  }
}
