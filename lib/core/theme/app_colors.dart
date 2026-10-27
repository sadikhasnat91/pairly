import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Backgrounds
  static const Color primaryBackground = Color(0xFF090B10);
  static const Color secondaryBackground = Color(0xFF10151D);
  static const Color elevatedCard = Color(0xFF151D27);
  static const Color cardSubtle = Color(0xFF1B2431);

  // Accents
  static const Color primaryAccent = Color(0xFFC5F467); // Lime
  static const Color primaryAccentDark = Color(0xFFA5D447);
  static const Color secondaryAccent = Color(0xFF8DD8C4); // Mint
  static const Color accentGlow = Color(0x33C5F467);

  // Typography
  static const Color primaryText = Color(0xFFF5F7FA);
  static const Color secondaryText = Color(0xFF98A4B5);
  static const Color tertiaryText = Color(0xFF64748B);
  static const Color disabledText = Color(0xFF475569);

  // Borders & Dividers
  static const Color border = Color(0xFF27313D);
  static const Color borderFocused = Color(0xFFC5F467);
  static const Color divider = Color(0xFF1E2836);

  // Semantic States
  static const Color success = Color(0xFF65DDA2);
  static const Color successBackground = Color(0x1F65DDA2);
  static const Color warning = Color(0xFFFFCB70);
  static const Color warningBackground = Color(0x1FFFCB70);
  static const Color error = Color(0xFFFF6977);
  static const Color errorBackground = Color(0x1FFF6977);
  static const Color info = Color(0xFF60A5FA);
  static const Color infoBackground = Color(0x1F60A5FA);

  // Gradients
  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF161F2C), Color(0xFF111721)],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFC5F467), Color(0xFF8DD8C4)],
  );

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0x301E2E20), Color(0x00090B10)],
  );
}
