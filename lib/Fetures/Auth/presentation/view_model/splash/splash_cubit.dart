import 'package:dawaey/Fetures/Auth/data/local/onboarding_local_storage.dart';
import 'package:dawaey/Fetures/Auth/data/models/user_model.dart';
import 'package:dawaey/Fetures/Auth/data/repositories/auth_repository.dart';
import 'package:dawaey/Fetures/Auth/presentation/view_model/splash/splash_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SplashCubit extends Cubit<SplashState> {
  SplashCubit() : super(SplashInitial());

  final AuthRepository repository = AuthRepository();

  Future<void> checkStartup() async {
    emit(SplashLoading());

    try {
      await Future.delayed(
        const Duration(seconds: 4),
      );

      final bool onboardingSeen =
          await OnboardingLocalStorage.isOnboardingSeen();

      if (!onboardingSeen) {
        emit(SplashShowOnboarding());
        return;
      }

      final user = await repository.getCurrentUser();

      if (user == null) {
        emit(SplashShowLogin());
        return;
      }

      if (user.role == UserRole.caregiver) {
        emit(SplashShowCaregiverHome());
        return;
      }

      if (user.role == UserRole.patient) {
        emit(SplashShowPatientHome());
        return;
      }

      emit(SplashShowLogin());
    } catch (e) {
      emit(
        SplashError(
          e.toString(),
        ),
      );
    }
  }
}