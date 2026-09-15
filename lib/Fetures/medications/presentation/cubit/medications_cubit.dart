import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/model/medication_model.dart';
import '../../data/model/doise_model.dart';
import 'medications_state.dart';
import '../../../Auth/data/local/auth_local_storage.dart';
import '../../services/notification_service.dart';

class MedicationsCubit extends Cubit<MedicationsState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  StreamSubscription? _medicationsSub;
  StreamSubscription? _dosesSub;

  // المريض اللي بنعرض/نتعامل مع بياناته حاليًا.
  String? _currentPatientId;

  List<MedicationModel> _medications = [];
  List<MedicationDoseModel> _doses = [];

  MedicationsCubit() : super(MedicationsInitial()) {
    _initNotifications();
  }

  Future<void> _initNotifications() async {
    await NotificationService().init();
  }

  // UID المستخدم المسجل حاليًا (Patient أو Caregiver).
  String? _getUid() {
    return AuthLocalStorage.getUser()?.uid;
  }

  // لو عندنا Patient ID نستخدمه، وإلا نرجع للمستخدم الحالي.
  String? _resolvePatientId([String? patientId]) {
    if (patientId != null && patientId.isNotEmpty) {
      return patientId;
    }

    if (_currentPatientId != null && _currentPatientId!.isNotEmpty) {
      return _currentPatientId;
    }

    return _getUid();
  }

  // ==============================================================
  // LOAD MEDICATIONS + DOSES
  // ==============================================================

  void loadMedications({
    String? patientId,
    bool updateFilter = false,
  }) {
    final targetPatientId = _resolvePatientId(patientId);

    if (targetPatientId == null || targetPatientId.isEmpty) {
      emit(MedicationsError('User not logged in'));
      return;
    }

    // حتى لو updateFilter = false، لازم نعرف إحنا بنسمع بيانات مين.
    if (updateFilter || _currentPatientId == null) {
      _currentPatientId = targetPatientId;
    } else if (patientId != null && patientId.isNotEmpty) {
      _currentPatientId = patientId;
    }

    emit(MedicationsLoading());

    _medicationsSub?.cancel();
    _dosesSub?.cancel();

    // مهم:
    // بنقرأ من Document المريض نفسه، مش من Document الـ Caregiver.
    _medicationsSub = _firestore
        .collection('users')
        .doc(targetPatientId)
        .collection('medications')
        .snapshots()
        .listen(
      (medSnapshot) {
        _medications = medSnapshot.docs
            .map((doc) => MedicationModel.fromMap(doc.data()))
            .toList();

        _emitCombinedState();
      },
      onError: (error) {
        emit(
          MedicationsError(
            'Failed to load medications: $error',
          ),
        );
      },
    );

    _dosesSub = _firestore
        .collection('users')
        .doc(targetPatientId)
        .collection('doses')
        .snapshots()
        .listen(
      (doseSnapshot) {
        _doses = doseSnapshot.docs
            .map((doc) => MedicationDoseModel.fromMap(doc.data()))
            .toList();

        _emitCombinedState();
      },
      onError: (error) {
        emit(
          MedicationsError(
            'Failed to load doses: $error',
          ),
        );
      },
    );
  }

  void _emitCombinedState() {
    try {
      var medications = _medications.toList();

      // Safety filter فقط.
      if (_currentPatientId != null &&
          _currentPatientId!.isNotEmpty) {
        medications = medications
            .where(
              (medication) =>
                  medication.patientId == _currentPatientId,
            )
            .toList();
      }

      final medicationIds =
          medications.map((medication) => medication.id).toSet();

      final patientDoses = _doses
          .where(
            (dose) => medicationIds.contains(dose.medicationId),
          )
          .toList();

      final now = DateTime.now();
      final today = DateTime(
        now.year,
        now.month,
        now.day,
      );

      final todaysDoses = patientDoses.where((dose) {
        final doseDate = DateTime(
          dose.date.year,
          dose.date.month,
          dose.date.day,
        );

        return doseDate.isAtSameMomentAs(today);
      }).toList();

      todaysDoses.sort(
        (a, b) => (a.time.hour * 60 + a.time.minute).compareTo(
          b.time.hour * 60 + b.time.minute,
        ),
      );

      final takenDoses = todaysDoses
          .where(
            (dose) => dose.status == DoseStatus.taken,
          )
          .length;

      emit(
        MedicationsLoaded(
          medications: medications,
          todaysDoses: todaysDoses,
          takenDosesCount: takenDoses,
          totalDosesCount: todaysDoses.length,
        ),
      );
    } catch (error) {
      emit(
        MedicationsError(
          'Failed to combine medications state: $error',
        ),
      );
    }
  }

  // ==============================================================
  // ADD MEDICATION
  // ==============================================================

  Future<void> addMedication(
    MedicationModel medication,
  ) async {
    // أهم تعديل:
    // الدواء يتحفظ تحت UID المريض صاحب الدواء.
    final patientId = medication.patientId.trim();

    if (patientId.isEmpty) {
      emit(
        MedicationsError(
          'Cannot add medication: patientId is empty',
        ),
      );
      return;
    }

    try {
      final batch = _firestore.batch();

      final medRef = _firestore
          .collection('users')
          .doc(patientId)
          .collection('medications')
          .doc(medication.id);

      batch.set(
        medRef,
        medication.toMap(),
      );

      final endDate =
          medication.endDate.isAfter(medication.startDate)
              ? medication.endDate
              : medication.startDate.add(
                  const Duration(days: 30),
                );

      for (
        int i = 0;
        i <= endDate.difference(medication.startDate).inDays;
        i++
      ) {
        final date = medication.startDate.add(
          Duration(days: i),
        );

        for (final time in medication.intakeTimes) {
          final doseId =
              '${medication.id}_${date.millisecondsSinceEpoch}_${time.hour}_${time.minute}';

          final dose = MedicationDoseModel(
            id: doseId,
            medicationId: medication.id,
            date: date,
            time: time,
            status: DoseStatus.pending,
          );

          final doseRef = _firestore
              .collection('users')
              .doc(patientId)
              .collection('doses')
              .doc(doseId);

          batch.set(
            doseRef,
            dose.toMap(),
          );

          final scheduledDate = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );

          NotificationService().scheduleMedicationReminder(
            doseId: doseId,
            title: 'Time for your medication!',
            body:
                'It is time to take ${medication.dosage} of ${medication.medicationName}',
            scheduledDate: scheduledDate,
          );
        }
      }

      await batch.commit();

      // نخلي الـCubit الحالي يعرف إنه بيتعامل مع نفس المريض.
      _currentPatientId = patientId;
    } catch (error) {
      emit(
        MedicationsError(
          'Failed to add medication: $error',
        ),
      );
    }
  }

  // ==============================================================
  // UPDATE DOSE STATUS
  // ==============================================================

  Future<void> updateDoseStatus(
    String doseId,
    DoseStatus status,
  ) async {
    final patientId = _resolvePatientId();

    if (patientId == null || patientId.isEmpty) {
      emit(
        MedicationsError(
          'Cannot update dose: patient not found',
        ),
      );
      return;
    }

    try {
      final doseRef = _firestore
          .collection('users')
          .doc(patientId)
          .collection('doses')
          .doc(doseId);

      await doseRef.update({
        'status': status.name,
      });
    } catch (error) {
      emit(
        MedicationsError(
          'Failed to update dose: $error',
        ),
      );
    }
  }

  // ==============================================================
  // DELETE MEDICATION
  // ==============================================================

  Future<void> deleteMedication(
    String id,
  ) async {
    String? patientId;

    try {
      final medication = _medications.firstWhere(
        (med) => med.id == id,
      );

      patientId = medication.patientId;
    } catch (_) {
      patientId = _resolvePatientId();
    }

    if (patientId == null || patientId.isEmpty) {
      emit(
        MedicationsError(
          'Cannot delete medication: patient not found',
        ),
      );
      return;
    }

    try {
      final batch = _firestore.batch();

      final medRef = _firestore
          .collection('users')
          .doc(patientId)
          .collection('medications')
          .doc(id);

      batch.delete(medRef);

      final dosesToDelete = _doses
          .where(
            (dose) => dose.medicationId == id,
          )
          .toList();

      for (final dose in dosesToDelete) {
        final doseRef = _firestore
            .collection('users')
            .doc(patientId)
            .collection('doses')
            .doc(dose.id);

        batch.delete(doseRef);

        NotificationService().cancelNotification(
          dose.id,
        );
      }

      await batch.commit();
    } catch (error) {
      emit(
        MedicationsError(
          'Failed to delete medication: $error',
        ),
      );
    }
  }

  // ==============================================================
  // TOGGLE MEDICATION STATUS
  // ==============================================================

  Future<void> toggleMedicationStatus(
    String id,
  ) async {
    try {
      final med = _medications.firstWhere(
        (medication) => medication.id == id,
      );

      final patientId = med.patientId;

      if (patientId.isEmpty) {
        emit(
          MedicationsError(
            'Cannot update medication: patientId is empty',
          ),
        );
        return;
      }

      final newStatus =
          med.status == MedicationStatus.active
              ? MedicationStatus.stopped
              : MedicationStatus.active;

      final medRef = _firestore
          .collection('users')
          .doc(patientId)
          .collection('medications')
          .doc(id);

      await medRef.update({
        'status': newStatus.name,
      });

      if (newStatus == MedicationStatus.stopped) {
        final futureDoses = _doses.where(
          (dose) =>
              dose.medicationId == id &&
              dose.status == DoseStatus.pending,
        );

        for (final dose in futureDoses) {
          NotificationService().cancelNotification(
            dose.id,
          );
        }
      } else {
        final futureDoses = _doses.where(
          (dose) =>
              dose.medicationId == id &&
              dose.status == DoseStatus.pending,
        );

        for (final dose in futureDoses) {
          final scheduledDate = DateTime(
            dose.date.year,
            dose.date.month,
            dose.date.day,
            dose.time.hour,
            dose.time.minute,
          );

          NotificationService().scheduleMedicationReminder(
            doseId: dose.id,
            title: 'Time for your medication!',
            body:
                'It is time to take ${med.dosage} of ${med.medicationName}',
            scheduledDate: scheduledDate,
          );
        }
      }
    } catch (error) {
      emit(
        MedicationsError(
          'Failed to toggle medication status: $error',
        ),
      );
    }
  }

  // ==============================================================
  // UPDATE MEDICATION
  // ==============================================================

  Future<void> updateMedication(
    MedicationModel medication,
  ) async {
    final patientId = medication.patientId.trim();

    if (patientId.isEmpty) {
      emit(
        MedicationsError(
          'Cannot update medication: patientId is empty',
        ),
      );
      return;
    }

    try {
      final batch = _firestore.batch();

      final medRef = _firestore
          .collection('users')
          .doc(patientId)
          .collection('medications')
          .doc(medication.id);

      batch.set(
        medRef,
        medication.toMap(),
      );

      final futureDosesToDelete = _doses.where(
        (dose) =>
            dose.medicationId == medication.id &&
            dose.date.isAfter(
              DateTime.now().subtract(
                const Duration(days: 1),
              ),
            ) &&
            dose.status == DoseStatus.pending,
      ).toList();

      for (final dose in futureDosesToDelete) {
        final doseRef = _firestore
            .collection('users')
            .doc(patientId)
            .collection('doses')
            .doc(dose.id);

        batch.delete(doseRef);

        NotificationService().cancelNotification(
          dose.id,
        );
      }

      final endDate =
          medication.endDate.isAfter(medication.startDate)
              ? medication.endDate
              : medication.startDate.add(
                  const Duration(days: 30),
                );

      final now = DateTime.now();

      final today = DateTime(
        now.year,
        now.month,
        now.day,
      );

      final start = medication.startDate.isBefore(today)
          ? today
          : medication.startDate;

      for (
        int i = 0;
        i <= endDate.difference(start).inDays;
        i++
      ) {
        final date = start.add(
          Duration(days: i),
        );

        for (final time in medication.intakeTimes) {
          final doseId =
              '${medication.id}_${date.millisecondsSinceEpoch}_${time.hour}_${time.minute}';

          final dose = MedicationDoseModel(
            id: doseId,
            medicationId: medication.id,
            date: date,
            time: time,
            status: DoseStatus.pending,
          );

          final doseRef = _firestore
              .collection('users')
              .doc(patientId)
              .collection('doses')
              .doc(doseId);

          batch.set(
            doseRef,
            dose.toMap(),
          );

          final scheduledDate = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );

          NotificationService().scheduleMedicationReminder(
            doseId: doseId,
            title: 'Time for your medication!',
            body:
                'It is time to take ${medication.dosage} of ${medication.medicationName}',
            scheduledDate: scheduledDate,
          );
        }
      }

      await batch.commit();

      _currentPatientId = patientId;
    } catch (error) {
      emit(
        MedicationsError(
          'Failed to update medication: $error',
        ),
      );
    }
  }

  @override
  Future<void> close() {
    _medicationsSub?.cancel();
    _dosesSub?.cancel();

    return super.close();
  }
}
