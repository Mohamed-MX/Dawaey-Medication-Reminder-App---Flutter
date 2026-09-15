abstract class SplashState {}

class SplashInitial extends SplashState {}

class SplashLoading extends SplashState {}

class SplashShowOnboarding extends SplashState {}

class SplashShowLogin extends SplashState {}

class SplashShowCaregiverHome extends SplashState {}

class SplashShowPatientHome extends SplashState {}

class SplashError extends SplashState {
  final String message;

  SplashError(this.message);
}