import 'package:flutter/material.dart';

class AppTheme {
  // Modern Color Palette
  static const Color primary = Color(0xFF0891b2); // Cyan-600
  static const Color primaryDark = Color(0xFF0e7490); // Cyan-700
  static const Color secondary = Color(0xFF4f46e5); // Indigo-600
  static const Color accent = Color(0xFF10b981); // Emerald-500
  static const Color background = Color(0xFFf8fafc); // Slate-50
  static const Color cardBg = Colors.white;
  static const Color textPrimary = Color(0xFF1e293b); // Slate-800
  static const Color textSecondary = Color(0xFF64748b); // Slate-500

  // Premium Colors
  static const Color premiumGold = Color(0xFFf59e0b); // Amber-500
  static const Color premiumGradientStart = Color(0xFFf59e0b);
  static const Color premiumGradientEnd = Color(0xFFd97706);

  // Result Colors
  static const Color frColor = Color(0xFF3b82f6); // Blue-500
  static const Color srColor = Color(0xFF10b981); // Emerald-500

  // Status Colors
  static const Color success = Color(0xFF22c55e); // Green-500
  static const Color warning = Color(0xFFf97316); // Orange-500
  static const Color error = Color(0xFFef4444); // Red-500

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient premiumGradient = LinearGradient(
    colors: [premiumGradientStart, premiumGradientEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Text Styles
  static const TextStyle headingLarge = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: textPrimary,
  );

  static const TextStyle headingMedium = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: textPrimary,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    color: textPrimary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    color: textPrimary,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    color: textSecondary,
  );

  // Card Decoration
  static BoxDecoration cardDecoration = BoxDecoration(
    color: cardBg,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 10,
        offset: const Offset(0, 2),
      ),
    ],
  );

  // Premium Badge
  static Widget premiumBadge({double size = 16}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        gradient: premiumGradient,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.workspace_premium, color: Colors.white, size: size),
          const SizedBox(width: 4),
          const Text(
            'PRO',
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
