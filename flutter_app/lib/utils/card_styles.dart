import 'package:flutter/material.dart';
import 'app_theme.dart';

/// Professional card and text styles for consistent UI
class CardStyles {
  // Primary Card - For main content
  static BoxDecoration primaryCard({double borderRadius = 16}) {
    return BoxDecoration(
      color: AppTheme.cardBackground,
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
        BoxShadow(
          color: Colors.black.withOpacity(0.02),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ],
      border: Border.all(
        color: AppTheme.textSecondary.withOpacity(0.08),
        width: 1,
      ),
    );
  }

  // Elevated Card - For important content
  static BoxDecoration elevatedCard({double borderRadius = 16}) {
    return BoxDecoration(
      color: AppTheme.cardBackground,
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: [
        BoxShadow(
          color: AppTheme.primary.withOpacity(0.08),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
      border: Border.all(
        color: AppTheme.primary.withOpacity(0.15),
        width: 1.5,
      ),
    );
  }

  // Premium Card - For premium features
  static BoxDecoration premiumCard({double borderRadius = 16}) {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: [
          AppTheme.premiumPurple.withOpacity(0.05),
          AppTheme.premiumGold.withOpacity(0.05),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: [
        BoxShadow(
          color: AppTheme.premiumPurple.withOpacity(0.15),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ],
      border: Border.all(
        color: AppTheme.premiumPurple.withOpacity(0.3),
        width: 1.5,
      ),
    );
  }

  // Success Card - For positive content
  static BoxDecoration successCard({double borderRadius = 16}) {
    return BoxDecoration(
      color: AppTheme.success.withOpacity(0.05),
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: [
        BoxShadow(
          color: AppTheme.success.withOpacity(0.1),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
      border: Border.all(
        color: AppTheme.success.withOpacity(0.3),
        width: 1.5,
      ),
    );
  }

  // Info Card - For informational content
  static BoxDecoration infoCard({double borderRadius = 12}) {
    return BoxDecoration(
      color: AppTheme.info.withOpacity(0.08),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: AppTheme.info.withOpacity(0.25),
        width: 1,
      ),
    );
  }

  // Warning Card - For warnings
  static BoxDecoration warningCard({double borderRadius = 12}) {
    return BoxDecoration(
      color: AppTheme.warning.withOpacity(0.08),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: AppTheme.warning.withOpacity(0.3),
        width: 1,
      ),
    );
  }

  // Standard padding for cards
  static EdgeInsets get cardPadding => const EdgeInsets.all(16);
  static EdgeInsets get cardPaddingLarge => const EdgeInsets.all(20);
  static EdgeInsets get cardPaddingSmall => const EdgeInsets.all(12);
}

/// Professional text styles
class TextStyles {
  // Display text (largest)
  static TextStyle display(Size size, {Color? color}) {
    return TextStyle(
      fontSize: size.width * 0.07,
      fontWeight: FontWeight.bold,
      color: color ?? AppTheme.textPrimary,
      height: 1.2,
      letterSpacing: -0.5,
    );
  }

  // Heading 1
  static TextStyle h1(Size size, {Color? color}) {
    return TextStyle(
      fontSize: size.width * 0.06,
      fontWeight: FontWeight.bold,
      color: color ?? AppTheme.textPrimary,
      height: 1.3,
      letterSpacing: -0.3,
    );
  }

  // Heading 2
  static TextStyle h2(Size size, {Color? color}) {
    return TextStyle(
      fontSize: size.width * 0.05,
      fontWeight: FontWeight.bold,
      color: color ?? AppTheme.textPrimary,
      height: 1.3,
    );
  }

  // Heading 3
  static TextStyle h3(Size size, {Color? color}) {
    return TextStyle(
      fontSize: size.width * 0.045,
      fontWeight: FontWeight.w600,
      color: color ?? AppTheme.textPrimary,
      height: 1.4,
    );
  }

  // Subtitle
  static TextStyle subtitle(Size size, {Color? color}) {
    return TextStyle(
      fontSize: size.width * 0.04,
      fontWeight: FontWeight.w600,
      color: color ?? AppTheme.textPrimary,
      height: 1.4,
    );
  }

  // Body text
  static TextStyle body(Size size, {Color? color}) {
    return TextStyle(
      fontSize: size.width * 0.038,
      fontWeight: FontWeight.w400,
      color: color ?? AppTheme.textPrimary,
      height: 1.5,
    );
  }

  // Body text medium
  static TextStyle bodyMedium(Size size, {Color? color}) {
    return TextStyle(
      fontSize: size.width * 0.036,
      fontWeight: FontWeight.w500,
      color: color ?? AppTheme.textPrimary,
      height: 1.5,
    );
  }

  // Small text
  static TextStyle small(Size size, {Color? color}) {
    return TextStyle(
      fontSize: size.width * 0.032,
      fontWeight: FontWeight.w400,
      color: color ?? AppTheme.textSecondary,
      height: 1.4,
    );
  }

  // Caption text (smallest)
  static TextStyle caption(Size size, {Color? color}) {
    return TextStyle(
      fontSize: size.width * 0.028,
      fontWeight: FontWeight.w400,
      color: color ?? AppTheme.textSecondary,
      height: 1.3,
    );
  }

  // Button text
  static TextStyle button(Size size, {Color? color}) {
    return TextStyle(
      fontSize: size.width * 0.04,
      fontWeight: FontWeight.bold,
      color: color ?? Colors.white,
      letterSpacing: 0.5,
    );
  }

  // Number display (for Teer numbers) - FIXED: Smaller, more professional
  static TextStyle number(Size size, {Color? color, bool isLarge = false}) {
    return TextStyle(
      fontSize: isLarge ? size.width * 0.055 : size.width * 0.038,
      fontWeight: FontWeight.bold,
      color: color ?? AppTheme.textPrimary,
      fontFamily: 'monospace',
    );
  }
}

/// Number chip widget for displaying Teer numbers
class NumberChip extends StatelessWidget {
  final String number;
  final Size size;
  final Color? color;
  final bool isHighlighted;
  final VoidCallback? onTap;

  const NumberChip({
    super.key,
    required this.number,
    required this.size,
    this.color,
    this.isHighlighted = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: size.width * 0.028,
          vertical: size.width * 0.015,
        ),
        decoration: BoxDecoration(
          gradient: isHighlighted
              ? AppTheme.primaryGradient
              : null,
          color: !isHighlighted
              ? (color ?? AppTheme.primary).withOpacity(0.1)
              : null,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isHighlighted
                ? AppTheme.primary
                : (color ?? AppTheme.primary).withOpacity(0.3),
            width: isHighlighted ? 1.5 : 1,
          ),
          boxShadow: isHighlighted
              ? [
                  BoxShadow(
                    color: AppTheme.primary.withOpacity(0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          number,
          style: TextStyle(
            color: isHighlighted
                ? Colors.white
                : (color ?? AppTheme.textPrimary),
            fontWeight: FontWeight.bold,
            fontSize: size.width * 0.035,
            fontFamily: 'monospace',
          ),
        ),
      ),
    );
  }
}

/// Section header widget
class SectionHeader extends StatelessWidget {
  final String title;
  final Size size;
  final IconData? icon;
  final Widget? action;

  const SectionHeader({
    super.key,
    required this.title,
    required this.size,
    this.icon,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: size.width * 0.03),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              color: AppTheme.primary,
              size: size.width * 0.055,
            ),
            SizedBox(width: size.width * 0.025),
          ],
          Expanded(
            child: Text(
              title,
              style: TextStyles.h3(size),
            ),
          ),
          if (action != null) action!,
        ],
      ),
    );
  }
}
