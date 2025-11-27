import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../../../../core/utils/validation_utils.dart';
import '../../../../core/themes/app_theme.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/app_button.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  String? _emailError;
  String? _passwordError;

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
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _validateEmail(String value) {
    setState(() {
      _emailError = ValidationUtils.validateEmail(value);
    });
  }

  void _validatePassword(String value) {
    setState(() {
      _passwordError = ValidationUtils.validatePassword(value);
    });
  }

  Future<void> _login() async {
    // Validate all fields
    _validateEmail(_emailController.text);
    _validatePassword(_passwordController.text);

    if (_emailError != null || _passwordError != null) {
      return;
    }

    final success = await context.read<AuthProvider>().signIn(
          _emailController.text.trim(),
          _passwordController.text,
        );

    if (success && mounted) {
      context.go('/');
    }
  }

  Future<void> _googleLogin() async {
    final success = await context.read<AuthProvider>().signInWithGoogle();
    if (success && mounted) {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.backgroundDark : AppTheme.surfaceLight,
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
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildLogo(),
                        const SizedBox(height: AppTheme.spacing4xl),
                        _buildEmailField(),
                        const SizedBox(height: AppTheme.spacingLg),
                        _buildPasswordField(),
                        const SizedBox(height: AppTheme.spacingXxl),
                        _buildErrorMessage(authProvider),
                        _buildLoginButton(authProvider),
                        const SizedBox(height: AppTheme.spacingLg),
                        _buildForgotPassword(),
                        const SizedBox(height: AppTheme.spacingXxl),
                        _buildDivider(),
                        const SizedBox(height: AppTheme.spacingXxl),
                        _buildGoogleButton(authProvider),
                        const SizedBox(height: AppTheme.spacingXxl),
                        _buildRegisterLink(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildLogo() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppTheme.primaryBlue,
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryBlue.withOpacity(0.3),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Icon(
            Icons.facebook,
            size: 50,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: AppTheme.spacingLg),
        Text(
          'Welcome Back',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: AppTheme.spacingSm),
        Text(
          'Sign in to continue',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppTheme.textSecondary,
              ),
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return AppTextField(
      label: 'Email',
      hint: 'Enter your email',
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      prefixIcon: const Icon(Icons.email_outlined),
      errorText: _emailError,
      onChanged: _validateEmail,
      textInputAction: TextInputAction.next,
    );
  }

  Widget _buildPasswordField() {
    return AppTextField(
      label: 'Password',
      hint: 'Enter your password',
      controller: _passwordController,
      obscureText: !_isPasswordVisible,
      prefixIcon: const Icon(Icons.lock_outline),
      errorText: _passwordError,
      onChanged: _validatePassword,
      suffixIcon: IconButton(
        icon: Icon(
          _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
        ),
        onPressed: () {
          setState(() {
            _isPasswordVisible = !_isPasswordVisible;
          });
        },
      ),
      onSubmitted: (_) => _login(),
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

  Widget _buildLoginButton(AuthProvider authProvider) {
    return AppButton(
      label: 'Log In',
      onPressed: authProvider.isLoading ? null : _login,
      isLoading: authProvider.isLoading,
      isFullWidth: true,
      size: ButtonSize.large,
    );
  }

  Widget _buildForgotPassword() {
    return Center(
      child: AppButton(
        label: 'Forgot Password?',
        variant: ButtonVariant.text,
        onPressed: () => context.push('/forgot-password'),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingLg),
          child: Text(
            'OR',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }

  Widget _buildGoogleButton(AuthProvider authProvider) {
    return AppButton(
      label: 'Continue with Google',
      variant: ButtonVariant.outline,
      icon: Icons.g_mobiledata,
      onPressed: authProvider.isLoading ? null : _googleLogin,
      isFullWidth: true,
      size: ButtonSize.large,
    );
  }

  Widget _buildRegisterLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account?",
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        AppButton(
          label: 'Sign Up',
          variant: ButtonVariant.text,
          onPressed: () => context.push('/register'),
        ),
      ],
    );
  }
}
