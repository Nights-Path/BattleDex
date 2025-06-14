import 'package:flutter/material.dart';

/// Application-wide color palette
const Color backgroundColor    = Color(0xFF0C1E36);
const Color cardColor          = Color(0xFF1E2B45);
const Color selectedColor      = Color(0xFF5A78FF);
const Color unselectedColor    = Color(0xFF9DA9C3);
const Color highlightColor     = Color(0xFFBDD8A2);
const Color activeStatColor    = Color(0x805FB0C3); // 50% opacity on #5FB0C3
const Color borderColor        = Color(0xFF6D88AE);

/// Text styles
const TextStyle primaryTextStyle    = TextStyle(color: Colors.white);
const TextStyle secondaryTextStyle  = TextStyle(color: unselectedColor);
const TextStyle selectedTextStyle   = TextStyle(color: selectedColor);
const TextStyle hintTextStyle       = TextStyle(color: unselectedColor);

/// Radar chart label style
const TextStyle radarLabelTextStyle = TextStyle(
  color: Colors.white,
  fontSize: 12,
);

/// Button themes
final ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
  primary: selectedColor,
  onPrimary: Colors.white,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
  ),
  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
);

/// Input decoration theme for text fields
final InputDecorationTheme inputDecorationTheme = InputDecorationTheme(
  hintStyle: hintTextStyle,
  enabledBorder: UnderlineInputBorder(
    borderSide: BorderSide(color: unselectedColor),
  ),
  focusedBorder: UnderlineInputBorder(
    borderSide: BorderSide(color: selectedColor),
  ),
  labelStyle: primaryTextStyle,
);
