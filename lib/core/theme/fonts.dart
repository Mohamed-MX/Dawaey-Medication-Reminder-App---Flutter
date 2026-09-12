import 'package:dawaey/core/theme/colors.dart';
import 'package:flutter/material.dart';

abstract final class AppFonts {
  static const inter30BoldDark =  TextStyle(
    color: AppColors.blackBlue,
    fontSize: 30 ,
    fontWeight: FontWeight.bold
  );
  static const inter18BoldRed =  TextStyle(
    fontSize: 18,
    color: AppColors.tealGreen
  );
  static const inter18RegularSoftMintGreen = TextStyle(
    color: AppColors.softMintGreen,
    fontSize: 18,
    fontWeight: FontWeight.w400
  );
  // Add more text styles or font weights here if needed
}
