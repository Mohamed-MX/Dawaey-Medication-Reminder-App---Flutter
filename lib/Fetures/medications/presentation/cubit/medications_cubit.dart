import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:hive/hive.dart';
import '../../data/model/medication_model.dart';
import '../../data/model/doise_model.dart';
import 'medications_state.dart';
import '../../../Auth/data/local/auth_local_storage.dart';
import '../../services/notification_service.dart';

class MedicationsCubit extends Cubit<MedicationsState> {
  // final Box<MedicationModel> _medicationsBox;
  // final Box<MedicationDoseModel> _dosesBox;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  StreamSubscription? _medicationsSub;
  StreamSubscription? _dosesSub;
  
  String? _currentPatientId;

  List<MedicationModel> _medications = [];
  List<MedicationDoseModel> _doses = [];

  // MedicationsCubit(this._medicationsBox, this._dosesBox) : super(MedicationsInitial());
  MedicationsCubit() : super(MedicationsInitial()) {
    _initNotifications();
  }

  void _initNotifications() async {
    await NotificationService().init();
  }

  String? _getUid() {
    return AuthLocalStorage.getUser()?.uid;
  }

  void loadMedications({String? patientId, bool updateFilter = false}) {
    if (updateFilter) {
      _currentPatientId = patientId;
    }

    final uid = _getUid();
    if (uid == null) {
      emit(MedicationsError("User not logged in"));
      return;
    }

    emit(MedicationsLoading());

    _medicationsSub?.cancel();
    _dosesSub?.cancel();

    _medicationsSub = _firestore
        .collection('users')
        .doc(uid)
        .collection('medications')
        .snapshots()
        .listen((medSnapshot) {
      _medications = medSnapshot.docs.map((d) => MedicationModel.fromMap(d.data())).toList();
      _emitCombinedState();
    }, onError: (e) => emit(MedicationsError(e.toString())));

    _dosesSub = _firestore
        .collection('users')
        .doc(uid)
        .collection('doses')
        .snapshots()
        .listen((doseSnapshot) {
      _doses = doseSnapshot.docs.map((d) => MedicationDoseModel.fromMap(d.data())).toList();
      _emitCombinedState();
    }, onError: (e) => emit(MedicationsError(e.toString())));
  }

  void _emitCombinedState() {
    try {
      var medications = _medications.toList();
      
      // Filter by patient if _currentPatientId is not null
      if (_currentPatientId != null) {
         medications = medications.where((m) => m.patientId == _currentPatientId).toList();
      }
      
      final medicationIds = medications.map((m) => m.id).toSet();
      
      final allDoses = _doses.toList();
      
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
      emit(MedicationsError("Failed to combine medications state: $e"));
    }
  }

  void addMedication(MedicationModel medication) async {
    final uid = _getUid();
    if (uid == null) return;

    try {
      final batch = _firestore.batch();
      final medRef = _firestore.collection('users').doc(uid).collection('medications').doc(medication.id);
      batch.set(medRef, medication.toMap());
      
      final endDate = medication.endDate.isAfter(medication.startDate) 
          ? medication.endDate 
          : medication.startDate.add(const Duration(days: 30));

      for (int i = 0; i <= endDate.difference(medication.startDate).inDays; i++) {
        final date = medication.startDate.add(Duration(days: i));
        for (var time in medication.intakeTimes) {
           final doseId = '${medication.id}_${date.millisecondsSinceEpoch}_${time.hour}_${time.minute}';
           final dose = MedicationDoseModel(
             id: doseId,
             medicationId: medication.id,
             date: date,
             time: time,
             status: DoseStatus.pending,
           );
           final doseRef = _firestore.collection('users').doc(uid).collection('doses').doc(doseId);
           batch.set(doseRef, dose.toMap());
           
           final scheduledDate = DateTime(date.year, date.month, date.day, time.hour, time.minute);
           NotificationService().scheduleMedicationReminder(
             doseId: doseId,
             title: 'Time for your medication!',
             body: 'It is time to take ${medication.dosage} of ${medication.medicationName}',
             scheduledDate: scheduledDate,
           );
        }
      }
      
      await batch.commit();
    } catch (e) {
      emit(MedicationsError("Failed to add medication: $e"));
    }
  }

  void updateDoseStatus(String doseId, DoseStatus status) async {
    final uid = _getUid();
    if (uid == null) return;

    try {
      final doseRef = _firestore.collection('users').doc(uid).collection('doses').doc(doseId);
      await doseRef.update({'status': status.name});
    } catch (e) {
      emit(MedicationsError("Failed to update dose: $e"));
    }
  }

