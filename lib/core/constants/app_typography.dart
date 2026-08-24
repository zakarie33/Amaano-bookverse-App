import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Premium book-app typography — Poppins headings, Nunito Sans body.
class AppTypography {
  AppTypography._();

  static TextStyle get appTitle => GoogleFonts.poppins(
        fontSize: 21,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: -0.2,
      );

  static TextStyle get greetingTitle => GoogleFonts.poppins(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
        letterSpacing: -0.4,
        height: 1.15,
      );

  static TextStyle get greetingSubtitle => GoogleFonts.nunitoSans(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
        height: 1.4,
      );

  static TextStyle get sectionTitle => GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
        letterSpacing: 0.5,
        height: 1.2,
      );

  static TextStyle get bookTitle => GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        height: 1.22,
      );

  static TextStyle get bookTitleCompact => GoogleFonts.poppins(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        height: 1.2,
      );

  static TextStyle get author => GoogleFonts.nunitoSans(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
        height: 1.25,
      );

  static TextStyle get body => GoogleFonts.nunitoSans(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
        height: 1.45,
      );

  static TextStyle get bodySecondary => GoogleFonts.nunitoSans(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
        height: 1.45,
      );

  static TextStyle get button => GoogleFonts.poppins(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.4,
      );

  static TextStyle get navLabel => GoogleFonts.poppins(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        height: 1.0,
      );

  static TextStyle get chip => GoogleFonts.nunitoSans(
        fontSize: 13,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get price => GoogleFonts.poppins(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      );

  static TextStyle get rating => GoogleFonts.nunitoSans(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );
}
