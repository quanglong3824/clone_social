import 'package:flutter/material.dart';
import '../themes/app_theme.dart';

enum ButtonVariant { primary, secondary, outline, text }
enum ButtonSize { small, medium, large }

class AppButton extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: _getHeight(),
      child: _buildButton(context, isDark),
    );
  }

  double _getHeight() {
    switch (size) {
      case ButtonSize.small:
        return 32.0;
      case ButtonSize.medium:
        return 44.0;
      case ButtonSize.large:
        return 52.0;
    }
  }

  EdgeInsets _getPadding() {
    switch (size) {
      case ButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0);
      case ButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0);
      case ButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 28.0, vertical: 14.0);
    }
  }


  double _getFontSize() {
    switch (size) {
      case ButtonSize.small:
        return 12.0;
      case ButtonSize.medium:
        return 14.0;
      case ButtonSize.large:
        return 16.0;
    }
  }

  double _getIconSize() {
    switch (size) {
      case ButtonSize.small:
        return 14.0;
      case ButtonSize.medium:
        return 18.0;
      case ButtonSize.large:
        return 22.0;
    }
  }

  Widget _buildButton(BuildContext context, bool isDark) {
    switch (variant) {
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
      onPressed: isLoading ? null : onPressed,
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
      onPressed: isLoading ? null : onPressed,
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
      onPressed: isLoading ? null : onPressed,
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
      onPressed: isLoading ? null : onPressed,
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
    if (isLoading) {
      return SizedBox(
        width: _getIconSize(),
        height: _getIconSize(),
        child: CircularProgressIndicator(
          strokeWidth: 2.0,
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: _getIconSize()),
          SizedBox(width: AppTheme.spacingXs),
          Text(
            label,
            style: TextStyle(
              fontSize: _getFontSize(),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

    return Text(
      label,
      style: TextStyle(
        fontSize: _getFontSize(),
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
