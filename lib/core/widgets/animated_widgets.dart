import 'package:flutter/material.dart';
import '../animations/app_animations.dart';
import '../themes/app_theme.dart';

/// Animated button with scale effect
class AnimatedButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final EdgeInsets? padding;
  final double borderRadius;
  final bool isLoading;
  final bool isFullWidth;

  const AnimatedButton({
    super.key,
    required this.child,
    this.onPressed,
    this.onLongPress,
    this.backgroundColor,
    this.foregroundColor,
    this.padding,
    this.borderRadius = AppTheme.radiusSm,
    this.isLoading = false,
    this.isFullWidth = false,
  });

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppDurations.fast,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      _controller.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = widget.backgroundColor ?? AppTheme.primaryBlue;
    final fgColor = widget.foregroundColor ?? Colors.white;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.isLoading ? null : widget.onPressed,
      onLongPress: widget.isLoading ? null : widget.onLongPress,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedContainer(
          duration: AppDurations.fast,
          width: widget.isFullWidth ? double.infinity : null,
          padding: widget.padding ??
              const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: widget.onPressed != null ? bgColor : bgColor.withOpacity(0.5),
            borderRadius: BorderRadius.circular(widget.borderRadius),
            boxShadow: widget.onPressed != null
                ? [
                    BoxShadow(
                      color: bgColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: widget.isLoading
              ? SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(fgColor),
                  ),
                )
              : DefaultTextStyle(
                  style: TextStyle(
                    color: fgColor,
                    fontWeight: FontWeight.w600,
                  ),
                  child: widget.child,
                ),
        ),
      ),
    );
  }
}

/// Animated icon button with ripple effect
class AnimatedIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? color;
  final Color? backgroundColor;
  final double size;
  final String? tooltip;
  final bool showBadge;
  final int badgeCount;

  const AnimatedIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.color,
    this.backgroundColor,
    this.size = 24,
    this.tooltip,
    this.showBadge = false,
    this.badgeCount = 0,
  });

  @override
  State<AnimatedIconButton> createState() => _AnimatedIconButtonState();
}

class _AnimatedIconButtonState extends State<AnimatedIconButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppDurations.fast,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.85).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
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
    final iconColor = widget.color ??
        (isDark ? AppTheme.textDark : AppTheme.textPrimary);

    Widget button = GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: widget.onPressed,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            shape: BoxShape.circle,
          ),
          child: Icon(
            widget.icon,
            size: widget.size,
            color: iconColor,
          ),
        ),
      ),
    );

    if (widget.showBadge && widget.badgeCount > 0) {
      button = Stack(
        clipBehavior: Clip.none,
        children: [
          button,
          Positioned(
            right: 0,
            top: 0,
            child: ScaleIn(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.error,
                  borderRadius: BorderRadius.circular(10),
                ),
                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                child: Text(
                  widget.badgeCount > 99 ? '99+' : '${widget.badgeCount}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      );
    }

    if (widget.tooltip != null) {
      return Tooltip(message: widget.tooltip!, child: button);
    }

    return button;
  }
}

/// Animated card with hover/tap effects
class AnimatedCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double borderRadius;
  final Color? backgroundColor;
  final bool enableHover;

  const AnimatedCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.borderRadius = AppTheme.radiusSm,
    this.backgroundColor,
    this.enableHover = true,
  });

  @override
  State<AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<AnimatedCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;
  bool _isHovered = false;

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
    _elevationAnimation = Tween<double>(begin: 0, end: 8).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
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
    final bgColor = widget.backgroundColor ??
        (isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight);

    return MouseRegion(
      onEnter: widget.enableHover ? (_) => setState(() => _isHovered = true) : null,
      onExit: widget.enableHover ? (_) => setState(() => _isHovered = false) : null,
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) => _controller.reverse(),
        onTapCancel: () => _controller.reverse(),
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: AnimatedContainer(
                duration: AppDurations.fast,
                margin: widget.margin,
                padding: widget.padding ?? const EdgeInsets.all(AppTheme.spacingLg),
                decoration: BoxDecoration(
                  color: _isHovered ? bgColor.withOpacity(0.95) : bgColor,
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  border: Border.all(
                    color: isDark ? AppTheme.dividerDark : AppTheme.dividerLight,
                    width: 0.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(
                        isDark ? 0.3 : 0.08 + (_elevationAnimation.value * 0.01),
                      ),
                      blurRadius: _elevationAnimation.value,
                      offset: Offset(0, _elevationAnimation.value / 2),
                    ),
                  ],
                ),
                child: child,
              ),
            );
          },
          child: widget.child,
        ),
      ),
    );
  }
}

