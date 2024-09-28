import 'package:flutter/material.dart'; 

// Defines Colour variables
final darkcolor1 = Color(0xff2B2D42);  // Background
final darkcolor2 = Color(0xffF7EBEC);  // On Background
final darkcolor3 = Color(0xffDDBDD5);  // Primary
final darkcolor4 = Color(0xff7FD1B9);  // Secondary
final darkcolor5 = Color(0xffFAB378);  // Tertiary

final lightcolor1 = Color(0xF5F5F5F5);  // Background
final lightcolor2 = Color(0xff333333);  // On Background
final lightcolor3 = Color(0xff7B68EE);  // Primary
final lightcolor4 = Color(0xff48D1CC);  // Secondary 
final lightcolor5 = Color(0xffFF8C00);  // Tertiary


// Defines themes per light/dark mode
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
  surface: lightcolor1,
  onSurface: lightcolor2,
  primary: lightcolor3,
  secondary: lightcolor4,
  tertiary: lightcolor5,
  ),
);
