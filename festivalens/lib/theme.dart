import 'package:flutter/material.dart';

final dcolor = Color(0xff2B2D42);  // Dark Color
final dcolor2 = Color(0xffF7EBEC);  // Light Color
final dcolor3 = Color(0xffDDBDD5);  // Accent Color
final dcolor4 = Color(0xff7FD1B9);  // Secondary Accent Color
final dcolor5 = Color(0xffFAB378);  // Additional Accent Color

final lcolor = Color(0xF5F5F5F5);  // Light Color
final lcolor2 = Color(0xff333333);  // Dark Color
final lcolor3 = Color(0xff7B68EE);  // Accent Color
final lcolor4 = Color(0xff48D1CC);  // Secondary Accent Color
final lcolor5 = Color(0xffFF8C00);  // Additional Accent Color



final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
  surface: dcolor,
  onSurface: dcolor2,
  primary: dcolor3,
  secondary: dcolor4,
  tertiary: dcolor5,
  ),
);


final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
  surface: lcolor,
  onSurface: lcolor2,
  primary: lcolor3,
  secondary: lcolor4,
  tertiary: lcolor5,
  ),
);
