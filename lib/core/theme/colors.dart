import 'package:flutter/material.dart';

abstract final class AppColors {
  static const Color primary = Colors.teal;
  static const Color primaryLight = Color(0xFFE0F2F1); // teal.shade50
  
  static const Color textDark = Color(0xFF1B363F);
  static const Color textGrey = Colors.grey;

  static const Color success = Colors.teal; // Using teal for success in this design
  static const Color error = Colors.red;
  static const Color errorLight = Color(0xFFFFEBEE); // red.shade50

  static const Color background = Colors.white;
  static const Color surface = Colors.white;

  static const Color tealGreen = Color(0xff169B64);
  static const Color lightBlue = Color(0xffEEF5FB);
  static const Color softMintGreen = Color(0xffE3F4EC);
  static const Color blackBlue = Color(0xff284A63);
  static const Color BlueGray = Color(0xff6F8595);
}
