// custom_button.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

enum ButtonVariant { primary, secondary, text }

class CustomButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final bool isLoading;
  final bool enabled;
  final double? width;
  final double height;
  final Widget? icon;

  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.variant = ButtonVariant.primary,
    this.isLoading = false,
    this.enabled = true,
    this.width,
    this.height = 48.0,
    this.icon,
  }) : super(key: key);

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  bool _isPressed = false;

  Color _getBackgroundColor() {
    if (!widget.enabled || widget.isLoading) {
      return AppColors.borderColor;
    }

    switch (widget.variant) {
      case ButtonVariant.primary:
        return AppColors.primaryButtonColor;
      case ButtonVariant.secondary:
        return AppColors.secondaryButtonColor;
      case ButtonVariant.text:
        return Colors.transparent;
    }
  }

  Color _getTextColor() {
    if (!widget.enabled || widget.isLoading) {
      return AppColors.textSecondary;
    }

    switch (widget.variant) {
      case ButtonVariant.primary:
        return AppColors.primaryButtonTextColor;
      case ButtonVariant.secondary:
        return AppColors.secondaryButtonTextColor;
      case ButtonVariant.text:
        return AppColors.primaryGreen;
    }
  }

  Border? _getBorder() {
    if (widget.variant == ButtonVariant.secondary) {
      return Border.all(
        color: !widget.enabled || widget.isLoading
            ? AppColors.borderColor
            : AppColors.secondaryButtonBorderColor,
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        if (widget.enabled && !widget.isLoading) {
          setState(() => _isPressed = true);
        }
      },
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: () {
        if (widget.enabled && !widget.isLoading && widget.onPressed != null) {
          HapticFeedback.lightImpact();
          widget.onPressed!();
        }
      },
      child: AnimatedScale(
        duration: const Duration(milliseconds: 100),
        scale: _isPressed ? 0.95 : 1.0,
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: _getBackgroundColor(),
            borderRadius: BorderRadius.circular(12),
            border: _getBorder(),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: widget.isLoading ? 0.0 : 1.0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.icon != null) ...[
                      widget.icon!,
                      const SizedBox(width: 8),
                    ],
                    Text(
                      widget.text,
                      style: AppTextStyles.buttonMedium(
                        context,
                      ).copyWith(color: _getTextColor()),
                    ),
                  ],
                ),
              ),
              if (widget.isLoading)
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(_getTextColor()),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
