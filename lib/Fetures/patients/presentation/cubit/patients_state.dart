import '../../data/model/patient_model.dart';

abstract class PatientsState {}

class PatientsInitial extends PatientsState {}

class PatientsLoading extends PatientsState {}

class PatientsLoaded extends PatientsState {
  final List<PatientModel> patients;
  final String? selectedPatientId; // null means 'All'

  PatientsLoaded({
    required this.patients,
    this.selectedPatientId,
  });
}

class PatientsError extends PatientsState {
  final String message;

  PatientsError(this.message);
}
