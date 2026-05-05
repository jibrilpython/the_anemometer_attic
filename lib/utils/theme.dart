import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:the_anemometer_attic/utils/const.dart';

final appTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: kAccent,
  scaffoldBackgroundColor: kBackground,
  colorScheme: const ColorScheme.light(
    primary: kAccent,
    secondary: kAccentAmber,
    surface: kPanelBg,
    onSurface: kPrimaryText,
    onPrimary: kPanelBg,
    error: kError,
    outline: kOutline,
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.transparent,
    elevation: 0,
    scrolledUnderElevation: 0,
    centerTitle: false,
    systemOverlayStyle: SystemUiOverlayStyle.dark,
    titleTextStyle: GoogleFonts.spaceGrotesk(
      fontSize: 24.sp,
      fontWeight: FontWeight.w700,
      color: kPrimaryText,
    ),
    iconTheme: const IconThemeData(color: kPrimaryText),
  ),
  textTheme: TextTheme(
    // Space Grotesk for display/headings (20px+ per ui_rules)
    displayLarge: GoogleFonts.spaceGrotesk(
      fontSize: 40.sp,
      fontWeight: FontWeight.w800,
      color: kPrimaryText,
      letterSpacing: -1.5,
    ),
    displayMedium: GoogleFonts.spaceGrotesk(
      fontSize: 32.sp,
      fontWeight: FontWeight.w800,
      color: kPrimaryText,
      letterSpacing: -1.0,
    ),
    displaySmall: GoogleFonts.spaceGrotesk(
      fontSize: 28.sp,
      fontWeight: FontWeight.w800,
      color: kPrimaryText,
      letterSpacing: -0.5,
    ),
    headlineLarge: GoogleFonts.spaceGrotesk(
      fontSize: 24.sp,
      fontWeight: FontWeight.w800,
      color: kPrimaryText,
      letterSpacing: -0.5,
    ),
    headlineMedium: GoogleFonts.spaceGrotesk(
      fontSize: 20.sp,
      fontWeight: FontWeight.w700,
      color: kPrimaryText,
    ),
    headlineSmall: GoogleFonts.inter(
      fontSize: 18.sp,
      fontWeight: FontWeight.w700,
      color: kPrimaryText,
    ),
    // Inter for body, labels, navigation
    titleLarge: GoogleFonts.inter(
      fontSize: 16.sp,
      fontWeight: FontWeight.w700,
      color: kPrimaryText,
    ),
    titleMedium: GoogleFonts.inter(
      fontSize: 14.sp,
      fontWeight: FontWeight.w600,
      color: kPrimaryText,
    ),
    titleSmall: GoogleFonts.inter(
      fontSize: 13.sp,
      fontWeight: FontWeight.w600,
      color: kSecondaryText,
    ),
    bodyLarge: GoogleFonts.inter(
      fontSize: 15.sp,
      fontWeight: FontWeight.w500,
      color: kPrimaryText,
      height: 1.5,
    ),
    bodyMedium: GoogleFonts.inter(
      fontSize: 14.sp,
      fontWeight: FontWeight.w500,
      color: kPrimaryText,
      height: 1.5,
    ),
    bodySmall: GoogleFonts.inter(
      fontSize: 12.sp,
      fontWeight: FontWeight.w500,
      color: kSecondaryText,
    ),
    labelLarge: GoogleFonts.inter(
      fontSize: 13.sp,
      fontWeight: FontWeight.w700,
      color: kPrimaryText,
      letterSpacing: 0.5,
    ),
    labelMedium: GoogleFonts.inter(
      fontSize: 12.sp,
      fontWeight: FontWeight.w600,
      color: kSecondaryText,
      letterSpacing: 0.5,
    ),
    labelSmall: GoogleFonts.inter(
      fontSize: 11.sp,
      fontWeight: FontWeight.w600,
      color: kSecondaryText,
      letterSpacing: 0.5,
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: kPanelBg,
    contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(kRadiusSmall)),
      borderSide: const BorderSide(color: kOutline, width: 1),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(kRadiusSmall)),
      borderSide: const BorderSide(color: kOutline, width: 1),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(kRadiusSmall)),
      borderSide: const BorderSide(color: kAccent, width: 2),
    ),
    hintStyle: GoogleFonts.inter(
      color: kSecondaryText,
      fontSize: 14.sp,
      fontWeight: FontWeight.w400,
    ),
    labelStyle: GoogleFonts.inter(
      color: kSecondaryText,
      fontSize: 14.sp,
      fontWeight: FontWeight.w500,
    ),
    floatingLabelStyle: GoogleFonts.inter(
      color: kPrimaryText,
      fontSize: 14.sp,
      fontWeight: FontWeight.w600,
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: kAccent,
      foregroundColor: Colors.white,
      elevation: 0,
      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 32.w),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(kRadiusSmall)),
      ),
      textStyle: GoogleFonts.inter(
        fontWeight: FontWeight.w600,
        fontSize: 14.sp,
        letterSpacing: 0.5,
      ),
    ),
  ),
  cardTheme: CardThemeData(
    color: kPanelBg,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(kRadiusSmall)),
      side: const BorderSide(color: kOutline, width: 1),
    ),
    margin: EdgeInsets.zero,
  ),
  dividerTheme: const DividerThemeData(
    color: kOutline,
    thickness: 1.0,
    space: 0,
  ),
  useMaterial3: true,
);
