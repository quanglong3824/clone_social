import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../../../../core/utils/validation_utils.dart';
import '../../../../core/themes/app_theme.dart';
import '../../../../core/widgets/app_text_field.dart';

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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [const Color(0xFF0D1B2A), const Color(0xFF1B263B)]
                : [const Color(0xFF00B4DB), const Color(0xFF00D4AA)],
            stops: const [0.0, 0.4],
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
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(35),
                              topRight: Radius.circular(35),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 20,
                                offset: const Offset(0, -5),
                              ),
                            ],
                          ),
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(AppTheme.spacingXxl),
                            child: _emailSent
                                ? _buildSuccessContent()
                                : _buildFormContent(authProvider),
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
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMd,
        vertical: AppTheme.spacingSm,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text(
                  '←',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDecorativeShapes() {
    return Stack(
      children: [
        Positioned(
          top: -40,
          right: -40,
          child: Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.1),
            ),
          ),
        ),
        Positioned(
          top: 120,
          left: -25,
          child: Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.08),
            ),
          ),
        ),
        Positioned(
          top: 80,
          right: 30,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white.withOpacity(0.06),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingXxl),
      child: Column(
        children: [
          // Lock reset visual
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Lock body
                Container(
                  width: 36,
                  height: 30,
                  margin: const EdgeInsets.only(top: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                // Lock shackle
                Positioned(
                  top: 18,
                  child: Container(
                    width: 26,
                    height: 20,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white, width: 4),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(13),
                        topRight: Radius.circular(13),
                      ),
                    ),
                  ),
                ),
                // Refresh arrow
                Positioned(
                  bottom: 15,
                  right: 15,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFE66D), Color(0xFFFF6B6B)],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text(
                        '↻',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.spacingXxl),
          const Text(
            'Forgot Password?',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: AppTheme.spacingSm),
          Text(
            'No worries! Enter your email and we\'ll send you a reset link.',
            style: TextStyle(
              fontSize: 15,
              color: Colors.white.withOpacity(0.85),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFormContent(AuthProvider authProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: AppTheme.spacingLg),
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
        const SizedBox(height: AppTheme.spacingXxl),
        // Success indicator
        Container(
          width: 110,
          height: 110,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF00B4DB), Color(0xFF00D4AA)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00B4DB).withOpacity(0.3),
                blurRadius: 25,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Envelope shape
              Container(
                width: 50,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              // Check badge
              Positioned(
                bottom: 20,
                right: 20,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    color: Color(0xFF4ECDC4),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text(
                      '✓',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppTheme.spacing3xl),
        const Text(
          'Check Your Email',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: AppTheme.spacingMd),
        Text(
          'We\'ve sent a password reset link to:',
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 16,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppTheme.spacingMd),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF00B4DB).withOpacity(0.1),
                const Color(0xFF00D4AA).withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF00B4DB).withOpacity(0.3),
            ),
          ),
          child: Text(
            _emailController.text,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: Color(0xFF00B4DB),
            ),
          ),
        ),
        const SizedBox(height: AppTheme.spacingXxl),
        // Info box
        Container(
          padding: const EdgeInsets.all(AppTheme.spacingLg),
          decoration: BoxDecoration(
            color: const Color(0xFFFFE66D).withOpacity(0.15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFFFE66D).withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFE66D), Color(0xFFFF6B6B)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text(
                    'i',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppTheme.spacingMd),
              Expanded(
                child: Text(
                  'If you don\'t see the email, check your spam folder.',
                  style: TextStyle(
                    color: Colors.orange.shade800,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppTheme.spacing3xl),
        // Back to login button
        Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF00B4DB), Color(0xFF00D4AA)],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00B4DB).withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: () => context.go('/login'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              'Back to Login',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppTheme.spacingLg),
        // Resend button
        TextButton(
          onPressed: () {
            setState(() {
              _emailSent = false;
            });
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF00B4DB), width: 2),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text(
                    '↻',
                    style: TextStyle(
                      color: Color(0xFF00B4DB),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Resend Email',
                style: TextStyle(
                  color: Color(0xFF00B4DB),
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ],
          ),
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
      prefixIcon: Container(
        margin: const EdgeInsets.all(12),
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF00B4DB), Color(0xFF00D4AA)],
          ),
          borderRadius: BorderRadius.circular(5),
        ),
      ),
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
          color: const Color(0xFFFF6B6B).withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(color: const Color(0xFFFF6B6B).withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                color: Color(0xFFFF6B6B),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text(
                  '!',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppTheme.spacingSm),
            Expanded(
              child: Text(
                authProvider.error!,
                style: const TextStyle(
                  color: Color(0xFFFF6B6B),
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResetButton(AuthProvider authProvider) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00B4DB), Color(0xFF00D4AA)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00B4DB).withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: authProvider.isLoading ? null : _resetPassword,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: authProvider.isLoading
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white, width: 2),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Sending...',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              )
            : const Text(
                'Send Reset Link',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
      ),
    );
  }

  Widget _buildBackToLogin() {
    return Center(
      child: TextButton(
        onPressed: () => context.pop(),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: const Color(0xFF00B4DB).withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Center(
                child: Text(
                  '←',
                  style: TextStyle(
                    color: Color(0xFF00B4DB),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Back to Login',
              style: TextStyle(
                color: Color(0xFF00B4DB),
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
