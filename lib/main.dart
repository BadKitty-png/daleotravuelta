import 'package:flutter/material.dart';

import 'screens/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class AppColors {
  static const Color primary = Color(0xFF3D7050);
  static const Color secondary = Color(0xFFC2DA8D);
  static const Color amber = Color(0xFFD4AF37);

  static const Color background = Color(0xFFF7F8F5);
  static const Color surface = Color(0xFFFFFFFF);

  static const Color textPrimary = Color(0xFF1E2420);
  static const Color textSecondary = Color(0xFF5C6660);

  static const Color border = Color(0xFFE4E8E2);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override.Widget
  build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dale la Vuelta',

      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,

        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          surface: AppColors.surface,
          onSurface: AppColors.textPrimary,
        ),

        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 23,
            fontWeight: FontWeight.bold,
          ),
        ),

        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
          headlineMedium: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
          titleLarge: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          titleMedium: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
          bodyLarge: TextStyle(fontSize: 14, color: AppColors.textPrimary),
          bodyMedium: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surface,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
        ),

        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        cardTheme: CardThemeData(
          color: AppColors.surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.border),
          ),
        ),
      ),

      home: const SplashScreen(),
    );
  }
}
