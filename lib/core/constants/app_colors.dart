import 'package:flutter/material.dart';

/// Amaano BookVerse — premium brown, caramel, cream & espresso palette.
///
/// Base surfaces/text stay on the soft cream + dark-ink family; the dark
/// brown "espresso" family (nav bar, hero gradients, headers, borders) and
/// the caramel accents use the exact shades from the dark-brown/caramel
/// master palette: #1E120D, #2D1B15, #3E241A, #4E2D1E, #6A3F24, #8A5A2B,
/// #C8965A, #E7C49A, #F5E9DA.
class AppColors {
  AppColors._();

  // ── Brand palette ────────────────────────────────────────────────────────
  static const Color background = Color(0xFFF7F1E8); // Soft cream
  static const Color primaryBrown = Color(0xFF3E241A); // Dark brown
  static const Color gold = Color(0xFFC8965A); // Primary caramel
  static const Color surface = Color(0xFFFFF9F2); // Light card background
  static const Color chipInactive = Color(0xFFE9DCC6); // Warm beige
  static const Color textPrimary = Color(0xFF1E120D); // Darkest brown
  static const Color textSecondary = Color(0xFF7A6657);
  static const Color navBackground = Color(0xFF2D1B15); // Very dark brown
  static const Color navSelected = Color(0xFFC8965A); // Primary caramel
  static const Color navUnselected = Color(0xFFF5E9DA); // Light cream
  static const Color navLightBackground = Color(0xFFFFFFFF);
  static const Color navLightSelected = Color(0xFFC8965A); // Primary caramel
  static const Color navLightUnselected = Color(0xFF7A6657); // Secondary text
  static const Color error = Color(0xFFC0392B);

  static const Color success = Color(0xFF6F8A45);
  static const Color white = Color(0xFFFFFFFF);

  // ── Legacy aliases (keep existing imports working) ───────────────────────
  static const Color espresso = primaryBrown; // Dark brown
  static const Color espressoDark = Color(0xFF1E120D); // Darkest brown
  static const Color espressoDeep = textPrimary; // Darkest brown
  static const Color espressoSoft = Color(0xFF6A3F24); // Medium brown
  static const Color espressoLight = Color(0xFF8A5A2B); // Secondary brown

  static const Color caramel = gold; // Primary caramel
  static const Color caramelDark = Color(0xFF8A5A2B); // Secondary brown
  static const Color starGold = Color(0xFFE7C49A); // Light caramel

  static const Color tortilla = navUnselected; // Light cream
  static const Color tortillaAlt = surface; // Light card background
  static const Color cream = background; // Soft cream
  static const Color homeSurface = background; // Soft cream

  static const Color darkBrown = primaryBrown; // Dark brown
  static const Color muted = chipInactive; // Warm beige
  static const Color mutedText = textSecondary; // Secondary text
  static const Color textOnCard = textPrimary;
  static const Color textOnCardMuted = textSecondary;
  static const Color textOnHomeMuted = textSecondary;
  static const Color softBorder = Color(0xFF6A3F24); // Medium brown

  static const Color danger = error;

  // ── Splash (coffee / espresso) ───────────────────────────────────────────
  static const Color splashCoffee = Color(0xFF2D1B15); // Very dark brown
  static const Color splashCoffeeDeep = Color(0xFF1E120D); // Darkest brown
  static const Color splashCoffeeMid = Color(0xFF3E241A); // Dark brown
  static const Color splashCoffeeLight = Color(0xFF6A3F24); // Medium brown
}
