import 'package:dawaey/core/theme/fonts.dart';
import 'package:flutter/material.dart';

class DurationChip extends StatelessWidget {
  const DurationChip({
    super.key,
    required this.title,
    required this.selected,
    required this.onTap,
  });
  double rs(BuildContext context, double value) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final scale = (screenWidth / 382).clamp(0.9, 1.2);

    return value * scale;
  }
  final String title;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF4285E5)
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? const Color(0xFF4285E5)
                : const Color(0xFFD9DDE1),
            width: rs(context , 2),
          ),
        ),
        child: Center(
          child: Text(
            title,
            style: AppFonts.inter30BoldDark.copyWith(fontSize: rs(context , 18) )
          ),
        ),
      ),
    );
  }
}