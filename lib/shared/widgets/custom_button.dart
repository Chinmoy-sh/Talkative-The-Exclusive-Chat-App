// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';

class CustomButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final bool isOutlined;
  final Color? borderColor;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height,
    this.borderRadius,
    this.isOutlined = false,
    this.borderColor,
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _animationController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveBackgroundColor =
        widget.backgroundColor ??
        (widget.isOutlined ? Colors.transparent : AppColors.primaryGreen);
    final effectiveTextColor =
        widget.textColor ??
        (widget.isOutlined ? AppColors.primaryGreen : Colors.white);
    final effectiveBorderColor =
        widget.borderColor ??
        (widget.isOutlined ? AppColors.primaryGreen : Colors.transparent);

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: widget.onPressed != null && !widget.isLoading
                ? _onTapDown
                : null,
            onTapUp: widget.onPressed != null && !widget.isLoading
                ? _onTapUp
                : null,
            onTapCancel: _onTapCancel,
            child: Container(
              width: widget.width ?? double.infinity,
              height: widget.height ?? 50,
              decoration: BoxDecoration(
                color: effectiveBackgroundColor,
                borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
                border: widget.isOutlined
                    ? Border.all(color: effectiveBorderColor, width: 2)
                    : null,
                gradient: !widget.isOutlined && widget.backgroundColor == null
                    ? const LinearGradient(
                        colors: AppColors.primaryGradient,
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      )
                    : null,
                boxShadow:
                    !widget.isOutlined &&
                        widget.onPressed != null &&
                        !widget.isLoading
                    ? [
                        BoxShadow(
                          // ignore: deprecated_member_use
                          color: AppColors.primaryGreen.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.onPressed != null && !widget.isLoading
                      ? widget.onPressed
                      : null,
                  borderRadius:
                      widget.borderRadius ?? BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.isLoading)
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                effectiveTextColor,
                              ),
                            ),
                          )
                        else if (widget.icon != null) ...[
                          Icon(
                            widget.icon,
                            color: effectiveTextColor,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                        ],

                        if (!widget.isLoading)
                          Text(
                            widget.text,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: effectiveTextColor,
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
      },
    );
  }
}
