import 'package:flutter/material.dart';

/// Adalot Sathi color identity.
///
/// Palette: "Official Navy & Gold" — deep, trustworthy blues with an accent of
/// gold. Chosen for a legal/professional audience.
class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF1F4E79); // Deep official blue
  static const Color primaryDark = Color(0xFF0D1B2A); // Near-black navy
  static const Color primaryLight = Color(0xFF1B263B); // Dark navy
  static const Color accent = Color(0xFFC9A227); // Gold
  static const Color accentSoft = Color(0xFFF5EBD3); // Soft gold tint

  // Status colors.
  static const Color danger = Color(0xFFC0392B); // Overdue / urgent
  static const Color warning = Color(0xFFE67E22); // Today / approaching
  static const Color success = Color(0xFF1E8449); // Completed / healthy
  static const Color muted = Color(0xFF7F8C8D); // Later / neutral

  // Surface shades.
  static const Color background = Color(0xFFF4F6F8);
  static const Color surface = Colors.white;
  static const Color surfaceAlt = Color(0xFFEDF1F4);
  static const Color border = Color(0xFFD5DBE1);

  // Text.
  static const Color textPrimary = Color(0xFF1B263B);
  static const Color textSecondary = Color(0xFF5D6D7E);
  static const Color textOnPrimary = Colors.white;
  static const Color textOnAccent = Color(0xFF1B263B);

  // Deadline urgency.
  static const Color urgencyOverdue = danger;
  static const Color urgencyToday = warning;
  static const Color urgencyWeek = primary;
  static const Color urgencyLater = muted;
}


