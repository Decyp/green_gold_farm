import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Primary Colors
  static const Color primaryGreen = Color(0xFF27AE60);
  static const Color lightGreen = Color(0xFF2ECC40);
  static const Color darkGreen = Color(0xFF1E8449);

  // Secondary Colors
  static const Color accentGold = Color(0xFFF9D342);
  static const Color white = Color(0xFFFFFFFF);
  static const Color lightGray = Color(0xFFF5F5F5);
  static const Color gray = Color(0xFF9E9E9E);
  static const Color darkGray = Color(0xFF424242);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryGreen, lightGreen],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [white, lightGray],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Text Styles
  static TextStyle get heading1 => GoogleFonts.montserrat(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: darkGray,
      );

  static TextStyle get heading2 => GoogleFonts.montserrat(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: darkGray,
      );

  static TextStyle get heading3 => GoogleFonts.montserrat(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: darkGray,
      );

  static TextStyle get bodyText => GoogleFonts.roboto(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: darkGray,
      );

  static TextStyle get caption => GoogleFonts.roboto(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: gray,
      );

  static TextStyle get buttonText => GoogleFonts.montserrat(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: white,
      );

  // Button Styles
  static ButtonStyle get primaryButton => ElevatedButton.styleFrom(
        backgroundColor: primaryGreen,
        foregroundColor: white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
      );

  static ButtonStyle get secondaryButton => ElevatedButton.styleFrom(
        backgroundColor: white,
        foregroundColor: primaryGreen,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: primaryGreen, width: 2),
        ),
        elevation: 0,
      );

  // Card Decoration
  static BoxDecoration get cardDecoration => BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      );

  // Input Decoration
  static InputDecoration get inputDecoration => InputDecoration(
        filled: true,
        fillColor: lightGray,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryGreen, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      );

  // Spacing
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;

  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 24.0;


}
