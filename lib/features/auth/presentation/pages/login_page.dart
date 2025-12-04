import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../../../../core/utils/validation_utils.dart';
import '../../../../core/themes/app_theme.dart';
import '../../../../core/widgets/app_text_field.dart';

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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    const Color(0xFF0D1B2A),
                    const Color(0xFF1B263B),
                  ]
                : [
                    const Color(0xFF00B4DB),
                    const Color(0xFF00D4AA),
                  ],
            stops: const [0.0, 0.45],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              _buildDecorativeShapes(),
              Column(
                children: [
                  // Top section with logo
                  Expanded(
                    flex: 2,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: _buildLogoSection(),
                    ),
                  ),
                  // Bottom section with form
                  Expanded(
                    flex: 5,
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
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _buildWelcomeText(),
                                  const SizedBox(height: AppTheme.spacing3xl),
                                  _buildEmailField(),
                                  const SizedBox(height: AppTheme.spacingLg),
                                  _buildPasswordField(),
                                  const SizedBox(height: AppTheme.spacingMd),
                                  _buildForgotPassword(),
                                  const SizedBox(height: AppTheme.spacingXxl),
                                  _buildErrorMessage(authProvider),
                                  _buildLoginButton(authProvider),
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
                ],
              ),
            ],
          ),
        ),
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
          top: 80,
          left: -30,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.08),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLogoSection() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 25,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // House shape
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomPaint(
                    size: const Size(40, 22),
                    painter: _RoofPainter(),
                  ),
                  Container(
                    width: 32,
                    height: 26,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF00B4DB), Color(0xFF00D4AA)],
                      ),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Center(
                      child: Container(
                        width: 10,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              // Decorative dot
              Positioned(
                top: 14,
                right: 14,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF6B6B), Color(0xFFFFE66D)],
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppTheme.spacingLg),
        const Text(
          'Social Home',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Welcome Back!',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFE66D), Color(0xFFFF6B6B)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacingSm),
        Text(
          'Sign in to continue to your home',
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
      textInputAction: TextInputAction.next,
    );
  }

  Widget _buildPasswordField() {
    return AppTextField(
      label: 'Password',
      hint: 'Enter your password',
      controller: _passwordController,
      obscureText: !_isPasswordVisible,
      prefixIcon: Container(
        margin: const EdgeInsets.all(12),
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF4ECDC4), Color(0xFF44A08D)],
          ),
          shape: BoxShape.circle,
        ),
      ),
      errorText: _passwordError,
      onChanged: _validatePassword,
      suffixIcon: GestureDetector(
        onTap: () {
          setState(() {
            _isPasswordVisible = !_isPasswordVisible;
          });
        },
        child: Container(
          margin: const EdgeInsets.all(12),
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: _isPasswordVisible
                ? const Color(0xFF00B4DB).withOpacity(0.2)
                : Colors.grey.withOpacity(0.2),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Center(
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: _isPasswordVisible
                    ? const Color(0xFF00B4DB)
                    : Colors.grey,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
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

  Widget _buildLoginButton(AuthProvider authProvider) {
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
        onPressed: authProvider.isLoading ? null : _login,
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
                    'Signing in...',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              )
            : const Text(
                'Sign In',
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

  Widget _buildForgotPassword() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () => context.push('/forgot-password'),
        child: const Text(
          'Forgot Password?',
          style: TextStyle(
            color: Color(0xFF00B4DB),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.grey.withOpacity(0.3),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingLg),
          child: Text(
            'or continue with',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.grey.withOpacity(0.3),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGoogleButton(AuthProvider authProvider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white24 : Colors.grey.shade300,
        ),
      ),
      child: ElevatedButton(
        onPressed: authProvider.isLoading ? null : _googleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Google logo as colored squares
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF4285F4),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(2),
                    ),
                  ),
                ),
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEA4335),
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(2),
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFBBC05),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(2),
                    ),
                  ),
                ),
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF34A853),
                    borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Text(
              'Google',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegisterLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account? ",
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        GestureDetector(
          onTap: () => context.push('/register'),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF00B4DB), Color(0xFF00D4AA)],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'Sign Up',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _RoofPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF00B4DB), Color(0xFF00D4AA)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
