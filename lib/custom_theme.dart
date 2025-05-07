import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

class CustomTheme {
  static final lightTheme = ThemeData(
    brightness: Brightness.light, // Явно указываем brightness
    scaffoldBackgroundColor: Colors.white,
    primaryColor: const Color(0xff084f57),
    iconTheme: const IconThemeData(color: Color(0xff084f57)),
    splashColor: const Color(0xff084f57),
    textTheme: TextTheme(
      displayLarge: GoogleFonts.openSans(
          fontSize: 22.0.sp, fontWeight: FontWeight.w600, letterSpacing: 1.0, color: Colors.black87),
      headlineMedium: GoogleFonts.openSans(
          fontSize: 12.0.sp, fontWeight: FontWeight.w600, letterSpacing: 1.0, color: Colors.black87),
      displaySmall: GoogleFonts.openSans(
          fontSize: 10.0.sp, fontWeight: FontWeight.w600, letterSpacing: 1.0, color: Colors.black87),
      displayMedium: GoogleFonts.openSans(
          fontSize: 12.0.sp, fontWeight: FontWeight.w600, letterSpacing: 1.0, color: Colors.black87),
      bodyLarge: GoogleFonts.openSans(fontSize: 10.0.sp, letterSpacing: 1.0, fontWeight: FontWeight.w400),
      bodyMedium: GoogleFonts.openSans(fontSize: 10.0.sp, letterSpacing: 1.0),
      headlineSmall: GoogleFonts.openSans(fontSize: 12.0.sp, letterSpacing: 1.0),
      titleLarge: GoogleFonts.openSans(
          fontSize: 18.0.sp, fontWeight: FontWeight.w700, color: Colors.black87),
      titleMedium: GoogleFonts.openSans(
          fontSize: 14.0.sp, fontWeight: FontWeight.w600, color: Colors.black87),
      titleSmall: GoogleFonts.openSans(
          fontSize: 12.0.sp, fontWeight: FontWeight.w600, color: Colors.black87),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: Color(0xff084f57),
      unselectedItemColor: Colors.grey,
    ),
    unselectedWidgetColor: Colors.grey,
    cardColor: Colors.white,
    inputDecorationTheme: InputDecorationTheme(
      hintStyle: GoogleFonts.openSans(fontSize: 10.0.sp, color: Colors.black54),
    ),
    colorScheme: const ColorScheme.light(
      background: Colors.white,
      primary: Color(0xff084f57),
      secondary: Color(0xff084f57),
    ),
  );

  static final darkTheme = ThemeData(
    brightness: Brightness.dark, // Явно указываем brightness
    scaffoldBackgroundColor: const Color(0xFF121212),
    primaryColor: const Color(0xff00c2cb),
    iconTheme: const IconThemeData(color: Color(0xff00c2cb)),
    splashColor: const Color(0xff00c2cb),
    textTheme: TextTheme(
      displayLarge: GoogleFonts.openSans(
          fontSize: 22.0.sp, fontWeight: FontWeight.w600, letterSpacing: 1.0, color: Colors.white),
      headlineMedium: GoogleFonts.openSans(
          fontSize: 12.0.sp, fontWeight: FontWeight.w600, letterSpacing: 1.0, color: Colors.white70),
      displaySmall: GoogleFonts.openSans(
          fontSize: 10.0.sp, fontWeight: FontWeight.w600, letterSpacing: 1.0, color: Colors.white70),
      displayMedium: GoogleFonts.openSans(
          fontSize: 12.0.sp, fontWeight: FontWeight.w600, letterSpacing: 1.0, color: Colors.white),
      bodyLarge: GoogleFonts.openSans(
          fontSize: 10.0.sp, letterSpacing: 1.0, fontWeight: FontWeight.w400, color: Colors.white70),
      bodyMedium: GoogleFonts.openSans(fontSize: 10.0.sp, letterSpacing: 1.0, color: Colors.white60),
      headlineSmall: GoogleFonts.openSans(fontSize: 12.0.sp, letterSpacing: 1.0, color: Colors.white),
      titleLarge: GoogleFonts.openSans(
          fontSize: 18.0.sp, fontWeight: FontWeight.w700, color: Colors.white),
      titleMedium: GoogleFonts.openSans(
          fontSize: 14.0.sp, fontWeight: FontWeight.w600, color: Colors.white),
      titleSmall: GoogleFonts.openSans(
          fontSize: 12.0.sp, fontWeight: FontWeight.w600, color: Colors.white),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF1E1E1E),
      selectedItemColor: Color(0xff00c2cb),
      unselectedItemColor: Colors.grey,
    ),
    unselectedWidgetColor: Colors.white60,
    cardColor: const Color(0xFF1E1E1E),
    inputDecorationTheme: InputDecorationTheme(
      hintStyle: GoogleFonts.openSans(fontSize: 10.0.sp, color: Colors.white70),
    ),
    colorScheme: const ColorScheme.dark(
      background: Color(0xFF121212),
      surface: Color(0xFF1E1E1E),
      primary: Color(0xff00c2cb),
      secondary: Color(0xff00c2cb),
    ),
  );
}