  void deleteMedication(String id) async {
    final uid = _getUid();
    if (uid == null) return;

    try {
      final batch = _firestore.batch();
      
      // Delete medication
      final medRef = _firestore.collection('users').doc(uid).collection('medications').doc(id);
      batch.delete(medRef);
      
      // Delete associated doses
      final dosesToDelete = _doses.where((d) => d.medicationId == id).toList();
      for (var dose in dosesToDelete) {
        final doseRef = _firestore.collection('users').doc(uid).collection('doses').doc(dose.id);
        batch.delete(doseRef);
        NotificationService().cancelNotification(dose.id);
      }
      
      await batch.commit();
    } catch (e) {
      emit(MedicationsError("Failed to delete medication: $e"));
    }
  }

  void toggleMedicationStatus(String id) async {
    final uid = _getUid();
    if (uid == null) return;

    try {
      final med = _medications.firstWhere((m) => m.id == id);
      final newStatus = med.status == MedicationStatus.active 
          ? MedicationStatus.stopped 
          : MedicationStatus.active;
          
      final medRef = _firestore.collection('users').doc(uid).collection('medications').doc(id);
      await medRef.update({'status': newStatus.name});

      if (newStatus == MedicationStatus.stopped) {
         final futureDoses = _doses.where((d) => d.medicationId == id && d.status == DoseStatus.pending);
         for (var dose in futureDoses) {
             NotificationService().cancelNotification(dose.id);
         }
      } else {
         final futureDoses = _doses.where((d) => d.medicationId == id && d.status == DoseStatus.pending);
         for (var dose in futureDoses) {
             final scheduledDate = DateTime(dose.date.year, dose.date.month, dose.date.day, dose.time.hour, dose.time.minute);
             NotificationService().scheduleMedicationReminder(
                doseId: dose.id,
                title: 'Time for your medication!',
                body: 'It is time to take ${med.dosage} of ${med.medicationName}',
                scheduledDate: scheduledDate,
             );
         }
      }
    } catch (e) {
      emit(MedicationsError("Failed to toggle medication status: $e"));
    }
  }

  void updateMedication(MedicationModel medication) async {
    final uid = _getUid();
    if (uid == null) return;

    try {
      final batch = _firestore.batch();
      
      // Update medication
      final medRef = _firestore.collection('users').doc(uid).collection('medications').doc(medication.id);
      batch.set(medRef, medication.toMap());
      
      // Delete future pending doses
      final futureDosesToDelete = _doses.where((d) => 
        d.medicationId == medication.id && 
        d.date.isAfter(DateTime.now().subtract(const Duration(days: 1))) &&
        d.status == DoseStatus.pending
      ).toList();
      
      for (var dose in futureDosesToDelete) {
        final doseRef = _firestore.collection('users').doc(uid).collection('doses').doc(dose.id);
        batch.delete(doseRef);
        NotificationService().cancelNotification(dose.id);
      }

      final endDate = medication.endDate.isAfter(medication.startDate) 
          ? medication.endDate 
          : medication.startDate.add(const Duration(days: 30));
          
      // Recreate doses from today onwards
      final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
      final start = medication.startDate.isBefore(today) ? today : medication.startDate;

      for (int i = 0; i <= endDate.difference(start).inDays; i++) {
        final date = start.add(Duration(days: i));
        for (var time in medication.intakeTimes) {
           final doseId = '${medication.id}_${date.millisecondsSinceEpoch}_${time.hour}_${time.minute}';
           final dose = MedicationDoseModel(
             id: doseId,
             medicationId: medication.id,
             date: date,
             time: time,
             status: DoseStatus.pending,
           );
           final doseRef = _firestore.collection('users').doc(uid).collection('doses').doc(doseId);
           batch.set(doseRef, dose.toMap());

           final scheduledDate = DateTime(date.year, date.month, date.day, time.hour, time.minute);
           NotificationService().scheduleMedicationReminder(
             doseId: doseId,
             title: 'Time for your medication!',
             body: 'It is time to take ${medication.dosage} of ${medication.medicationName}',
             scheduledDate: scheduledDate,
           );
        }
      }

      await batch.commit();
    } catch (e) {
      emit(MedicationsError("Failed to update medication: $e"));
    }
  }

  @override
  Future<void> close() {
    _medicationsSub?.cancel();
    _dosesSub?.cancel();
    return super.close();
  }
}