/// Animated avatar with loading state
class AnimatedAvatar extends StatelessWidget {
  final String? imageUrl;
  final double radius;
  final IconData placeholderIcon;
  final VoidCallback? onTap;
  final bool isOnline;
  final bool showOnlineIndicator;

  const AnimatedAvatar({
    super.key,
    this.imageUrl,
    this.radius = 20,
    this.placeholderIcon = Icons.person,
    this.onTap,
    this.isOnline = false,
    this.showOnlineIndicator = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget avatar = TapScale(
      onTap: onTap,
      child: CircleAvatar(
        radius: radius,
        backgroundColor: isDark ? AppTheme.surfaceDark : AppTheme.backgroundLight,
        backgroundImage: imageUrl != null ? NetworkImage(imageUrl!) : null,
        child: imageUrl == null
            ? Icon(
                placeholderIcon,
                size: radius,
                color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondary,
              )
            : null,
      ),
    );

    if (showOnlineIndicator) {
      avatar = Stack(
        children: [
          avatar,
          Positioned(
            right: 0,
            bottom: 0,
            child: AnimatedContainer(
              duration: AppDurations.normal,
              width: radius * 0.4,
              height: radius * 0.4,
              decoration: BoxDecoration(
                color: isOnline ? AppTheme.success : AppTheme.textSecondary,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
                  width: 2,
                ),
              ),
            ),
          ),
        ],
      );
    }

    return avatar;
  }
}

/// Animated loading indicator
class AnimatedLoading extends StatelessWidget {
  final double size;
  final Color? color;
  final String? message;

  const AnimatedLoading({
    super.key,
    this.size = 40,
    this.color,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(
              color ?? AppTheme.primaryBlue,
            ),
          ),
        ),
        if (message != null) ...[
          const SizedBox(height: AppTheme.spacingMd),
          FadeIn(
            child: Text(
              message!,
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppTheme.textSecondaryDark
                    : AppTheme.textSecondary,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Animated empty state
class AnimatedEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? action;

  const AnimatedEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingXxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ScaleIn(
              child: Container(
                padding: const EdgeInsets.all(AppTheme.spacingXl),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppTheme.surfaceDark
                      : AppTheme.backgroundLight,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 48,
                  color: isDark
                      ? AppTheme.textSecondaryDark
                      : AppTheme.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: AppTheme.spacingLg),
            SlideIn.fromBottom(
              delay: const Duration(milliseconds: 100),
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: AppTheme.spacingSm),
              SlideIn.fromBottom(
                delay: const Duration(milliseconds: 150),
                child: Text(
                  subtitle!,
                  style: TextStyle(
                    color: isDark
                        ? AppTheme.textSecondaryDark
                        : AppTheme.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: AppTheme.spacingXl),
              SlideIn.fromBottom(
                delay: const Duration(milliseconds: 200),
                child: action!,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Animated snackbar content
class AnimatedSnackbarContent extends StatelessWidget {
  final String message;
  final IconData? icon;
  final Color? iconColor;

  const AnimatedSnackbarContent({
    super.key,
    required this.message,
    this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return SlideIn.fromBottom(
      duration: AppDurations.fast,
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: iconColor ?? Colors.white, size: 20),
            const SizedBox(width: AppTheme.spacingSm),
          ],
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

/// Animated tab indicator
class AnimatedTabIndicator extends Decoration {
  final Color color;
  final double radius;

  const AnimatedTabIndicator({
    this.color = AppTheme.primaryBlue,
    this.radius = 3,
  });

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _AnimatedTabIndicatorPainter(color: color, radius: radius);
  }
}

class _AnimatedTabIndicatorPainter extends BoxPainter {
  final Color color;
  final double radius;

  _AnimatedTabIndicatorPainter({required this.color, required this.radius});

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final rect = offset & configuration.size!;
    final indicator = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        rect.left + rect.width * 0.2,
        rect.bottom - 3,
        rect.width * 0.6,
        3,
      ),
      Radius.circular(radius),
    );

    canvas.drawRRect(indicator, paint);
  }
}
