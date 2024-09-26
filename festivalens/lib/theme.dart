import 'package:flutter/material.dart';

final darkcolor1 = Color(0xff2B2D42);  // Dark Color
final darkcolor2 = Color(0xffF7EBEC);  // Light Color
final darkcolor3 = Color(0xffDDBDD5);  // Accent Color
final darkcolor4 = Color(0xff7FD1B9);  // Secondary Accent Color
final darkcolor5 = Color(0xffFAB378);  // Additional Accent Color

final lightcolor1 = Color(0xF5F5F5F5);  // Light Color
final lightcolor2 = Color(0xff333333);  // Dark Color
final lightcolor3 = Color(0xff7B68EE);  // Accent Color
final lightcolor4 = Color(0xff48D1CC);  // Secondary Accent Color
final lightcolor5 = Color(0xffFF8C00);  // Additional Accent Color



final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
  surface: darkcolor1,
  onSurface: darkcolor2,
  primary: darkcolor3,
  secondary: darkcolor4,
  tertiary: darkcolor5,
  ),
);


final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
  surface: lightcolor,
  onSurface: lightcolor2,
  primary: lightcolor3,
  secondary: lightcolor4,
  tertiary: lightcolor5,
  ),
);
