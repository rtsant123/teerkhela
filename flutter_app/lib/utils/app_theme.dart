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

  // Gradients (Enhanced for professional look)
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6), Color(0xFF9333EA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.5, 1.0],
  );

  static const LinearGradient premiumGradient = LinearGradient(
    colors: [Color(0xFF9333EA), Color(0xFFC026D3), Color(0xFFD946EF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.6, 1.0],
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF059669), Color(0xFF047857)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.5, 1.0],
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFFFD700), Color(0xFFFFA500), Color(0xFFFF8C00)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.5, 1.0],
  );

  static const LinearGradient numberGradient = LinearGradient(
    colors: [Color(0xFF4F46E5), Color(0xFF6366F1), Color(0xFF818CF8)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [0.0, 0.5, 1.0],
  );

  // FR/SR Specific Gradients (Professional & Distinct)
  static const LinearGradient frGradient = LinearGradient(
    colors: [Color(0xFF4F46E5), Color(0xFF3B82F6), Color(0xFF2563EB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.5, 1.0],
  );

  static const LinearGradient srGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF059669), Color(0xFF047857)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.5, 1.0],
  );

  // PROFESSIONAL NUMBER SIZING - MAX 3.5% of screen width
  static double numberSize(double screenWidth) => screenWidth * 0.035; // 3.5%
  static double numberSizeSmall(double screenWidth) => screenWidth * 0.03; // 3%
  static double numberSizeLarge(double screenWidth) => screenWidth * 0.04; // 4% max

  // ICON SIZING CONSTANTS (Consistent across app)
  static double iconSmall(double screenWidth) => screenWidth * 0.04; // 4%
  static double iconMedium(double screenWidth) => screenWidth * 0.05; // 5%
  static double iconLarge(double screenWidth) => screenWidth * 0.06; // 6%

  // OPACITY LEVELS (Consistent transparency)
  static const double opacityHigh = 0.12;
  static const double opacityMedium = 0.08;
  static const double opacityLow = 0.05;
  static const double opacityDisabled = 0.38;

  // Shadows (Professional depth - Enhanced for premium look)
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Color(0xFF000000).withOpacity(0.08),
      blurRadius: 16,
      offset: Offset(0, 4),
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color(0xFF000000).withOpacity(0.04),
      blurRadius: 8,
      offset: Offset(0, 2),
      spreadRadius: 0,
    ),
  ];

  static List<BoxShadow> get elevatedShadow => [
    BoxShadow(
      color: Color(0xFF000000).withOpacity(0.12),
      blurRadius: 32,
      offset: Offset(0, 12),
      spreadRadius: -4,
    ),
    BoxShadow(
      color: Color(0xFF000000).withOpacity(0.06),
      blurRadius: 16,
      offset: Offset(0, 6),
      spreadRadius: 0,
    ),
  ];

  static List<BoxShadow> buttonShadow(Color color) => [
    BoxShadow(
      color: color.withOpacity(0.35),
      blurRadius: 16,
      offset: Offset(0, 6),
      spreadRadius: 0,
    ),
    BoxShadow(
      color: color.withOpacity(0.15),
      blurRadius: 8,
      offset: Offset(0, 2),
      spreadRadius: 0,
    ),
  ];

  // Number chip shadow for predictions
  static List<BoxShadow> get numberChipShadow => [
    BoxShadow(
      color: primary.withOpacity(0.3),
      blurRadius: 12,
      offset: Offset(0, 4),
      spreadRadius: 0,
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

  // Dark Theme Colors
  static const Color darkBackground = Color(0xFF1a1a1a); // #1a1a1a
  static const Color darkSurface = Color(0xFF262626); // #262626
  static const Color darkCard = Color(0xFF2d2d2d); // #2d2d2d
  static const Color darkSurfaceVariant = Color(0xFF333333);

  static const Color darkTextPrimary = Color(0xFFffffff); // #ffffff
  static const Color darkTextSecondary = Color(0xFFb0b0b0); // #b0b0b0
  static const Color darkTextTertiary = Color(0xFF808080);

  // Dark Mode Gradients (slightly muted)
  static const LinearGradient darkPrimaryGradient = LinearGradient(
    colors: [Color(0xFF5558E8), Color(0xFF7850E8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkPremiumGradient = LinearGradient(
    colors: [Color(0xFF8428D9), Color(0xFFB020C5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkSuccessGradient = LinearGradient(
    colors: [Color(0xFF0E9F75), Color(0xFF048558)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Dark Mode Shadows
  static List<BoxShadow> get darkCardShadow => [
    BoxShadow(
      color: Color(0xFF000000).withOpacity(0.3),
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
    BoxShadow(
      color: Color(0xFF000000).withOpacity(0.15),
      blurRadius: 6,
      offset: Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get darkElevatedShadow => [
    BoxShadow(
      color: Color(0xFF000000).withOpacity(0.4),
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
  ];

  static List<BoxShadow> darkButtonShadow(Color color) => [
    BoxShadow(
      color: color.withOpacity(0.3),
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ];

  // Dark Mode System UI Overlay Style
  static SystemUiOverlayStyle get darkSystemUiOverlayStyle => SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: darkSurface,
    systemNavigationBarIconBrightness: Brightness.light,
  );

  // Dark Theme Data
  static ThemeData darkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: primary,
      scaffoldBackgroundColor: darkBackground,
      cardColor: darkCard,
      dividerColor: darkSurfaceVariant,

      // Color Scheme
      colorScheme: ColorScheme.dark(
        primary: primary,
        secondary: secondary,
        surface: darkSurface,
        background: darkBackground,
        error: error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: darkTextPrimary,
        onBackground: darkTextPrimary,
        onError: Colors.white,
      ),

      // AppBar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: darkSurface,
        elevation: 0,
        iconTheme: IconThemeData(color: darkTextPrimary),
        titleTextStyle: TextStyle(
          color: darkTextPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: darkCard,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
      ),

      // Icon Theme
      iconTheme: IconThemeData(
        color: darkTextSecondary,
      ),

      // Text Theme
      textTheme: TextTheme(
        displayLarge: heading1.copyWith(color: darkTextPrimary),
        displayMedium: heading2.copyWith(color: darkTextPrimary),
        displaySmall: heading3.copyWith(color: darkTextPrimary),
        headlineMedium: subtitle1.copyWith(color: darkTextPrimary),
        bodyLarge: bodyLarge.copyWith(color: darkTextPrimary),
        bodyMedium: bodyMedium.copyWith(color: darkTextPrimary),
        bodySmall: bodySmall.copyWith(color: darkTextSecondary),
        labelSmall: caption.copyWith(color: darkTextTertiary),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide(color: darkSurfaceVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide(color: darkSurfaceVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide(color: primary, width: 2),
        ),
        labelStyle: TextStyle(color: darkTextSecondary),
        hintStyle: TextStyle(color: darkTextTertiary),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: Colors.black.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
          padding: EdgeInsets.symmetric(vertical: space12, horizontal: space16),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
        ),
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: darkSurface,
        selectedItemColor: primary,
        unselectedItemColor: darkTextSecondary,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
      ),

      // Drawer Theme
      drawerTheme: DrawerThemeData(
        backgroundColor: darkSurface,
      ),

      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: darkCard,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
        ),
      ),

      // Switch Theme
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return primary;
          }
          return darkTextSecondary;
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return primary.withOpacity(0.5);
          }
          return darkSurfaceVariant;
        }),
      ),

      // Divider Theme
      dividerTheme: DividerThemeData(
        color: darkSurfaceVariant,
        thickness: 1,
      ),
    );
  }
}
