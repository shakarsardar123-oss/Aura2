import 'package:flutter/material.dart';

/// AURA color palette.
///
/// All theme colors are centralized here so that every widget
/// and future theme extension references a single source of truth.
class AppColors {
  AppColors._();

  // ── Background layers ──
  static const Color background = Color(0xFF0B0E14);
  static const Color card = Color(0xFF151A23);
  static const Color secondary = Color(0xFF111720);

  // ── Accent colors ──
  static const Color cyan = Color(0xFF00E5FF);
  static const Color blue = Color(0xFF448AFF);
  static const Color purple = Color(0xFFB388FF);
  static const Color orange = Color(0xFFFFAB40);
  static const Color green = Color(0xFF69F0AE);
  static const Color red = Color(0xFFFF5252);

  // ── Semantic defaults ──
  static const Color primary = cyan;
  static const Color onBackground = Color(0xFFE1E4EA);
  static const Color onCard = Color(0xFFC9CDD4);
  static const Color hint = Color(0xFF6B7280);
  static const Color border = Color(0xFF1E2533);
  static const Color divider = Color(0xFF1E2533);
  static const Color error = red;
  static const Color surface = card;
  static const Color onSurface = onCard;
}
