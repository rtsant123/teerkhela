import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  // Professional Modern Color Palette
  static const Color primary = Color(0xFF6366F1); // Indigo-500
  static const Color primaryDark = Color(0xFF4F46E5); // Indigo-600
  static const Color primaryLight = Color(0xFF818CF8); // Indigo-400

  static const Color secondary = Color(0xFF10B981); // Emerald-500
  static const Color secondaryDark = Color(0xFF059669);

  static const Color accent = Color(0xFFF59E0B); // Amber-500

  static const Color background = Color(0xFFF9FAFB); // Gray-50
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF3F4F6);

  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);

  // Premium Colors
  static const Color premiumGold = Color(0xFFFFD700);
  static const Color premiumPurple = Color(0xFF9333EA);

  // Result Colors
  static const Color frColor = Color(0xFF3B82F6); // Blue-500
  static const Color srColor = Color(0xFF10B981); // Emerald-500

  // Status
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient premiumGradient = LinearGradient(
    colors: [Color(0xFF9333EA), Color(0xFFC026D3)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Shadows (Professional depth)
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Color(0xFF000000).withOpacity(0.04),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
    BoxShadow(
      color: Color(0xFF000000).withOpacity(0.02),
      blurRadius: 4,
      offset: Offset(0, 1),
    ),
  ];

  static List<BoxShadow> get elevatedShadow => [
    BoxShadow(
      color: Color(0xFF000000).withOpacity(0.1),
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
  ];

  static List<BoxShadow> buttonShadow(Color color) => [
    BoxShadow(
      color: color.withOpacity(0.25),
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ];

  // Border Radius
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 24.0;

  // Spacing
  static const double space4 = 4.0;
  static const double space8 = 8.0;
  static const double space12 = 12.0;
  static const double space16 = 16.0;
  static const double space20 = 20.0;
  static const double space24 = 24.0;
  static const double space32 = 32.0;
  static const double space48 = 48.0;

  // Card Decorations
  static BoxDecoration get cardDecoration => BoxDecoration(
    color: surface,
    borderRadius: BorderRadius.circular(radiusMedium),
    boxShadow: cardShadow,
  );

  static BoxDecoration get elevatedCard => BoxDecoration(
    color: surface,
    borderRadius: BorderRadius.circular(radiusLarge),
    boxShadow: elevatedShadow,
  );

  // Text Styles (Professional Typography)
  static const TextStyle heading1 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: textPrimary,
    height: 1.2,
    letterSpacing: -0.5,
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    height: 1.3,
  );

  static const TextStyle heading3 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    height: 1.4,
  );

  static const TextStyle subtitle1 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: textPrimary,
    height: 1.5,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: textPrimary,
    height: 1.6,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: textPrimary,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: textSecondary,
    height: 1.4,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: textTertiary,
    height: 1.3,
  );

  static const TextStyle buttonText = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.3,
  );

  // Premium Badge
  static Widget premiumBadge({double size = 16}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        gradient: premiumGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: premiumPurple.withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.workspace_premium_rounded, color: Colors.white, size: size),
          const SizedBox(width: 4),
          const Text(
            'PRO',
            style: TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // System UI Overlay Style
  static SystemUiOverlayStyle get systemUiOverlayStyle => SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: surface,
    systemNavigationBarIconBrightness: Brightness.dark,
  );
}
