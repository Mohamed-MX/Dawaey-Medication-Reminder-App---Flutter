import 'package:flutter/material.dart';

enum MedicationFrequency {
  onceDaily,
  twiceDaily,
  threeTimesDaily,
  onceWeekly,
}

enum MedicationStatus {
  active,
  stopped,
}
class MedicationModel {
  String medicationName;
  String administrationRoute;
  String dosage;
  MedicationFrequency frequency;
  List<TimeOfDay> intakeTimes;
  DateTime startDate;
  DateTime endDate;
  int remainingDoses;
  int remainingMedicationAmount;
  String notes;
  MedicationStatus status;

  MedicationModel({
    required this.medicationName,
    required this.administrationRoute,
    required this.dosage,
    required this.frequency,
    required this.intakeTimes,
    required this.startDate,
    required this.endDate,
    required this.remainingDoses,
    required this.remainingMedicationAmount,
    required this.notes,
    required this.status,
  });
}