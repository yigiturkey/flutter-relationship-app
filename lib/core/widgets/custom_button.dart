import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_fonts.dart';

enum ButtonType {
  primary,
  secondary,
  outline,
  text,
}

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonType type;
  final bool isLoading;
  final bool isFullWidth;
  final double? width;
  final double? height;
  final Widget? icon;
  final EdgeInsetsGeometry? padding;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = ButtonType.primary,
    this.isLoading = false,
    this.isFullWidth = false,
    this.width,
    this.height,
    this.icon,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    Widget button;

    switch (type) {
      case ButtonType.primary:
        button = _buildPrimaryButton(context);
        break;
      case ButtonType.secondary:
        button = _buildSecondaryButton(context);
        break;
      case ButtonType.outline:
        button = _buildOutlineButton(context);
        break;
      case ButtonType.text:
        button = _buildTextButton(context);
        break;
    }

    if (isFullWidth) {
      return SizedBox(
        width: double.infinity,
        height: height ?? 50,
        child: button,
      );
    }

    return SizedBox(
      width: width,
      height: height ?? 50,
      child: button,
    );
  }

  Widget _buildPrimaryButton(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        disabledBackgroundColor: AppColors.primary.withOpacity(0.6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        elevation: 0,
      ),
      child: _buildButtonContent(),
    );
  }

  Widget _buildSecondaryButton(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.white,
        disabledBackgroundColor: AppColors.secondary.withOpacity(0.6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        elevation: 0,
      ),
      child: _buildButtonContent(),
    );
  }

  Widget _buildOutlineButton(BuildContext context) {
    return OutlinedButton(
      onPressed: isLoading ? null : onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      ),
      child: _buildButtonContent(),
    );
  }

  Widget _buildTextButton(BuildContext context) {
    return TextButton(
      onPressed: isLoading ? null : onPressed,
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      child: _buildButtonContent(),
    );
  }

  Widget _buildButtonContent() {
    if (isLoading) {
      return const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon!,
          const SizedBox(width: 8),
          Text(
            text,
            style: AppFonts.button,
          ),
        ],
      );
    }

    return Text(
      text,
      style: AppFonts.button,
    );
  }
}