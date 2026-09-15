import 'package:dawaey/Fetures/Auth/data/models/onboarding_model.dart';
import 'package:dawaey/Fetures/Auth/presentation/view_model/onboarding/onboarding_cubit.dart';
import 'package:dawaey/Fetures/Auth/presentation/view_model/onboarding/onboarding_state.dart';
import 'package:dawaey/Fetures/Auth/presentation/widgets/onboarding_page.dart';
import 'package:dawaey/core/routes/app_routes.dart';
import 'package:dawaey/core/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({
    super.key,
  });

  static const List<OnboardingModel>
      onboardingPages = [
    OnboardingModel(
      imagePath:
          'assets/auth_assets/04_Illustration.svg',

      title:
          'مواعيد أدويتك في مكان واحد',

      description:
          'نساعدك تفتكر مواعيد أدويتك وتنظم جرعاتك بسهولة.',
    ),

    OnboardingModel(
      imagePath:
          'assets/auth_assets/04_Illustration_Card.svg',

      title:
          'متابعة أسهل كل يوم',

      description:
          'تابع أدويتك واعرف الجرعات اللي أخدتها والجرعات المتبقية.',
    ),

    OnboardingModel(
      imagePath:
          'assets/auth_assets/05_Illustration_Card.svg',

      title:
          'خليك مطمئن على عيلتك',

      description:
          'مقدم الرعاية يقدر يتابع أحد أفراد العائلة ويساعده على الالتزام بالأدوية.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        return OnboardingCubit();
      },

      child: BlocConsumer<
          OnboardingCubit,
          OnboardingState>(
        listener: (context, state) {
          if (state
              is OnboardingCompleted) {
            Navigator
                .pushNamedAndRemoveUntil(
              context,
              AppRoutes.login,
              (route) => false,
            );
          }

          if (state
              is OnboardingError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(
              SnackBar(
                content: Text(
                  state.message,
                ),
              ),
            );
          }
        },

        builder: (context, state) {
          final cubit =
              context.read<
                  OnboardingCubit>();

          final bool isLastPage =
              cubit.currentPage ==
                  onboardingPages.length -
                      1;

          return Directionality(
            textDirection:
                TextDirection.rtl,

            child: Scaffold(
              backgroundColor:
                  AppColors.authBackground,

              body: SafeArea(
                child: LayoutBuilder(
                  builder:
                      (
                    context,
                    constraints,
                  ) {
                    final double width =
                        constraints.maxWidth;

                    final double height =
                        constraints.maxHeight;

                    final bool isTablet =
                        width >= 600;

                    return Column(
                      children: [
                        SizedBox(
                          height:
                              height * 0.015,
                        ),

                        Padding(
                          padding:
                              EdgeInsets.symmetric(
                            horizontal:
                                isTablet
                                    ? width *
                                        0.10
                                    : width *
                                        0.05,
                          ),

                          child: Align(
                            alignment:
                                Alignment
                                    .centerLeft,

                            child:
                                TextButton(
                              onPressed:
                                  state
                                          is OnboardingLoading
                                      ? null
                                      : () {
                                          cubit
                                              .finishOnboarding();
                                        },

                              child:
                                  Text(
                                'تخطي',

                                style:
                                    TextStyle(
                                  color:
                                      AppColors
                                          .primaryBlue,

                                  fontSize:
                                      isTablet
                                          ? 18
                                          : width *
                                              0.042,

                                  fontWeight:
                                      FontWeight
                                          .w600,
                                ),
                              ),
                            ),
                          ),
                        ),

                        Expanded(
                          child:
                              PageView.builder(
                            controller:
                                cubit.pageController,

                            itemCount:
                                onboardingPages
                                    .length,

                            onPageChanged:
                                (index) {
                              cubit
                                  .changePage(
                                index,
                              );
                            },

                            itemBuilder:
                                (
                              context,
                              index,
                            ) {
                              return OnboardingPage(
                                model:
                                    onboardingPages[
                                        index],
                              );
                            },
                          ),
                        ),

                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .center,

                          children:
                              List.generate(
                            onboardingPages
                                .length,

                            (index) {
                              final bool
                                  isSelected =
                                  cubit.currentPage ==
                                      index;

                              return AnimatedContainer(
                                duration:
                                    const Duration(
                                  milliseconds:
                                      250,
                                ),

                                margin:
                                    EdgeInsets.symmetric(
                                  horizontal:
                                      width *
                                          0.01,
                                ),

                                width:
                                    isSelected
                                        ? width *
                                            0.065
                                        : width *
                                            0.022,

                                height:
                                    width *
                                        0.022,

                                decoration:
                                    BoxDecoration(
                                  color: isSelected
                                      ? AppColors
                                          .primaryBlue
                                      : AppColors
                                          .authBorder,

                                  borderRadius:
                                      BorderRadius
                                          .circular(
                                    50,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        SizedBox(
                          height:
                              height * 0.04,
                        ),

                        Padding(
                          padding:
                              EdgeInsets.symmetric(
                            horizontal:
                                isTablet
                                    ? width *
                                        0.20
                                    : width *
                                        0.07,
                          ),

                          child:
                              ConstrainedBox(
                            constraints:
                                const BoxConstraints(
                              maxWidth: 500,
                            ),

                            child:
                                SizedBox(
                              width:
                                  double.infinity,

                              height:
                                  isTablet
                                      ? 62
                                      : height *
                                          0.067,

                              child:
                                  ElevatedButton(
                                onPressed:
                                    state
                                            is OnboardingLoading
                                        ? null
                                        : () {
                                            if (isLastPage) {
                                              cubit
                                                  .finishOnboarding();
                                            } else {
                                              cubit
                                                  .nextPage();
                                            }
                                          },

                                style:
                                    ElevatedButton
                                        .styleFrom(
                                  backgroundColor:
                                      AppColors
                                          .primaryBlue,

                                  foregroundColor:
                                      Colors.white,

                                  elevation:
                                      0,

                                  shape:
                                      RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius
                                            .circular(
                                      14,
                                    ),
                                  ),
                                ),

                                child:
                                    state
                                            is OnboardingLoading
                                        ? const SizedBox(
                                            width:
                                                25,

                                            height:
                                                25,

                                            child:
                                                CircularProgressIndicator(
                                              strokeWidth:
                                                  2,

                                              color:
                                                  Colors.white,
                                            ),
                                          )
                                        : Text(
                                            isLastPage
                                                ? 'ابدأ الآن'
                                                : 'التالي',

                                            style:
                                                TextStyle(
                                              fontSize:
                                                  isTablet
                                                      ? 19
                                                      : width *
                                                          0.045,

                                              fontWeight:
                                                  FontWeight.bold,
                                            ),
                                          ),
                              ),
                            ),
                          ),
                        ),

                        SizedBox(
                          height:
                              height * 0.035,
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}