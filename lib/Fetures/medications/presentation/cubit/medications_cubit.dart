import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import '../../data/model/medication_model.dart';
import '../../data/model/doise_model.dart';
import 'medications_state.dart';

class MedicationsCubit extends Cubit<MedicationsState> {
  final Box<MedicationModel> _medicationsBox;
  final Box<MedicationDoseModel> _dosesBox;

  MedicationsCubit(this._medicationsBox, this._dosesBox) : super(MedicationsInitial());

  void loadMedications() {
    emit(MedicationsLoading());
    try {
      final medications = _medicationsBox.values.toList();
      final allDoses = _dosesBox.values.toList();
      
      // Filter for today's doses
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      
      final todaysDoses = allDoses.where((dose) {
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
        loadMedications();
      }
    } catch (e) {
      emit(MedicationsError("Failed to update dose: $e"));
    }
  }
}
