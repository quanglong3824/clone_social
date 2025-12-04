import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../../../../core/utils/validation_utils.dart';
import '../../../../core/themes/app_theme.dart';
import '../../../../core/widgets/app_text_field.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  String? _nameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
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
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _validateName(String value) {
    setState(() {
      _nameError = ValidationUtils.validateName(value);
    });
  }

  void _validateEmail(String value) {
    setState(() {
      _emailError = ValidationUtils.validateEmail(value);
    });
  }

  void _validatePassword(String value) {
    setState(() {
      _passwordError = ValidationUtils.validatePassword(value);
      if (_confirmPasswordController.text.isNotEmpty) {
        _confirmPasswordError = ValidationUtils.validateConfirmPassword(
          _confirmPasswordController.text,
          value,
        );
      }
    });
  }

  void _validateConfirmPassword(String value) {
    setState(() {
      _confirmPasswordError = ValidationUtils.validateConfirmPassword(
        value,
        _passwordController.text,
      );
    });
  }

  Future<void> _register() async {
    _validateName(_nameController.text);
    _validateEmail(_emailController.text);
    _validatePassword(_passwordController.text);
    _validateConfirmPassword(_confirmPasswordController.text);

    if (_nameError != null ||
        _emailError != null ||
        _passwordError != null ||
        _confirmPasswordError != null) {
      return;
    }

    final success = await context.read<AuthProvider>().signUp(
          _emailController.text.trim(),
          _passwordController.text,
          _nameController.text.trim(),
        );

    if (success && mounted) {
      _showVerificationDialog();
    }
  }

  void _showVerificationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00B4DB), Color(0xFF00D4AA)],
                ),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 45,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  Positioned(
                    bottom: 18,
                    right: 18,
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: const BoxDecoration(
                        color: Color(0xFF4ECDC4),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text('✓', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.spacingXxl),
            const Text('Verify Your Email', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
            const SizedBox(height: AppTheme.spacingMd),
            Text('We\'ve sent a verification email to:', style: TextStyle(color: AppTheme.textSecondary)),
            const SizedBox(height: AppTheme.spacingSm),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF00B4DB).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(_emailController.text, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF00B4DB))),
            ),
            const SizedBox(height: AppTheme.spacingXxl),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF00B4DB), Color(0xFF00D4AA)]),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    context.go('/login');
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                  child: const Text('Go to Login', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [const Color(0xFF0D1B2A), const Color(0xFF1B263B)]
                : [const Color(0xFF00B4DB), const Color(0xFF00D4AA)],
            stops: const [0.0, 0.35],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              _buildDecorativeShapes(),
              Column(
                children: [
                  _buildAppBar(),
                  FadeTransition(opacity: _fadeAnimation, child: _buildHeader()),
                  const SizedBox(height: AppTheme.spacingXxl),
                  Expanded(
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: isDark ? AppTheme.surfaceDark : Colors.white,
                            borderRadius: const BorderRadius.only(topLeft: Radius.circular(35), topRight: Radius.circular(35)),
                          ),
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(AppTheme.spacingXxl),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _buildNameField(),
                                  const SizedBox(height: AppTheme.spacingLg),
                                  _buildEmailField(),
                                  const SizedBox(height: AppTheme.spacingLg),
                                  _buildPasswordField(),
                                  const SizedBox(height: AppTheme.spacingLg),
                                  _buildConfirmPasswordField(),
                                  const SizedBox(height: AppTheme.spacingXxl),
                                  _buildErrorMessage(authProvider),
                                  _buildRegisterButton(authProvider),
                                  const SizedBox(height: AppTheme.spacingXxl),
                                  _buildLoginLink(),
                                  const SizedBox(height: AppTheme.spacingXxl),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd, vertical: AppTheme.spacingSm),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
              child: const Center(child: Text('←', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDecorativeShapes() {
    return Stack(
      children: [
        Positioned(top: -30, right: -30, child: Container(width: 120, height: 120, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.1)))),
        Positioned(top: 100, left: -20, child: Container(width: 60, height: 60, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.08)))),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingXxl),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Create Account', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white)),
              const SizedBox(width: 10),
              Container(width: 24, height: 24, decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFFFE66D), Color(0xFFFF6B6B)]), borderRadius: BorderRadius.circular(8))),
            ],
          ),
          const SizedBox(height: AppTheme.spacingSm),
          Text('Join Social Home and connect with friends', style: TextStyle(fontSize: 15, color: Colors.white.withOpacity(0.85)), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildNameField() {
    return AppTextField(
      label: 'Full Name',
      hint: 'Enter your full name',
      controller: _nameController,
      prefixIcon: Container(margin: const EdgeInsets.all(12), width: 20, height: 20, decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFFF6B6B), Color(0xFFFFE66D)]), borderRadius: BorderRadius.circular(10))),
      errorText: _nameError,
      onChanged: _validateName,
      textInputAction: TextInputAction.next,
    );
  }

  Widget _buildEmailField() {
    return AppTextField(
      label: 'Email',
      hint: 'Enter your email',
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      prefixIcon: Container(margin: const EdgeInsets.all(12), width: 20, height: 20, decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF00B4DB), Color(0xFF00D4AA)]), borderRadius: BorderRadius.circular(5))),
      errorText: _emailError,
      onChanged: _validateEmail,
      textInputAction: TextInputAction.next,
    );
  }

  Widget _buildPasswordField() {
    return AppTextField(
      label: 'Password',
      hint: 'Create a password',
      controller: _passwordController,
      obscureText: !_isPasswordVisible,
      prefixIcon: Container(margin: const EdgeInsets.all(12), width: 20, height: 20, decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF4ECDC4), Color(0xFF44A08D)]), shape: BoxShape.circle)),
      errorText: _passwordError,
      onChanged: _validatePassword,
      suffixIcon: _buildVisibilityToggle(_isPasswordVisible, () => setState(() => _isPasswordVisible = !_isPasswordVisible)),
      textInputAction: TextInputAction.next,
    );
  }

  Widget _buildConfirmPasswordField() {
    return AppTextField(
      label: 'Confirm Password',
      hint: 'Confirm your password',
      controller: _confirmPasswordController,
      obscureText: !_isConfirmPasswordVisible,
      prefixIcon: Container(margin: const EdgeInsets.all(12), width: 20, height: 20, decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF4ECDC4), Color(0xFF44A08D)]), shape: BoxShape.circle)),
      errorText: _confirmPasswordError,
      onChanged: _validateConfirmPassword,
      suffixIcon: _buildVisibilityToggle(_isConfirmPasswordVisible, () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible)),
      onSubmitted: (_) => _register(),
    );
  }

  Widget _buildVisibilityToggle(bool isVisible, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(12),
        width: 24,
        height: 24,
        decoration: BoxDecoration(color: isVisible ? const Color(0xFF00B4DB).withOpacity(0.2) : Colors.grey.withOpacity(0.2), borderRadius: BorderRadius.circular(6)),
        child: Center(child: Container(width: 8, height: 8, decoration: BoxDecoration(color: isVisible ? const Color(0xFF00B4DB) : Colors.grey, shape: BoxShape.circle))),
      ),
    );
  }

  Widget _buildErrorMessage(AuthProvider authProvider) {
    if (authProvider.error == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingLg),
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        decoration: BoxDecoration(color: const Color(0xFFFF6B6B).withOpacity(0.1), borderRadius: BorderRadius.circular(AppTheme.radiusMd), border: Border.all(color: const Color(0xFFFF6B6B).withOpacity(0.3))),
        child: Row(
          children: [
            Container(width: 20, height: 20, decoration: const BoxDecoration(color: Color(0xFFFF6B6B), shape: BoxShape.circle), child: const Center(child: Text('!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)))),
            const SizedBox(width: AppTheme.spacingSm),
            Expanded(child: Text(authProvider.error!, style: const TextStyle(color: Color(0xFFFF6B6B), fontSize: 14))),
          ],
        ),
      ),
    );
  }

  Widget _buildRegisterButton(AuthProvider authProvider) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF00B4DB), Color(0xFF00D4AA)]),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: const Color(0xFF00B4DB).withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: ElevatedButton(
        onPressed: authProvider.isLoading ? null : _register,
        style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
        child: authProvider.isLoading
            ? Row(mainAxisAlignment: MainAxisAlignment.center, children: [Container(width: 20, height: 20, decoration: BoxDecoration(border: Border.all(color: Colors.white, width: 2), shape: BoxShape.circle)), const SizedBox(width: 12), const Text('Creating account...', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white))])
            : const Text('Create Account', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white)),
      ),
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Already have an account? ', style: TextStyle(color: AppTheme.textSecondary)),
        GestureDetector(
          onTap: () => context.pop(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF00B4DB), Color(0xFF00D4AA)]), borderRadius: BorderRadius.circular(8)),
            child: const Text('Sign In', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ),
      ],
    );
  }
}
