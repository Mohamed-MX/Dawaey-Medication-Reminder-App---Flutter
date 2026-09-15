import 'package:dawaey/Fetures/history/data/model/history_data_model.dart';

abstract class PatientHomeState {}

class PatientHomeInitial extends PatientHomeState {}

class PatientHomeLoading extends PatientHomeState {}

class PatientHomeLoaded extends PatientHomeState {
  final List<HistoryDataModel> upcomingDoses;
  final HistoryDataModel? currentDose;
  final int completedDoses;
  final int totalDoses;
  final int selectedIndex;
   PatientHomeLoaded({
    required this.upcomingDoses,
    required this.currentDose,
    required this.completedDoses,
    required this.totalDoses,
    required this.selectedIndex,
  });
  PatientHomeLoaded copyWith({
    List<HistoryDataModel>? upcomingDoses,
    HistoryDataModel? currentDose,
    bool clearCurrentDose = false,
    int? completedDoses,
    int? totalDoses,
    int? selectedIndex,
  }) {
    return PatientHomeLoaded(
      upcomingDoses: upcomingDoses ?? this.upcomingDoses,
      currentDose: clearCurrentDose ? null : currentDose ?? this.currentDose,
      completedDoses: completedDoses ?? this.completedDoses,
      totalDoses: totalDoses ?? this.totalDoses,
      selectedIndex: selectedIndex ?? this.selectedIndex,
    );
  }
}

class PatientHomeError extends PatientHomeState {
  final String message;
  PatientHomeError(this.message);
}
