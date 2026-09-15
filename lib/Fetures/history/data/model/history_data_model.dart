import 'package:dawaey/Fetures/medications/data/model/doise_model.dart';
import 'package:dawaey/Fetures/medications/data/model/medication_model.dart';

class HistoryDataModel {
  final MedicationModel medication;
  final MedicationDoseModel dose;

  HistoryDataModel({
    required this.medication,
    required this.dose,
  });
}