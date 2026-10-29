import 'package:flutter/material.dart';

/// The official Pairly Romantic Design System Palette.
/// Emotional direction: "Even when we're apart, we're still close."
class AppColors {
  AppColors._();

  // === Core Romantic Foundation Palette ===
  static const Color primaryRomanticBlush = Color(0xFFF4A6B8);
  static const Color deepRomanticPlum = Color(0xFF47263F);
  static const Color softRose = Color(0xFFE77E9A);
  static const Color warmCreamBackground = Color(0xFFFFF8F5);
  static const Color softPinkSurface = Color(0xFFFCECEF);
  static const Color whiteCards = Color(0xFFFFFFFF);
  static const Color mainText = Color(0xFF332630);
  static const Color secondaryTextCol = Color(0xFF897783);
  static const Color subtleBorders = Color(0xFFF0DDE3);
  static const Color successAccent = Color(0xFF64A98A);
  static const Color errorAccent = Color(0xFFD85C6B);

  // === Semantic Aliases (Preserving 100% compatibility across codebase) ===
  static const Color primaryBackground = warmCreamBackground;
  static const Color secondaryBackground = softPinkSurface;
  static const Color elevatedCard = whiteCards;
  static const Color cardSubtle = softPinkSurface;

  static const Color primaryAccent = softRose;
  static const Color primaryAccentDark = deepRomanticPlum;
  static const Color secondaryAccent = primaryRomanticBlush;
  static const Color accentGlow = Color(0x33F4A6B8);

  static const Color primaryText = mainText;
  static const Color secondaryText = secondaryTextCol;
  static const Color tertiaryText = Color(0xFFA594A0);
  static const Color disabledText = Color(0xFFC7B6BF);

  static const Color border = subtleBorders;
  static const Color borderFocused = softRose;
  static const Color divider = subtleBorders;

  static const Color success = successAccent;
  static const Color successBackground = Color(0x1F64A98A);
  static const Color warning = Color(0xFFE89858);
  static const Color warningBackground = Color(0x1FE89858);
  static const Color error = errorAccent;
  static const Color errorBackground = Color(0x1FD85C6B);
  static const Color info = Color(0xFF7E9AE7);
  static const Color infoBackground = Color(0x1F7E9AE7);

  // === Dark / Evening Romantic Theme Tokens ===
  static const Color darkPrimaryBackground = Color(0xFF22111E);
  static const Color darkSecondaryBackground = Color(0xFF2D1728);
  static const Color darkElevatedCard = Color(0xFF371D31);
  static const Color darkBorder = Color(0xFF4C2743);
  static const Color darkPrimaryText = Color(0xFFFFF3F6);
  static const Color darkSecondaryText = Color(0xFFD2B3C3);

  // === Romantic Gradients ===
  /// Warm blush to soft rose for primary actions & glowing elements
  static const LinearGradient blushGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryRomanticBlush, softRose],
  );

  /// Deep romantic plum to muted berry
  static const LinearGradient plumGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [deepRomanticPlum, Color(0xFF33192C)],
  );

  /// Subtle card shine
  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [whiteCards, Color(0xFFFFFBFD)],
  );

  static const LinearGradient accentGradient = blushGradient;

  /// Romantic top ambient gradient
  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0x35F4A6B8), Color(0x00FFF8F5)],
  );
}
