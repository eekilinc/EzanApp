import 'package:flutter/material.dart';

/// Uygulama genelinde tek karanlık/açık tema paleti.
///
/// Amaç: her ekranda farklı hex (`0xFF18241B` vs `0xFF161F18` vs
/// `grey.shade900`) kullanımını bitirip tutarlı görünüm sağlamak.
/// Yeni renk eklerken buraya ekleyin, ekrana gömmeyin.
class AppColors {
  AppColors._();

  // ---- Dark tema yüzeyleri ----
  static const Color darkScaffold = Color(0xFF0C130E);
  static const Color darkSurface = Color(0xFF162018);
  static const Color darkCard = Color(0xFF18241B);
  static const Color darkCardAlt = Color(0xFF1A261D);
  static const Color darkAppBar = Color(0xFF0F1A11);

  // ---- Açık tema yüzeyleri ----
  static const Color lightScaffold = Color(0xFFF6F8F6);

  // ---- Vurgu ----
  static const Color gold = Colors.amber;
}
