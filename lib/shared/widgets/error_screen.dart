// ignore_for_file: unused_import, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import '../../core/constants/app_colors.dart';

class ErrorScreen extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final IconData? icon;
  final String? title;
  final String? buttonText;

  const ErrorScreen({
    super.key,
    required this.message,
    this.onRetry,
    this.icon,
    this.title,
    this.buttonText,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Error Icon or Animation
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon ?? Icons.error_outline,
                  size: 60,
                  color: AppColors.error,
                ),
              ),

              const SizedBox(height: 32),

              // Error Title
              Text(
                title ?? 'Oops! Something went wrong',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.headlineMedium?.color,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // Error Message
              Text(
                message,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.color?.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              // Retry Button
              if (onRetry != null)
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: onRetry,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: Text(
                      buttonText ?? 'Try Again',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class NoInternetScreen extends StatelessWidget {
  final VoidCallback? onRetry;

  const NoInternetScreen({super.key, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return ErrorScreen(
      icon: Icons.wifi_off,
      title: 'No Internet Connection',
      message: 'Please check your internet connection and try again.',
      onRetry: onRetry,
      buttonText: 'Retry',
    );
  }
}

class EmptyScreen extends StatelessWidget {
  final String message;
  final IconData? icon;
  final String? title;
  final VoidCallback? onAction;
  final String? actionText;

  const EmptyScreen({
    super.key,
    required this.message,
    this.icon,
    this.title,
    this.onAction,
    this.actionText,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Empty Icon
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.textHint.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon ?? Icons.inbox_outlined,
                size: 50,
                color: AppColors.textHint,
              ),
            ),

            const SizedBox(height: 24),

            // Empty Title
            if (title != null)
              Text(
                title!,
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.headlineSmall?.color,
                ),
                textAlign: TextAlign.center,
              ),

            if (title != null) const SizedBox(height: 12),

            // Empty Message
            Text(
              message,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: AppColors.textHint,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            // Action Button
            if (onAction != null && actionText != null)
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  actionText!,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
