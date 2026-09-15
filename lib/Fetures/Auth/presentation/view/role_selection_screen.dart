import 'package:dawaey/Fetures/Auth/data/models/user_model.dart';
import 'package:dawaey/Fetures/Auth/presentation/view/signup_screen.dart';
import 'package:dawaey/Fetures/Auth/presentation/widgets/role_selection_card.dart';
import 'package:dawaey/core/routes/app_routes.dart';
import 'package:dawaey/core/theme/colors.dart';
import 'package:flutter/material.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    final bool isTablet = screenWidth >= 600;

    return Directionality(
      textDirection: TextDirection.rtl,

      child: Scaffold(
        backgroundColor: AppColors.authBackground,

        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 60 : 24,
                vertical: 20,
              ),

              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 460,
                ),

                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerRight,

                      child: IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },

                        icon: const Icon(
                          Icons.arrow_back_ios_new,

                          color: AppColors.primaryBlue,

                          size: 25,
                        ),
                      ),
                    ),

                    SizedBox(
                      height: isTablet ? 55 : 45,
                    ),

                    Text(
                      'من أنت في دوائي؟',

                      textAlign: TextAlign.center,

                      style: TextStyle(
                        color: AppColors.primaryBlue,

                        fontSize: isTablet ? 32 : 29,

                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(
                      height: 12,
                    ),

                    Text(
                      'اختر الدور المناسب لك',

                      textAlign: TextAlign.center,

                      style: TextStyle(
                        color: AppColors.greyText,

                        fontSize: isTablet ? 18 : 16,
                      ),
                    ),

                    SizedBox(
                      height: isTablet ? 60 : 50,
                    ),

                    RoleSelectionCard(
                      imagePath:
                          'assets/auth_assets/Avatar_Elderly.svg',

                      title: 'أنا باخد أدوية',

                      subtitle:
                          'أدير أدويتي ومواعيدي بسهولة',

                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.patientSignup,
                        );
                      },
                    ),

                    const SizedBox(
                      height: 20,
                    ),

                    RoleSelectionCard(
                      imagePath:
                          'assets/auth_assets/Avatar_Family.svg',

                      title: 'بتابع حد من عيلتي',

                      subtitle:
                          'أتابع وأدعم أحد أفراد عائلتي',

                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.caregiverSignup,
                        );
                      },
                    ),

                    const SizedBox(
                      height: 30,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}