// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/utils/app_router.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/custom_button.dart' as button;
import '../../../shared/widgets/loading_overlay.dart';

final signupFormProvider =
    StateNotifierProvider<SignupFormNotifier, SignupFormState>((ref) {
      return SignupFormNotifier();
    });

class SignupFormState {
  final String name;
  final String email;
  final String password;
  final String confirmPassword;
  final bool isLoading;
  final String? error;
  final bool obscurePassword;
  final bool obscureConfirmPassword;
  final bool acceptTerms;

  const SignupFormState({
    this.name = '',
    this.email = '',
    this.password = '',
    this.confirmPassword = '',
    this.isLoading = false,
    this.error,
    this.obscurePassword = true,
    this.obscureConfirmPassword = true,
    this.acceptTerms = false,
  });

  SignupFormState copyWith({
    String? name,
    String? email,
    String? password,
    String? confirmPassword,
    bool? isLoading,
    String? error,
    bool? obscurePassword,
    bool? obscureConfirmPassword,
    bool? acceptTerms,
  }) {
    return SignupFormState(
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      obscurePassword: obscurePassword ?? this.obscurePassword,
      obscureConfirmPassword:
          obscureConfirmPassword ?? this.obscureConfirmPassword,
      acceptTerms: acceptTerms ?? this.acceptTerms,
    );
  }
}

class SignupFormNotifier extends StateNotifier<SignupFormState> {
  SignupFormNotifier() : super(const SignupFormState());

  void updateName(String name) {
    state = state.copyWith(name: name, error: null);
  }

  void updateEmail(String email) {
    state = state.copyWith(email: email, error: null);
  }

  void updatePassword(String password) {
    state = state.copyWith(password: password, error: null);
  }

  void updateConfirmPassword(String confirmPassword) {
    state = state.copyWith(confirmPassword: confirmPassword, error: null);
  }

  void togglePasswordVisibility() {
    state = state.copyWith(obscurePassword: !state.obscurePassword);
  }

  void toggleConfirmPasswordVisibility() {
    state = state.copyWith(
      obscureConfirmPassword: !state.obscureConfirmPassword,
    );
  }

  void toggleAcceptTerms() {
    state = state.copyWith(acceptTerms: !state.acceptTerms);
  }

  void setError(String error) {
    state = state.copyWith(error: error, isLoading: false);
  }

