import 'package:flutter/material.dart';
import '../themes/app_theme.dart';

class AppTextField extends StatefulWidget {
  final String? label;
  final String? hint;
  final String? errorText;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final bool enabled;
  final int maxLines;
  final int? maxLength;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final bool autofocus;

  const AppTextField({
    super.key,
    this.label,
    this.hint,
    this.errorText,
    this.controller,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.enabled = true,
    this.maxLines = 1,
    this.maxLength,
    this.focusNode,
    this.textInputAction,
    this.autofocus = false,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}


class _AppTextFieldState extends State<AppTextField> {
  late FocusNode _focusNode;
  bool _isFocused = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_handleFocusChange);
    _hasError = widget.errorText != null && widget.errorText!.isNotEmpty;
  }

  @override
  void didUpdateWidget(AppTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    _hasError = widget.errorText != null && widget.errorText!.isNotEmpty;
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _handleFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: _getLabelColor(isDark),
            ),
          ),
          const SizedBox(height: AppTheme.spacingXs),
        ],
        TextFormField(
          controller: widget.controller,
          focusNode: _focusNode,
          obscureText: widget.obscureText,
          keyboardType: widget.keyboardType,
          enabled: widget.enabled,
          maxLines: widget.maxLines,
          maxLength: widget.maxLength,
          textInputAction: widget.textInputAction,
          autofocus: widget.autofocus,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onSubmitted,
          validator: widget.validator,
          style: TextStyle(
            fontSize: 16,
            color: widget.enabled
                ? (isDark ? AppTheme.textDark : AppTheme.textPrimary)
                : (isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondary),
          ),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: TextStyle(
              color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondary,
            ),
            errorText: widget.errorText,
            prefixIcon: widget.prefixIcon,
            suffixIcon: widget.suffixIcon,
            filled: true,
            fillColor: _getFillColor(isDark),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingLg,
              vertical: AppTheme.spacingMd,
            ),
            border: _buildBorder(isDark),
            enabledBorder: _buildBorder(isDark),
            focusedBorder: _buildFocusedBorder(),
            errorBorder: _buildErrorBorder(),
            focusedErrorBorder: _buildErrorBorder(),
            disabledBorder: _buildDisabledBorder(isDark),
          ),
        ),
      ],
    );
  }


  Color _getLabelColor(bool isDark) {
    if (!widget.enabled) {
      return isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondary;
    }
    if (_hasError) {
      return AppTheme.error;
    }
    if (_isFocused) {
      return AppTheme.primaryBlue;
    }
    return isDark ? AppTheme.textDark : AppTheme.textPrimary;
  }

  Color _getFillColor(bool isDark) {
    if (!widget.enabled) {
      return isDark 
          ? AppTheme.surfaceDark.withOpacity(0.5) 
          : AppTheme.backgroundLight.withOpacity(0.5);
    }
    return isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight;
  }

  OutlineInputBorder _buildBorder(bool isDark) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      borderSide: BorderSide(
        color: isDark ? AppTheme.dividerDark : AppTheme.dividerLight,
        width: 1.0,
      ),
    );
  }

  OutlineInputBorder _buildFocusedBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      borderSide: const BorderSide(
        color: AppTheme.primaryBlue,
        width: 2.0,
      ),
    );
  }

  OutlineInputBorder _buildErrorBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      borderSide: const BorderSide(
        color: AppTheme.error,
        width: 1.5,
      ),
    );
  }

  OutlineInputBorder _buildDisabledBorder(bool isDark) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      borderSide: BorderSide(
        color: (isDark ? AppTheme.dividerDark : AppTheme.dividerLight).withOpacity(0.5),
        width: 1.0,
      ),
    );
  }
}
