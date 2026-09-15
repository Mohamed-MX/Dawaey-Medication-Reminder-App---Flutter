import 'package:dawaey/core/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class RoleSelectionCard extends StatelessWidget {
  final String imagePath;

  final String title;

  final String subtitle;

  final VoidCallback onTap;

  const RoleSelectionCard({
    super.key,
    required this.imagePath,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,

      borderRadius: BorderRadius.circular(18),

      child: Container(
        width: double.infinity,
        height: 180,

        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),

        decoration: BoxDecoration(
          color: AppColors.background,

          borderRadius: BorderRadius.circular(18),

          border: Border.all(
            color: AppColors.authBorder,
            width: 1.5,
          ),
        ),

        child: Row(
          children: [
            SizedBox(
              width: 105,
              height: 125,

              child: SvgPicture.asset(
                imagePath,
                fit: BoxFit.contain,
              ),
            ),

            const SizedBox(
              width: 22,
            ),

            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,

                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    title,

                    textAlign: TextAlign.right,

                    style: const TextStyle(
                      color: AppColors.primaryBlue,
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  Text(
                    subtitle,

                    textAlign: TextAlign.right,

                    style: const TextStyle(
                      color: AppColors.greyText,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}