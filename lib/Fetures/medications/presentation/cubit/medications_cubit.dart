import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import '../../data/model/medication_model.dart';
import '../../data/model/doise_model.dart';
import 'medications_state.dart';

class MedicationsCubit extends Cubit<MedicationsState> {
  final Box<MedicationModel> _medicationsBox;
  final Box<MedicationDoseModel> _dosesBox;
  String? _currentPatientId;

  MedicationsCubit(this._medicationsBox, this._dosesBox) : super(MedicationsInitial());

  void loadMedications({String? patientId, bool updateFilter = false}) {
    if (updateFilter) {
      _currentPatientId = patientId;
    }

    emit(MedicationsLoading());
    try {
      var medications = _medicationsBox.values.toList();
      
      // Filter by patient if _currentPatientId is not null
      if (_currentPatientId != null) {
         medications = medications.where((m) => m.patientId == _currentPatientId).toList();
      }
      
      final medicationIds = medications.map((m) => m.id).toSet();
      
      final allDoses = _dosesBox.values.toList();
      
      // Filter doses by patient's medications
      final patientDoses = allDoses.where((d) => medicationIds.contains(d.medicationId)).toList();
      
      // Filter for today's doses
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      
      final todaysDoses = patientDoses.where((dose) {
        final doseDate = DateTime(dose.date.year, dose.date.month, dose.date.day);
        return doseDate.isAtSameMomentAs(today);
      }).toList();

      todaysDoses.sort((a, b) => (a.time.hour * 60 + a.time.minute).compareTo(b.time.hour * 60 + b.time.minute));

      final takenDoses = todaysDoses.where((d) => d.status == DoseStatus.taken).length;
      
      emit(MedicationsLoaded(
        medications: medications,
        todaysDoses: todaysDoses,
        takenDosesCount: takenDoses,
        totalDosesCount: todaysDoses.length,
      ));
    } catch (e) {
      emit(MedicationsError("Failed to load medications: $e"));
    }
  }

  void addMedication(MedicationModel medication) async {
    try {
      await _medicationsBox.put(medication.id, medication);
      
      final endDate = medication.endDate.isAfter(medication.startDate) 
          ? medication.endDate 
          : medication.startDate.add(const Duration(days: 30));

      for (int i = 0; i <= endDate.difference(medication.startDate).inDays; i++) {
        final date = medication.startDate.add(Duration(days: i));
        for (var time in medication.intakeTimes) {
           final dose = MedicationDoseModel(
             id: '${medication.id}_${date.millisecondsSinceEpoch}_${time.hour}_${time.minute}',
             medicationId: medication.id,
             date: date,
             time: time,
             status: DoseStatus.pending,
           );
           await _dosesBox.put(dose.id, dose);
        }
      }
      // Reload keeping current filter
      loadMedications();
    } catch (e) {
      emit(MedicationsError("Failed to add medication: $e"));
    }
  }

  void updateDoseStatus(String doseId, DoseStatus status) async {
    try {
      final dose = _dosesBox.get(doseId);
      if (dose != null) {
        final updatedDose = MedicationDoseModel(
          id: dose.id,
          medicationId: dose.medicationId,
          date: dose.date,
          time: dose.time,
          status: status,
        );
        await _dosesBox.put(doseId, updatedDose);
        // Reload keeping current filter
        loadMedications();
      }
    } catch (e) {
      emit(MedicationsError("Failed to update dose: $e"));
    }
  }
}
