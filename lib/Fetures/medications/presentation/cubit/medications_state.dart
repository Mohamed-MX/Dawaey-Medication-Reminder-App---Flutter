import 'package:flutter/material.dart';
import '../../data/model/medication_model.dart';
import '../../data/model/doise_model.dart';

@immutable
abstract class MedicationsState {}

class MedicationsInitial extends MedicationsState {}

class MedicationsLoading extends MedicationsState {}

class MedicationsLoaded extends MedicationsState {
  final List<MedicationModel> medications;
  final List<MedicationDoseModel> todaysDoses;
  final int takenDosesCount;
  final int totalDosesCount;

  MedicationsLoaded({
    required this.medications,
    required this.todaysDoses,
    required this.takenDosesCount,
    required this.totalDosesCount,
  });

  MedicationModel? getMedicationById(String id) {
    try {
      return medications.firstWhere((element) => element.id == id);
    } catch (e) {
      return null;
    }
  }
}

class MedicationsError extends MedicationsState {
  final String message;

  MedicationsError(this.message);
}
