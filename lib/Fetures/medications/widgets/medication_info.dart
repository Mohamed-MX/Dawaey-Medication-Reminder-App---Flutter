import 'package:dawaey/core/theme/colors.dart';
import 'package:dawaey/core/theme/fonts.dart';
import 'package:flutter/material.dart';

class MedicationInfo extends StatelessWidget {
  const MedicationInfo({super.key , required this.label , required this.value});
  final String label ;
  final String value;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          textDirection: TextDirection.rtl,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
              style: AppFonts.inter18RegularSoftMintGreen.copyWith(color: AppColors.BlueGray),
            ),
            Text(value,
              style: AppFonts.inter30BoldDark.copyWith(fontSize: 18),
            ),
          ],
        ),
        Divider(
          thickness: 1,
        )
      ],
    );
  }
}