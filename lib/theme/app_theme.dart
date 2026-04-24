import 'package:flutter/material.dart';

// ── colours ──────────────────────────────────
class AppColors {
  static const Color primary          = Color(0xFFC46906);
  static const Color primaryLight     = Color(0xFFA9692C);
  static const Color primaryCard      = Color(0x80A9692C);
  static const Color gold             = Color(0xFFCB9D4F);
  static const Color white            = Color(0xFFFFFFFF);
  static const Color black            = Color(0xFF000000);
  static const Color gray             = Color(0xFF828282);
  static const Color grayLight        = Color(0xFFBDBDBD);
  static const Color inputFill        = Color(0xBFFFFFFF);
  static const Color cardShadow       = Color(0x40000000);
}

// ── Text styles ───────────────────
class AppTextStyles {
  static const TextStyle heading1 = TextStyle(
    fontFamily: 'Inter', fontWeight: FontWeight.w700,
    fontSize: 64, color: AppColors.white,
  );
  static const TextStyle heading2 = TextStyle(
    fontFamily: 'Inter', fontWeight: FontWeight.w700,
    fontSize: 48, color: AppColors.white,
  );
  static const TextStyle heading3 = TextStyle(
    fontFamily: 'Inter', fontWeight: FontWeight.w700,
    fontSize: 32, color: AppColors.white,
  );
  static const TextStyle heading4 = TextStyle(
    fontFamily: 'Inter', fontWeight: FontWeight.w700,
    fontSize: 24, color: AppColors.white,
  );
  static const TextStyle body = TextStyle(
    fontFamily: 'Inter', fontWeight: FontWeight.w700,
    fontSize: 16, color: AppColors.white,
  );
  static const TextStyle navItem = TextStyle(
    fontFamily: 'Inter', fontWeight: FontWeight.w400,
    fontSize: 16, color: AppColors.white,
  );
  static const TextStyle navItemActive = TextStyle(
    fontFamily: 'Inter', fontWeight: FontWeight.w400,
    fontSize: 16, color: AppColors.gold,
    decoration: TextDecoration.underline,
    decorationColor: AppColors.gold,
  );
  static const TextStyle goldTitle = TextStyle(
    fontFamily: 'Inter', fontWeight: FontWeight.w700,
    fontSize: 48, color: AppColors.gold,
  );
  static const TextStyle button = TextStyle(
    fontFamily: 'Inter', fontWeight: FontWeight.w700,
    fontSize: 24, color: AppColors.white,
  );
  static const TextStyle label = TextStyle(
    fontFamily: 'Inter', fontWeight: FontWeight.w700,
    fontSize: 16, color: Colors.white,
  );
  static const TextStyle drop = TextStyle(
    fontFamily: 'Inter', fontWeight: FontWeight.w700,
    fontSize: 16, color: AppColors.gray,
  );
  static const TextStyle price = TextStyle(
    fontFamily: 'Inter', fontWeight: FontWeight.w700,
    fontSize: 20, color: AppColors.primaryLight,
  );
}

// ── Decorations ───────────────────────────────────────────────
class AppDecorations {
  static BoxDecoration get card => BoxDecoration(
    color: AppColors.primaryCard,
    borderRadius: BorderRadius.circular(25),
    border: Border.all(color: AppColors.primaryLight),
    boxShadow: const [
      BoxShadow(
        color: AppColors.cardShadow,
        blurRadius: 4, spreadRadius: 5, offset: Offset(0, 3),
      ),
    ],
  );

  static BoxDecoration get inputBox => BoxDecoration(
    color: AppColors.inputFill,
    borderRadius: BorderRadius.circular(10),
    border: Border.all(color: AppColors.primaryLight),
  );

  static BoxDecoration get primaryButton => BoxDecoration(
    color: AppColors.primary,
    borderRadius: BorderRadius.circular(10),
    border: Border.all(color: AppColors.primaryLight),
  );

  static BoxDecoration get roundButton => BoxDecoration(
    color: AppColors.primary,
    shape: BoxShape.circle,
    border: Border.all(color: AppColors.primaryLight),
  );
}

// ── Theme ─────────────────────────────────────────────────────
class AppTheme {
  static ThemeData get theme => ThemeData(
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.black,
    fontFamily: 'Inter',
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.gold,
      surface: AppColors.black,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        side: const BorderSide(color: AppColors.primaryLight),
        textStyle: AppTextStyles.button,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.inputFill,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.primaryLight),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.primaryLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      labelStyle: AppTextStyles.label,
      hintStyle: const TextStyle(color: AppColors.gray),
    ),
  );
}