  void setLoading(bool isLoading) {
    state = state.copyWith(isLoading: isLoading, error: null);
  }
}

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  late AnimationController _animationController;

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
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;

    final signupState = ref.read(signupFormProvider);
    if (!signupState.acceptTerms) {
      ref
          .read(signupFormProvider.notifier)
          .setError('Please accept the Terms and Conditions');
      return;
    }

    final signupNotifier = ref.read(signupFormProvider.notifier);
    final authService = ref.read(authServiceProvider);

    signupNotifier.setLoading(true);

    try {
      await authService.signUpWithEmailAndPassword(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (mounted) {
        Navigator.of(context).pushReplacementNamed(AppRouter.profileSetup);
      }
    } catch (e) {
      signupNotifier.setError(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final signupState = ref.watch(signupFormProvider);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios_rounded),
        ),
      ),
      body: LoadingOverlay(
        isLoading: signupState.isLoading,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: AnimationLimiter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header Section
                    AnimationConfiguration.staggeredList(
                      position: 0,
                      duration: const Duration(milliseconds: 1500),
                      child: SlideAnimation(
                        verticalOffset: 50.0,
                        child: FadeInAnimation(
                          child: Column(
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: AppColors.primaryGradient,
                                  ),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primaryGreen.withOpacity(
                                        0.3,
                                      ),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.person_add_rounded,
                                  size: 40,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'Create Account',
                                style: GoogleFonts.poppins(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w700,
                                  color: Theme.of(
                                    context,
                                  ).textTheme.headlineLarge?.color,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Join Talkative and connect with people',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.color
                                      ?.withOpacity(0.7),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: size.height * 0.04),

                    // Name Field
                    AnimationConfiguration.staggeredList(
                      position: 1,
                      duration: const Duration(milliseconds: 1500),
                      child: SlideAnimation(
                        verticalOffset: 50.0,
                        child: FadeInAnimation(
                          child: CustomTextField(
                            controller: _nameController,
                            hintText: 'Enter your full name',
                            labelText: 'Full Name',
                            keyboardType: TextInputType.name,
                            textCapitalization: TextCapitalization.words,
                            prefixIcon: Icons.person_outlined,
                            onChanged: ref
                                .read(signupFormProvider.notifier)
                                .updateName,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your name';
                              }
                              if (value.length < 2) {
                                return 'Name must be at least 2 characters';
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Email Field
                    AnimationConfiguration.staggeredList(
                      position: 2,
                      duration: const Duration(milliseconds: 1500),
                      child: SlideAnimation(
                        verticalOffset: 50.0,
                        child: FadeInAnimation(
                          child: CustomTextField(
                            controller: _emailController,
                            hintText: 'Enter your email',
                            labelText: 'Email',
                            keyboardType: TextInputType.emailAddress,
                            prefixIcon: Icons.email_outlined,
                            onChanged: ref
                                .read(signupFormProvider.notifier)
                                .updateEmail,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
                              }
                              if (!RegExp(
                                AppConstants.emailPattern,
                              ).hasMatch(value)) {
                                return 'Please enter a valid email';
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
                      position: 3,
                      duration: const Duration(milliseconds: 1500),
                      child: SlideAnimation(
                        verticalOffset: 50.0,
                        child: FadeInAnimation(
                          child: CustomTextField(
                            controller: _passwordController,
                            hintText: 'Enter your password',
                            labelText: 'Password',
                            obscureText: signupState.obscurePassword,
                            prefixIcon: Icons.lock_outlined,
                            suffixIcon: IconButton(
                              icon: Icon(
                                signupState.obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                              onPressed: ref
                                  .read(signupFormProvider.notifier)
                                  .togglePasswordVisibility,
                            ),
                            onChanged: ref
                                .read(signupFormProvider.notifier)
                                .updatePassword,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your password';
                              }
                              if (value.length <
                                  AppConstants.minPasswordLength) {
                                return 'Password must be at least ${AppConstants.minPasswordLength} characters';
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Confirm Password Field
                    AnimationConfiguration.staggeredList(
                      position: 4,
                      duration: const Duration(milliseconds: 1500),
                      child: SlideAnimation(
                        verticalOffset: 50.0,
                        child: FadeInAnimation(
                          child: CustomTextField(
                            controller: _confirmPasswordController,
                            hintText: 'Confirm your password',
                            labelText: 'Confirm Password',
                            obscureText: signupState.obscureConfirmPassword,
                            prefixIcon: Icons.lock_outlined,
                            suffixIcon: IconButton(
                              icon: Icon(
                                signupState.obscureConfirmPassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                              onPressed: ref
                                  .read(signupFormProvider.notifier)
                                  .toggleConfirmPasswordVisibility,
                            ),
                            onChanged: ref
                                .read(signupFormProvider.notifier)
                                .updateConfirmPassword,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please confirm your password';
                              }
                              if (value != _passwordController.text) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Terms and Conditions
                    AnimationConfiguration.staggeredList(
                      position: 5,
                      duration: const Duration(milliseconds: 1500),
                      child: SlideAnimation(
                        verticalOffset: 30.0,
                        child: FadeInAnimation(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Checkbox(
                                value: signupState.acceptTerms,
                                onChanged: (value) {
                                  ref
                                      .read(signupFormProvider.notifier)
                                      .toggleAcceptTerms();
                                },
                                activeColor: AppColors.primaryGreen,
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 12),
                                  child: Text.rich(
                                    TextSpan(
                                      text: 'I agree to the ',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.color
                                            ?.withOpacity(0.7),
                                      ),
                                      children: [
                                        TextSpan(
                                          text: 'Terms and Conditions',
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.primaryGreen,
                                          ),
                                        ),
                                        TextSpan(
                                          text: ' and ',
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            color: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.color
                                                ?.withOpacity(0.7),
                                          ),
                                        ),
                                        TextSpan(
                                          text: 'Privacy Policy',
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.primaryGreen,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Error Message
                    if (signupState.error != null)
                      AnimationConfiguration.staggeredList(
                        position: 6,
                        duration: const Duration(milliseconds: 1500),
                        child: SlideAnimation(
                          verticalOffset: 30.0,
                          child: FadeInAnimation(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              margin: const EdgeInsets.only(bottom: 20),
                              decoration: BoxDecoration(
                                color: AppColors.error.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppColors.error.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    color: AppColors.error,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      signupState.error!,
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: AppColors.error,
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

                    const SizedBox(height: 32),

                    // Sign Up Button
                    AnimationConfiguration.staggeredList(
                      position: 7,
                      duration: const Duration(milliseconds: 1500),
                      child: SlideAnimation(
                        verticalOffset: 50.0,
                        child: FadeInAnimation(
                          child: button.CustomButton(
                            text: 'Create Account',
                            onPressed: _handleSignup,
                            isLoading: signupState.isLoading,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: size.height * 0.04),

                    // Sign In Link
                    AnimationConfiguration.staggeredList(
                      position: 8,
                      duration: const Duration(milliseconds: 1500),
                      child: SlideAnimation(
                        verticalOffset: 30.0,
                        child: FadeInAnimation(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Already have an account? ',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.color
                                      ?.withOpacity(0.7),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text(
                                  'Sign In',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primaryGreen,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
