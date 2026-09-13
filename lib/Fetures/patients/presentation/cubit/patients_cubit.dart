import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import '../../data/model/patient_model.dart';
import 'patients_state.dart';

class PatientsCubit extends Cubit<PatientsState> {
  final Box<PatientModel> _patientsBox;

  PatientsCubit(this._patientsBox) : super(PatientsInitial());

  void loadPatients() {
    emit(PatientsLoading());
    try {
      List<PatientModel> patients = _patientsBox.values.toList();
      
      // If no patients exist, create a default "Me" patient
      if (patients.isEmpty) {
        final defaultPatient = PatientModel(
          id: 'user_1',
          name: 'أنا',
          relationship: 'نفسي',
        );
        _patientsBox.put(defaultPatient.id, defaultPatient);
        patients = [defaultPatient];
      }
      
      // Default selection to "Me" if available, or the first patient
      String? defaultSelectionId = patients.isNotEmpty ? patients.first.id : null;
      
      emit(PatientsLoaded(
        patients: patients,
        selectedPatientId: defaultSelectionId,
      ));
    } catch (e) {
      emit(PatientsError("Failed to load patients: $e"));
    }
  }

  void addPatient(PatientModel patient) async {
    try {
      await _patientsBox.put(patient.id, patient);
      final currentState = state;
      if (currentState is PatientsLoaded) {
        final updatedPatients = _patientsBox.values.toList();
        emit(PatientsLoaded(
          patients: updatedPatients,
          selectedPatientId: patient.id, // Auto-select the newly added patient
        ));
      } else {
        loadPatients();
      }
    } catch (e) {
      emit(PatientsError("Failed to add patient: $e"));
    }
  }

  void selectPatient(String? patientId) {
    final currentState = state;
    if (currentState is PatientsLoaded) {
      emit(PatientsLoaded(
        patients: currentState.patients,
        selectedPatientId: patientId,
      ));
    }
  }
}
