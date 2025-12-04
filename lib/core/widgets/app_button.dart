import 'package:flutter/material.dart';
import '../themes/app_theme.dart';
import '../animations/app_animations.dart';

enum ButtonVariant { primary, secondary, outline, text }
enum ButtonSize { small, medium, large }

class AppButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final ButtonSize size;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
  });

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> with SingleTickerProviderStateMixin {
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
    
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: SizedBox(
          width: widget.isFullWidth ? double.infinity : null,
          height: _getHeight(),
          child: _buildButton(context, isDark),
        ),
      ),
    );
  }

  double _getHeight() {
    switch (widget.size) {
      case ButtonSize.small:
        return 32.0;
      case ButtonSize.medium:
        return 44.0;
      case ButtonSize.large:
        return 52.0;
    }
  }

  EdgeInsets _getPadding() {
    switch (widget.size) {
      case ButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0);
      case ButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0);
      case ButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 28.0, vertical: 14.0);
    }
  }

  double _getFontSize() {
    switch (widget.size) {
      case ButtonSize.small:
        return 12.0;
      case ButtonSize.medium:
        return 14.0;
      case ButtonSize.large:
        return 16.0;
    }
  }

  double _getIconSize() {
    switch (widget.size) {
      case ButtonSize.small:
        return 14.0;
      case ButtonSize.medium:
        return 18.0;
      case ButtonSize.large:
        return 22.0;
    }
  }

  Widget _buildButton(BuildContext context, bool isDark) {
    switch (widget.variant) {
      case ButtonVariant.primary:
        return _buildPrimaryButton(isDark);
      case ButtonVariant.secondary:
        return _buildSecondaryButton(isDark);
      case ButtonVariant.outline:
        return _buildOutlineButton(isDark);
      case ButtonVariant.text:
        return _buildTextButton(isDark);
    }
  }

  Widget _buildPrimaryButton(bool isDark) {
    return ElevatedButton(
      onPressed: widget.isLoading ? null : widget.onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
        disabledBackgroundColor: AppTheme.primaryBlue.withOpacity(0.6),
        disabledForegroundColor: Colors.white.withOpacity(0.6),
        elevation: 0,
        padding: _getPadding(),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        ),
      ),
      child: _buildButtonContent(Colors.white),
    );
  }

  Widget _buildSecondaryButton(bool isDark) {
    final bgColor = isDark ? AppTheme.surfaceDark : AppTheme.lightBlue;
    final fgColor = AppTheme.primaryBlue;
    
    return ElevatedButton(
      onPressed: widget.isLoading ? null : widget.onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: bgColor,
        foregroundColor: fgColor,
        disabledBackgroundColor: bgColor.withOpacity(0.6),
        disabledForegroundColor: fgColor.withOpacity(0.6),
        elevation: 0,
        padding: _getPadding(),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        ),
      ),
      child: _buildButtonContent(fgColor),
    );
  }

  Widget _buildOutlineButton(bool isDark) {
    final borderColor = isDark ? AppTheme.dividerDark : AppTheme.dividerLight;
    final fgColor = isDark ? AppTheme.textDark : AppTheme.textPrimary;
    
    return OutlinedButton(
      onPressed: widget.isLoading ? null : widget.onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: fgColor,
        side: BorderSide(color: borderColor),
        padding: _getPadding(),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        ),
      ),
      child: _buildButtonContent(fgColor),
    );
  }

  Widget _buildTextButton(bool isDark) {
    final fgColor = AppTheme.primaryBlue;
    
    return TextButton(
      onPressed: widget.isLoading ? null : widget.onPressed,
      style: TextButton.styleFrom(
        foregroundColor: fgColor,
        padding: _getPadding(),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        ),
      ),
      child: _buildButtonContent(fgColor),
    );
  }

  Widget _buildButtonContent(Color color) {
    if (widget.isLoading) {
      return SizedBox(
        width: _getIconSize(),
        height: _getIconSize(),
        child: CircularProgressIndicator(
          strokeWidth: 2.0,
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      );
    }

    if (widget.icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(widget.icon, size: _getIconSize()),
          const SizedBox(width: AppTheme.spacingXs),
          Text(
            widget.label,
            style: TextStyle(
              fontSize: _getFontSize(),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

    return Text(
      widget.label,
      style: TextStyle(
        fontSize: _getFontSize(),
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
