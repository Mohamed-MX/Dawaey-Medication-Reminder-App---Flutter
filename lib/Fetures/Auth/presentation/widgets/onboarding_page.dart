import 'package:dawaey/Fetures/Auth/data/models/onboarding_model.dart';
import 'package:dawaey/core/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class OnboardingPage extends StatelessWidget {
  final OnboardingModel model;

  const OnboardingPage({
    super.key,
    required this.model,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width =
            constraints.maxWidth;

        final double height =
            constraints.maxHeight;

        final bool isTablet =
            width >= 600;

        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal:
                isTablet
                    ? width * 0.14
                    : width * 0.08,
          ),

          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center,

            children: [
              SizedBox(
                width:
                    isTablet
                        ? width * 0.52
                        : width * 0.70,

                height:
                    isTablet
                        ? height * 0.42
                        : height * 0.38,

                child: SvgPicture.asset(
                  model.imagePath,

                  fit: BoxFit.contain,
                ),
              ),

              SizedBox(
                height:
                    height * 0.045,
              ),

              Text(
                model.title,

                textAlign:
                    TextAlign.center,

                style: TextStyle(
                  color:
                      AppColors.primaryBlue,

                  fontSize:
                      isTablet
                          ? 32
                          : width * 0.068,

                  fontWeight:
                      FontWeight.bold,

                  height: 1.3,
                ),
              ),

              SizedBox(
                height:
                    height * 0.018,
              ),

              Text(
                model.description,

                textAlign:
                    TextAlign.center,

                style: TextStyle(
                  color:
                      AppColors.greyText,

                  fontSize:
                      isTablet
                          ? 19
                          : width * 0.042,

                  height: 1.7,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}