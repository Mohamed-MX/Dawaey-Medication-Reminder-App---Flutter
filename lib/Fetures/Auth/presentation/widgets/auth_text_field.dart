import 'package:dawaey/core/theme/colors.dart';
import 'package:flutter/material.dart';

class AuthTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData icon;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;

  const AuthTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.icon,
    this.obscureText = false,
    this.suffixIcon,
    this.keyboardType,
    this.textInputAction,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,

      obscureText: obscureText,

      keyboardType: keyboardType,

      textInputAction: textInputAction,

      validator: validator,

      style: const TextStyle(
        fontSize: 16,
        color: AppColors.textDark,
      ),

      decoration: InputDecoration(
        hintText: hintText,

        hintStyle: const TextStyle(
          color: AppColors.greyText,
          fontSize: 16,
        ),

        filled: true,

        fillColor: AppColors.authBackground,

        prefixIcon: Icon(
          icon,
          color: AppColors.primaryBlue,
        ),

        suffixIcon: suffixIcon,

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 19,
        ),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: AppColors.authBorder,
            width: 1.5,
          ),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: AppColors.primaryBlue,
            width: 1.5,
          ),
        ),

        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: Colors.red,
          ),
        ),

        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: Colors.red,
          ),
        ),
      ),
    );
  }
}