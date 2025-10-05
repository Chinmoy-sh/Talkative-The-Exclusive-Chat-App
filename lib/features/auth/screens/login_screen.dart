// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/utils/app_router.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/custom_button.dart' as button;
import '../../../shared/widgets/loading_overlay.dart';

// Login Form State Management
final loginFormProvider =
    StateNotifierProvider<LoginFormNotifier, LoginFormState>((ref) {
      return LoginFormNotifier();
    });

class LoginFormState {
  final String email;
  final String password;
  final bool isLoading;
  final bool obscurePassword;
  final bool rememberMe;
  final String? errorMessage;

  const LoginFormState({
    this.email = '',
    this.password = '',
    this.isLoading = false,
    this.obscurePassword = true,
    this.rememberMe = false,
    this.errorMessage,
  });

  LoginFormState copyWith({
    String? email,
    String? password,
    bool? isLoading,
    bool? obscurePassword,
    bool? rememberMe,
    String? errorMessage,
  }) {
    return LoginFormState(
      email: email ?? this.email,
      password: password ?? this.password,
      isLoading: isLoading ?? this.isLoading,
      obscurePassword: obscurePassword ?? this.obscurePassword,
      rememberMe: rememberMe ?? this.rememberMe,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class LoginFormNotifier extends StateNotifier<LoginFormState> {
  LoginFormNotifier() : super(const LoginFormState());

  void updateEmail(String email) {
    state = state.copyWith(email: email, errorMessage: null);
  }

  void updatePassword(String password) {
    state = state.copyWith(password: password, errorMessage: null);
  }

  void togglePasswordVisibility() {
    state = state.copyWith(obscurePassword: !state.obscurePassword);
  }

  void toggleRememberMe() {
    state = state.copyWith(rememberMe: !state.rememberMe);
  }

  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  void setError(String? error) {
    state = state.copyWith(errorMessage: error, isLoading: false);
  }

  Future<bool> login(WidgetRef ref) async {
    if (state.email.isEmpty || state.password.isEmpty) {
      setError('Please fill in all fields');
      return false;
    }

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(state.email)) {
      setError('Please enter a valid email address');
      return false;
    }

    setLoading(true);

    try {
      final authService = ref.read(authServiceProvider);
      final userCredential = await authService.signInWithEmailAndPassword(
        email: state.email,
        password: state.password,
      );

      if (userCredential?.user != null) {
        setLoading(false);
        return true;
      } else {
        setError('Invalid email or password');
        return false;
      }
    } catch (e) {
      setError(e.toString());
      return false;
    }
  }
}

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final success = await ref.read(loginFormProvider.notifier).login(ref);
      if (success && mounted) {
        Navigator.of(context).pushReplacementNamed(AppRouter.home);
      }
    }
  }

  void _handleGoogleSignIn() async {
    try {
      ref.read(loginFormProvider.notifier).setLoading(true);
      final authService = ref.read(authServiceProvider);
      final user = await authService.signInWithGoogle();

      if (user != null && mounted) {
        Navigator.of(context).pushReplacementNamed(AppRouter.home);
      } else {
        ref.read(loginFormProvider.notifier).setError('Google sign-in failed');
      }
    } catch (e) {
      ref.read(loginFormProvider.notifier).setError(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(loginFormProvider);
    final size = MediaQuery.of(context).size;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: LoadingOverlay(
        isLoading: loginState.isLoading,
        child: Container(
          height: size.height,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: AppColors.primaryGradient,
            ),
          ),
          child: SafeArea(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 20,
                bottom: keyboardHeight > 0 ? 20 : 40,
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Logo and Welcome Section
                      AnimationConfiguration.staggeredList(
                        position: 0,
                        duration: const Duration(milliseconds: 800),
                        child: SlideAnimation(
                          verticalOffset: 50,
                          child: FadeInAnimation(child: _buildWelcomeSection()),
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Login Form Card
                      AnimationConfiguration.staggeredList(
                        position: 1,
                        duration: const Duration(milliseconds: 1000),
                        child: SlideAnimation(
                          verticalOffset: 80,
                          child: FadeInAnimation(child: _buildLoginCard()),
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Social Login Section
                      AnimationConfiguration.staggeredList(
                        position: 2,
                        duration: const Duration(milliseconds: 1200),
                        child: SlideAnimation(
                          verticalOffset: 50,
                          child: FadeInAnimation(
                            child: _buildSocialLoginSection(),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Sign Up Link
                      AnimationConfiguration.staggeredList(
                        position: 3,
                        duration: const Duration(milliseconds: 1400),
                        child: SlideAnimation(
                          verticalOffset: 30,
                          child: FadeInAnimation(child: _buildSignUpLink()),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Column(
      children: [
        // App Logo
        Container(
          height: 120,
          width: 120,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
          ),
          child: const Icon(
            Icons.chat_bubble_rounded,
            size: 60,
            color: Colors.white,
          ),
        ),

        const SizedBox(height: 24),

        // Welcome Text
        Text(
          'Welcome Back',
          style: GoogleFonts.poppins(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          'Sign in to continue your conversations',
          style: GoogleFonts.roboto(
            fontSize: 16,
            color: Colors.white.withOpacity(0.9),
            fontWeight: FontWeight.w400,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLoginCard() {
    final loginState = ref.watch(loginFormProvider);

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Email Field
          AnimationConfiguration.staggeredList(
            position: 0,
            duration: const Duration(milliseconds: 600),
            child: SlideAnimation(
              horizontalOffset: 30,
              child: FadeInAnimation(
                child: CustomTextField(
                  controller: _emailController,
                  labelText: 'Email Address',
                  hintText: 'Enter your email',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (value) =>
                      ref.read(loginFormProvider.notifier).updateEmail(value),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(
                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                    ).hasMatch(value)) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Password Field
          AnimationConfiguration.staggeredList(
            position: 1,
            duration: const Duration(milliseconds: 800),
            child: SlideAnimation(
              horizontalOffset: 30,
              child: FadeInAnimation(
                child: CustomTextField(
                  controller: _passwordController,
                  labelText: 'Password',
                  hintText: 'Enter your password',
                  prefixIcon: Icons.lock_outlined,
                  obscureText: loginState.obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      loginState.obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: () => ref
                        .read(loginFormProvider.notifier)
                        .togglePasswordVisibility(),
                  ),
                  onChanged: (value) => ref
                      .read(loginFormProvider.notifier)
                      .updatePassword(value),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                  onFieldSubmitted: (_) => _handleLogin(),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Remember Me & Forgot Password Row
          AnimationConfiguration.staggeredList(
            position: 2,
            duration: const Duration(milliseconds: 1000),
            child: SlideAnimation(
              horizontalOffset: 20,
              child: FadeInAnimation(
                child: Row(
                  children: [
                    // Remember Me Checkbox
                    Transform.scale(
                      scale: 0.9,
                      child: Checkbox(
                        value: loginState.rememberMe,
                        onChanged: (_) => ref
                            .read(loginFormProvider.notifier)
                            .toggleRememberMe(),
                        activeColor: AppColors.primaryGreen,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    Text(
                      'Remember me',
                      style: GoogleFonts.roboto(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const Spacer(),
                    // Forgot Password Link
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        'Forgot Password?',
                        style: GoogleFonts.roboto(
                          fontSize: 14,
                          color: AppColors.primaryGreen,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Error Message
          if (loginState.errorMessage != null) ...[
            const SizedBox(height: 12),
            AnimationConfiguration.staggeredList(
              position: 3,
              duration: const Duration(milliseconds: 600),
              child: SlideAnimation(
                verticalOffset: 20,
                child: FadeInAnimation(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.errorRed.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.errorRed.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: AppColors.errorRed,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            loginState.errorMessage!,
                            style: GoogleFonts.roboto(
                              fontSize: 13,
                              color: AppColors.errorRed,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],

          const SizedBox(height: 24),

          // Login Button
          AnimationConfiguration.staggeredList(
            position: 4,
            duration: const Duration(milliseconds: 1200),
            child: SlideAnimation(
              verticalOffset: 30,
              child: FadeInAnimation(
                child: button.CustomButton(
                  text: 'Sign In',
                  onPressed: _handleLogin,
                  isLoading: loginState.isLoading,
                  icon: Icons.login_rounded,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialLoginSection() {
    return Column(
      children: [
        // Divider with "OR" text
        Row(
          children: [
            const Expanded(child: Divider(color: Colors.white54, thickness: 1)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'OR',
                style: GoogleFonts.roboto(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Expanded(child: Divider(color: Colors.white54, thickness: 1)),
          ],
        ),

        const SizedBox(height: 24),

        // Google Sign In Button
        AnimationConfiguration.staggeredList(
          position: 0,
          duration: const Duration(milliseconds: 800),
          child: SlideAnimation(
            horizontalOffset: 50,
            child: FadeInAnimation(
              child: _buildSocialButton(
                onPressed: _handleGoogleSignIn,
                icon: Icons.g_mobiledata_rounded,
                text: 'Continue with Google',
                backgroundColor: Colors.white,
                textColor: AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String text,
    required Color backgroundColor,
    required Color textColor,
  }) {
    return Container(
      width: double.infinity,
      height: 54,
      margin: const EdgeInsets.only(bottom: 12),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 24),
        label: Text(
          text,
          style: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          elevation: 2,
          shadowColor: Colors.black26,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildSignUpLink() {
    return Center(
      child: RichText(
        text: TextSpan(
          text: "Don't have an account? ",
          style: GoogleFonts.roboto(
            fontSize: 16,
            color: Colors.white.withOpacity(0.9),
          ),
          children: [
            WidgetSpan(
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pushNamed(AppRouter.signup);
                },
                child: Text(
                  'Sign Up',
                  style: GoogleFonts.roboto(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
