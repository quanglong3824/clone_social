import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../../../../core/utils/validation_utils.dart';
import '../../../../core/themes/app_theme.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/app_button.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  String? _emailError;
  bool _emailSent = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
      ),
    );

    _animationController.forward();
  }


  @override
  void dispose() {
    _emailController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _validateEmail(String value) {
    setState(() {
      _emailError = ValidationUtils.validateEmail(value);
    });
  }

  Future<void> _resetPassword() async {
    _validateEmail(_emailController.text);

    if (_emailError != null) {
      return;
    }

    final success = await context.read<AuthProvider>().resetPassword(
          _emailController.text.trim(),
        );

    if (success && mounted) {
      setState(() {
        _emailSent = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.backgroundDark : AppTheme.surfaceLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppTheme.spacingXxl),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: _emailSent ? _buildSuccessContent() : _buildFormContent(authProvider),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormContent(AuthProvider authProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHeader(),
        const SizedBox(height: AppTheme.spacing3xl),
        _buildEmailField(),
        const SizedBox(height: AppTheme.spacingXxl),
        _buildErrorMessage(authProvider),
        _buildResetButton(authProvider),
        const SizedBox(height: AppTheme.spacingXxl),
        _buildBackToLogin(),
      ],
    );
  }

  Widget _buildSuccessContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: AppTheme.successLight,
            borderRadius: BorderRadius.circular(AppTheme.radiusFull),
          ),
          child: const Icon(
            Icons.mark_email_read_outlined,
            size: 50,
            color: AppTheme.success,
          ),
        ),
        const SizedBox(height: AppTheme.spacingXxl),
        Text(
          'Check Your Email',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: AppTheme.spacingMd),
        Text(
          'We\'ve sent a password reset link to:',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppTheme.textSecondary,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppTheme.spacingSm),
        Text(
          _emailController.text,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: AppTheme.spacingXxl),
        Container(
          padding: const EdgeInsets.all(AppTheme.spacingLg),
          decoration: BoxDecoration(
            color: AppTheme.infoLight,
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: AppTheme.info),
              const SizedBox(width: AppTheme.spacingMd),
              Expanded(
                child: Text(
                  'If you don\'t see the email, check your spam folder.',
                  style: TextStyle(color: AppTheme.info),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppTheme.spacing3xl),
        AppButton(
          label: 'Back to Login',
          onPressed: () => context.go('/login'),
          isFullWidth: true,
          size: ButtonSize.large,
        ),
        const SizedBox(height: AppTheme.spacingLg),
        AppButton(
          label: 'Resend Email',
          variant: ButtonVariant.outline,
          onPressed: () {
            setState(() {
              _emailSent = false;
            });
          },
          isFullWidth: true,
        ),
      ],
    );
  }


  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppTheme.lightBlue,
            borderRadius: BorderRadius.circular(AppTheme.radiusFull),
          ),
          child: const Icon(
            Icons.lock_reset,
            size: 40,
            color: AppTheme.primaryBlue,
          ),
        ),
        const SizedBox(height: AppTheme.spacingXxl),
        Text(
          'Forgot Password?',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: AppTheme.spacingMd),
        Text(
          'No worries! Enter your email and we\'ll send you a reset link.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppTheme.textSecondary,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return AppTextField(
      label: 'Email',
      hint: 'Enter your email address',
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      prefixIcon: const Icon(Icons.email_outlined),
      errorText: _emailError,
      onChanged: _validateEmail,
      onSubmitted: (_) => _resetPassword(),
    );
  }

  Widget _buildErrorMessage(AuthProvider authProvider) {
    if (authProvider.error == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingLg),
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        decoration: BoxDecoration(
          color: AppTheme.errorLight,
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          border: Border.all(color: AppTheme.error.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: AppTheme.error, size: 20),
            const SizedBox(width: AppTheme.spacingSm),
            Expanded(
              child: Text(
                authProvider.error!,
                style: const TextStyle(color: AppTheme.error, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResetButton(AuthProvider authProvider) {
    return AppButton(
      label: 'Send Reset Link',
      onPressed: authProvider.isLoading ? null : _resetPassword,
      isLoading: authProvider.isLoading,
      isFullWidth: true,
      size: ButtonSize.large,
    );
  }

  Widget _buildBackToLogin() {
    return Center(
      child: AppButton(
        label: 'Back to Login',
        variant: ButtonVariant.text,
        icon: Icons.arrow_back,
        onPressed: () => context.pop(),
      ),
    );
  }
}
