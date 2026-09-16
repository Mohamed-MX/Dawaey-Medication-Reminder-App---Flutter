import 'package:dawaey/Fetures/Auth/data/models/user_model.dart';
import 'package:dawaey/Fetures/Auth/presentation/view/login_screen.dart';
import 'package:dawaey/Fetures/Auth/presentation/view/onboarding_screen.dart';
import 'package:dawaey/Fetures/Auth/presentation/view/role_selection_screen.dart';
import 'package:dawaey/Fetures/Auth/presentation/view/signup_screen.dart';
import 'package:dawaey/Fetures/Auth/presentation/view/splash_screen.dart';
import 'package:dawaey/Fetures/Auth/presentation/view_model/auth_cubit.dart';
import 'package:dawaey/Fetures/Auth/presentation/view_model/auth_state.dart';

import 'package:dawaey/Fetures/caregiver/home/presentation/view/home_caretaker_screen.dart';

import 'package:dawaey/Fetures/history/presentation/view/history_screen.dart';

import 'package:dawaey/Fetures/medications/presentation/view/add_medication_screen.dart';
import 'package:dawaey/Fetures/medications/presentation/view/medication_details_screen.dart';

import 'package:dawaey/Fetures/patient/home/presentation/view/patient_main_screen.dart';

import 'package:dawaey/core/routes/app_routes.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:month_year_picker/month_year_picker.dart';

class MedicationReminderApp extends StatelessWidget {
  const MedicationReminderApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,


      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: SafeArea(
            top: false,
            child: child!,
          ),
        );
      },
      initialRoute: AppRoutes.splash,
      routes: {


        '/add_medications': (context) {
          final user =
              context.read<AuthCubit>().currentUser;

          if (user == null) {
            return const LoginScreen();
          }

          String? patientId;

          if (user.role == UserRole.patient) {
            patientId = user.uid;
          }

          if (user.role == UserRole.caregiver) {
            patientId = user.linkedUserId;
          }

          if (patientId == null ||
              patientId.isEmpty) {
            return const LoginScreen();
          }

          return AddMedicationScreen(
            targetPatientId: patientId,
          );
        },

        '/history': (context) {
          return BlocBuilder<AuthCubit, AuthState>(
            builder: (context, state) {
              if (state is AuthSuccess) {
                return HistoryScreen(
                  currentUser: state.user,
                );
              }

              return const LoginScreen();
            },
          );
        },
        '/medication_details' : (context) => MedicationDetailsScreen(),
        AppRoutes.splash: (context) {
          return const SplashScreen();
        },

        AppRoutes.onboarding: (context) {
          return const OnboardingScreen();
        },

        AppRoutes.login: (context) {
          return const LoginScreen();
        },

        AppRoutes.roleSelection: (context) {
          return const RoleSelectionScreen();
        },

        AppRoutes.patientSignup: (context) {
          return const SignupScreen(
            role: UserRole.patient,
          );
        },


        AppRoutes.caregiverSignup: (context) {
          return const SignupScreen(
            role: UserRole.caregiver,
          );
        },

        AppRoutes.caregiverHome: (context) {
          return const home_caretaker_screen();
        },

        AppRoutes.patientHome: (context) {
          final user =
              context.read<AuthCubit>().currentUser;

          if (user == null) {
            return const LoginScreen();
          }

          return PatientMainScreen(
            currentUser: user,
          );
        },
      },


      locale: const Locale(
        'ar',
        'EG',
      ),

      supportedLocales: const [
        Locale(
          'ar',
          'EG',
        ),
        Locale(
          'en',
          'US',
        ),
      ],

      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        MonthYearPickerLocalizations.delegate,
      ],

      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'NotoSansArabic',
      ),
    );
  }
}