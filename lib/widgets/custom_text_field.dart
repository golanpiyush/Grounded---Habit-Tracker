import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

enum TextFieldType { email, password, text }

class CustomTextField extends StatefulWidget {
  final String label;
  final String? hintText;
  final TextFieldType type;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final bool showValidationIcon;
  final bool autofocus;
  final TextInputAction? textInputAction;
  final void Function(String)? onSubmitted;

  const CustomTextField({
    Key? key,
    required this.label,
    this.hintText,
    this.type = TextFieldType.text,
    this.controller,
    this.validator,
    this.onChanged,
    this.showValidationIcon = false,
    this.autofocus = false,
    this.textInputAction,
    this.onSubmitted,
  }) : super(key: key);

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = true;
  bool _hasFocus = false;
  String? _errorText;

  @override
  Widget build(BuildContext context) {
    final isPassword = widget.type == TextFieldType.password;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label Text
        Text(
          widget.label,
          style: AppTextStyles.bodyMedium(
            context,
          ).copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),

        // Text Field
        Focus(
          onFocusChange: (hasFocus) {
            setState(() => _hasFocus = hasFocus);
            if (!hasFocus && widget.controller?.text.isNotEmpty == true) {
              _validate();
            }
          },
          child: TextFormField(
            controller: widget.controller,
            obscureText: isPassword && _obscureText,
            autofocus: widget.autofocus,
            textInputAction: widget.textInputAction,
            onFieldSubmitted: widget.onSubmitted,
            style: AppTextStyles.bodyMedium(
              context,
            ).copyWith(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: AppTextStyles.bodySmall(
                context,
              ).copyWith(color: AppColors.textSecondary),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.borderColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.primaryGreen,
                  width: 1.5,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.errorRed),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.errorRed,
                  width: 1.5,
                ),
              ),
              suffixIcon: _buildSuffixIcon(),
              errorText: _errorText,
            ),
            onChanged: (value) {
              widget.onChanged?.call(value);
              if (_hasFocus) setState(() => _errorText = null);
            },
          ),
        ),
      ],
    );
  }

  Widget? _buildSuffixIcon() {
    final controller = widget.controller;

    // Password visibility toggle
    if (widget.type == TextFieldType.password) {
      return IconButton(
        icon: Icon(
          _obscureText
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined,
          color: _hasFocus ? AppColors.primaryGreen : AppColors.textSecondary,
        ),
        onPressed: () => setState(() => _obscureText = !_obscureText),
      );
    }

    // Validation icon (✔ / ❌)
    if (widget.showValidationIcon && controller?.text.isNotEmpty == true) {
      final isValid = widget.validator?.call(controller!.text) == null;
      return Icon(
        isValid ? Icons.check_circle_rounded : Icons.error_rounded,
        color: isValid ? AppColors.successGreen : AppColors.errorRed,
        size: 20,
      );
    }

    return null;
  }

  void _validate() {
    if (widget.validator != null &&
        widget.controller?.text.isNotEmpty == true) {
      setState(() {
        _errorText = widget.validator!(widget.controller!.text);
      });
    }
  }
}
