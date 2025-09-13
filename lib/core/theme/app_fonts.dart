import 'package:flutter/material.dart';

class AppFonts {
  static const String primaryFont = 'Inter';
  
  // Font Weights
  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
  
  // Text Styles
  static const TextStyle heading1 = TextStyle(
    fontFamily: primaryFont,
    fontSize: 32,
    fontWeight: bold,
    height: 1.2,
  );
  
  static const TextStyle heading2 = TextStyle(
    fontFamily: primaryFont,
    fontSize: 24,
    fontWeight: bold,
    height: 1.3,
  );
  
  static const TextStyle heading3 = TextStyle(
    fontFamily: primaryFont,
    fontSize: 20,
    fontWeight: semiBold,
    height: 1.4,
  );
  
  static const TextStyle body1 = TextStyle(
    fontFamily: primaryFont,
    fontSize: 16,
    fontWeight: regular,
    height: 1.5,
  );
  
  static const TextStyle body2 = TextStyle(
    fontFamily: primaryFont,
    fontSize: 14,
    fontWeight: regular,
    height: 1.4,
  );
  
  static const TextStyle caption = TextStyle(
    fontFamily: primaryFont,
    fontSize: 12,
    fontWeight: regular,
    height: 1.3,
  );
  
  static const TextStyle button = TextStyle(
    fontFamily: primaryFont,
    fontSize: 16,
    fontWeight: medium,
    height: 1.2,
  );
}