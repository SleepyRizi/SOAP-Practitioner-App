import 'package:flutter/material.dart';

class AppColors {
  AppColors._(); // no instantiation

  // ─────────────────────────── Brand
  static const MaterialColor primarySwatch = Colors.indigo;
  static const Color primary   = Color(0xFF2D5661); // deep teal
  static const Color onPrimary = Colors.white;

  static const Color accent    = Color(0xFFFFC107); // amber
  static const Color onAccent  = Colors.black;
  static const Color scaffold = Color(0xFFF7FCFD);    // ➕ add this

  // ───── OTP box helpers ─────
  static const Color otpBoxBg      = Color(0xFFF0F0F0); // light-grey (optional)
  static const Color otpBoxFocused = Color(0xFF000000); // solid black border


  static const Color error     = Color(0xFFEF5350);
  static const Color onError   = Colors.white;

  // ─────────────────────────── Neutrals & Surfaces
  static const Color background    = Color(0xFFF8F9FB);
  static const Color onBackground  = Color(0xFF121212);

  static const Color surfaceLight  = Color(0xFFFFFFFF);
  static const Color surfaceDark   = Color(0xFFF0F0F0);

  // ─────────────────────────── Legacy / Extra
  static const Color secondary = Color(0xFFF4E1E6); // soft rose
  static const Color border    = Color(0xFFDADADA);

  // ─────────────────────────── Text
  static const Color textPrimary   = Color(0xFF1C1C1C);
  static const Color textSecondary = Color(0xFF686868);


  // ─────────────────────────── Helpers
  static Color primaryOpacity(double op) => primary.withOpacity(op);
  static Color accentOpacity (double op) => accent.withOpacity(op);
}
