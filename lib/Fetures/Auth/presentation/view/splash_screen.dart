import 'package:dawaey/Fetures/Auth/data/models/user_model.dart';
import 'package:dawaey/Fetures/Auth/presentation/view_model/auth_cubit.dart';
import 'package:dawaey/Fetures/Auth/presentation/view_model/auth_state.dart';
import 'package:dawaey/Fetures/Auth/presentation/view_model/splash/splash_cubit.dart';
import 'package:dawaey/Fetures/Auth/presentation/view_model/splash/splash_state.dart';
import 'package:dawaey/core/routes/app_routes.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        return SplashCubit()..checkStartup();
      },
      child: BlocListener<SplashCubit, SplashState>(
        listener: (context, state) async {
          if (state is SplashShowOnboarding) {
            Navigator.pushReplacementNamed(
              context,
              AppRoutes.onboarding,
            );

            return;
          }

          if (state is SplashShowLogin) {
            Navigator.pushReplacementNamed(
              context,
              AppRoutes.login,
            );

            return;
          }

          if (state is SplashShowCaregiverHome ||
              state is SplashShowPatientHome) {
            final authCubit =
                context.read<AuthCubit>();

            await authCubit.checkCurrentUser();

            if (!context.mounted) {
              return;
            }

            final authState = authCubit.state;

            if (authState is AuthSuccess) {
              if (authState.user.role ==
                  UserRole.caregiver) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.caregiverHome,
                  (route) => false,
                );

                return;
              }

              if (authState.user.role ==
                  UserRole.patient) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.patientHome,
                  (route) => false,
                );

                return;
              }
            }

            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.login,
              (route) => false,
            );

            return;
          }

          if (state is SplashError) {
            Navigator.pushReplacementNamed(
              context,
              AppRoutes.login,
            );
          }
        },
        child: Scaffold(
          backgroundColor: const Color(0xFFF7FBFC),
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final double width =
                    constraints.maxWidth;

                final double height =
                    constraints.maxHeight;

                final bool isTablet =
                    width >= 600;

                return Stack(
                  children: [
                    Positioned(
                      top: height * 0.20,
                      left: 0,
                      right: 0,
                      child: Column(
                        children: [
                          SizedBox(
                            width:
                                isTablet
                                    ? 115
                                    : width * 0.23,
                            height:
                                isTablet
                                    ? 115
                                    : width * 0.23,
                            child: SvgPicture.asset(
                              'assets/auth_assets/03_Logo.svg',
                              fit: BoxFit.contain,
                            ),
                          ),

                          SizedBox(
                            height:
                                height * 0.012,
                          ),

                          SizedBox(
                            width:
                                isTablet
                                    ? 190
                                    : width * 0.34,
                            child: SvgPicture.asset(
                              'assets/auth_assets/04_Brand.svg',
                              fit: BoxFit.contain,
                            ),
                          ),

                          SizedBox(
                            height:
                                height * 0.035,
                          ),

                          Text(
                            'مواعيدك.. بصحة أفضل\nوتنظيم مطمئن',
                            textAlign:
                                TextAlign.center,
                            style: TextStyle(
                              color:
                                  const Color(
                                    0xFF718B9F,
                                  ),
                              fontSize:
                                  isTablet
                                      ? 22
                                      : width *
                                          0.045,
                              fontWeight:
                                  FontWeight.w400,
                              height: 1.7,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: SizedBox(
                        height:
                            height * 0.20,
                        child: CustomPaint(
                          painter:
                              _BottomWavePainter(),
                        ),
                      ),
                    ),

                    Positioned(
                      left: 0,
                      bottom: 0,
                      child: SizedBox(
                        width:
                            width * 0.27,
                        height:
                            height * 0.16,
                        child: CustomPaint(
                          painter:
                              _PlantPainter(),
                        ),
                      ),
                    ),

                    Positioned(
                      right:
                          width * 0.07,
                      bottom:
                          height * 0.045,
                      child: Row(
                        mainAxisSize:
                            MainAxisSize.min,
                        children: [
                          Text(
                            'صحتك تهمنا',
                            style: TextStyle(
                              color:
                                  const Color(
                                    0xFF177FA4,
                                  ),
                              fontSize:
                                  isTablet
                                      ? 20
                                      : width *
                                          0.042,
                              fontWeight:
                                  FontWeight.w700,
                            ),
                          ),

                          SizedBox(
                            width:
                                width * 0.015,
                          ),

                          Icon(
                            Icons.favorite,
                            color:
                                const Color(
                                  0xFF178AAF,
                                ),
                            size:
                                isTablet
                                    ? 22
                                    : width *
                                        0.055,
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomWavePainter extends CustomPainter {
  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final paint = Paint()
      ..color =
          const Color(0xFFEDF7F7)
      ..style = PaintingStyle.fill;

    final path = Path();

    path.moveTo(
      0,
      size.height * 0.32,
    );

    path.cubicTo(
      size.width * 0.20,
      size.height * 0.02,
      size.width * 0.38,
      size.height * 0.55,
      size.width * 0.60,
      size.height * 0.42,
    );

    path.cubicTo(
      size.width * 0.78,
      size.height * 0.32,
      size.width * 0.90,
      size.height * 0.08,
      size.width,
      0,
    );

    path.lineTo(
      size.width,
      size.height,
    );

    path.lineTo(
      0,
      size.height,
    );

    path.close();

    canvas.drawPath(
      path,
      paint,
    );
  }

  @override
  bool shouldRepaint(
    covariant CustomPainter oldDelegate,
  ) {
    return false;
  }
}

class _PlantPainter extends CustomPainter {
  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final stemPaint = Paint()
      ..color =
          const Color(0xFF76CDBE)
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final leafPaint = Paint()
      ..color =
          const Color(0xFF83D5C5)
      ..style = PaintingStyle.fill;

    final stem = Path();

    stem.moveTo(
      size.width * 0.15,
      size.height,
    );

    stem.quadraticBezierTo(
      size.width * 0.24,
      size.height * 0.50,
      size.width * 0.23,
      size.height * 0.12,
    );

    canvas.drawPath(
      stem,
      stemPaint,
    );

    final branch = Path();

    branch.moveTo(
      size.width * 0.20,
      size.height * 0.68,
    );

    branch.quadraticBezierTo(
      size.width * 0.48,
      size.height * 0.54,
      size.width * 0.67,
      size.height * 0.54,
    );

    canvas.drawPath(
      branch,
      stemPaint,
    );

    _drawLeaf(
      canvas,
      Offset(
        size.width * 0.18,
        size.height * 0.40,
      ),
      size.width * 0.20,
      size.height * 0.25,
      -0.50,
      leafPaint,
    );

    _drawLeaf(
      canvas,
      Offset(
        size.width * 0.30,
        size.height * 0.62,
      ),
      size.width * 0.22,
      size.height * 0.25,
      0.65,
      leafPaint,
    );

    _drawLeaf(
      canvas,
      Offset(
        size.width * 0.49,
        size.height * 0.56,
      ),
      size.width * 0.28,
      size.height * 0.22,
      1.00,
      leafPaint,
    );
  }

  void _drawLeaf(
    Canvas canvas,
    Offset center,
    double width,
    double height,
    double angle,
    Paint paint,
  ) {
    canvas.save();

    canvas.translate(
      center.dx,
      center.dy,
    );

    canvas.rotate(angle);

    final path = Path();

    path.moveTo(
      0,
      -height / 2,
    );

    path.cubicTo(
      width / 2,
      -height / 4,
      width / 2,
      height / 3,
      0,
      height / 2,
    );

    path.cubicTo(
      -width / 2,
      height / 3,
      -width / 2,
      -height / 4,
      0,
      -height / 2,
    );

    path.close();

    canvas.drawPath(
      path,
      paint,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(
    covariant CustomPainter oldDelegate,
  ) {
    return false;
  }
}