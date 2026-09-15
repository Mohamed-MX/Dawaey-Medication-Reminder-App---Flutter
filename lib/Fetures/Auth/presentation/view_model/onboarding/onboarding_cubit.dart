import 'package:dawaey/Fetures/Auth/data/local/onboarding_local_storage.dart';
import 'package:dawaey/Fetures/Auth/presentation/view_model/onboarding/onboarding_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OnboardingCubit
    extends Cubit<OnboardingState> {
  OnboardingCubit()
      : super(
          OnboardingInitial(),
        );

  final PageController pageController =
      PageController();

  int currentPage = 0;

  void changePage(int index) {
    currentPage = index;

    emit(
      OnboardingPageChanged(),
    );
  }

  void nextPage() {
    pageController.nextPage(
      duration: const Duration(
        milliseconds: 300,
      ),
      curve: Curves.easeInOut,
    );
  }

  Future<void> finishOnboarding() async {
    emit(
      OnboardingLoading(),
    );

    try {
      await OnboardingLocalStorage
          .saveOnboardingSeen();

      emit(
        OnboardingCompleted(),
      );
    } catch (e) {
      emit(
        OnboardingError(
          e.toString(),
        ),
      );
    }
  }

  @override
  Future<void> close() {
    pageController.dispose();

    return super.close();
  }
}