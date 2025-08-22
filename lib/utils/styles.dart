import 'package:flutter/material.dart';

class AppStyles {
  static const Color primaryColor = Color(0xFF0067AC);
  static const Color accentColor = Color(0xFFC6DA23);
  static const Color buttonColor = Color(0xFF0067AC);
  static const Color registerButtonColor = Colors.green;

  static const TextStyle headerTextStyle = TextStyle(
    fontFamily: 'HelveticaRounded',
    color: Colors.white,
    fontSize: 34,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle buttonTextStyle = TextStyle(
    fontSize: 16,
    color: Colors.white,
    fontFamily: 'HelveticaRounded',
  );

  static InputDecoration textFieldDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400),
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: primaryColor),
      ),
    );
  }

  static ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: buttonColor,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
  );
}
