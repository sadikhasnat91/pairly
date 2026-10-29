import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTypography {
  AppTypography._();

  static TextStyle get displayLarge => GoogleFonts.plusJakartaSans(
    fontSize: 32,
    fontWeight: FontWeight.w800,
    color: AppColors.mainText,
    letterSpacing: -0.6,
    height: 1.2,
  );

  static TextStyle get displayMedium => GoogleFonts.plusJakartaSans(
    fontSize: 26,
    fontWeight: FontWeight.w700,
    color: AppColors.mainText,
    letterSpacing: -0.4,
    height: 1.25,
  );

  static TextStyle get titleLarge => GoogleFonts.plusJakartaSans(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.mainText,
    letterSpacing: -0.2,
    height: 1.3,
  );

  static TextStyle get titleMedium => GoogleFonts.plusJakartaSans(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.mainText,
    letterSpacing: -0.1,
    height: 1.35,
  );

  static TextStyle get titleSmall => GoogleFonts.plusJakartaSans(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.mainText,
    letterSpacing: 0,
    height: 1.4,
  );

  static TextStyle get bodyLarge => GoogleFonts.plusJakartaSans(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.mainText,
    letterSpacing: 0.1,
    height: 1.5,
  );

  static TextStyle get bodyMedium => GoogleFonts.plusJakartaSans(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.secondaryTextCol,
    letterSpacing: 0.1,
    height: 1.45,
  );

  static TextStyle get bodySmall => GoogleFonts.plusJakartaSans(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.secondaryTextCol,
    letterSpacing: 0.2,
    height: 1.4,
  );

  static TextStyle get labelLarge => GoogleFonts.plusJakartaSans(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.mainText,
    letterSpacing: 0.2,
  );

  static TextStyle get labelMedium => GoogleFonts.plusJakartaSans(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.secondaryTextCol,
    letterSpacing: 0.3,
  );

  static TextStyle get labelSmall => GoogleFonts.plusJakartaSans(
    fontSize: 10,
    fontWeight: FontWeight.w700,
    color: AppColors.secondaryTextCol,
    letterSpacing: 0.6,
  );

  static TextStyle get buttonText => GoogleFonts.plusJakartaSans(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.2,
  );
}
