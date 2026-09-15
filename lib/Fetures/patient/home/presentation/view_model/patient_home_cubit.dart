import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dawaey/Fetures/medications/data/model/doise_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:dawaey/Fetures/history/data/model/history_data_model.dart';
import 'package:dawaey/Fetures/medications/data/model/medication_model.dart';

import 'patient_home_state.dart';

class PatientHomeCubit extends Cubit<PatientHomeState> {
  PatientHomeCubit({
    required this.uid,
  }) : super(PatientHomeInitial());

  final String uid;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Timer? _timer;

  bool _isLoading = false;

  CollectionReference<Map<String, dynamic>> get _doseCollection {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('doses');
  }

  CollectionReference<Map<String, dynamic>> get _medicationCollection {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('medications');
  }


  Future<void> initialize() async {
    emit(PatientHomeLoading());

    await loadTodayDoses();

    _timer?.cancel();

    _timer = Timer.periodic(
      const Duration(minutes: 1),
      (_) {
        loadTodayDoses();
      },
    );
  }

  Future<void> loadTodayDoses() async {
    // Prevent two Firestore requests from running simultaneously.
    if (_isLoading) return;

    _isLoading = true;

    try {
      final now = DateTime.now();

      final startOfDay = DateTime(
        now.year,
        now.month,
        now.day,
      );

      final endOfDay = startOfDay.add(
        const Duration(days: 1),
      );

      print('UID FROM CONSTRUCTOR: $uid');

try {
  final test = await _firestore
      .collection('users')
      .doc(uid)
      .get();

  print('USER DOCUMENT EXISTS: ${test.exists}');
  print('USER DATA: ${test.data()}');
} catch (e) {
  print('USER DOCUMENT ERROR: $e');
}
      final doseSnapshot = await _doseCollection
          .where(
            'date',
            isGreaterThanOrEqualTo:
                Timestamp.fromDate(startOfDay),
          )
          .where(
            'date',
            isLessThan: Timestamp.fromDate(endOfDay),
          )
          .get();


      final medicationSnapshot =
          await _medicationCollection.get();

      final Map<String, MedicationModel> medications = {};

      for (final doc in medicationSnapshot.docs) {
        final medication = MedicationModel.fromMap(
          doc.data(),
        );

        medications[medication.id] = medication;
      }



      final List<HistoryDataModel> upcomingDoses = [];

      final List<HistoryDataModel> currentDoses = [];

      int completedDoses = 0;
      int totalDoses = 0;


      for (final doc in doseSnapshot.docs) {
        final data = doc.data();

        final dose = MedicationDoseModel.fromMap(data);

        totalDoses++;

        if (dose.status == DoseStatus.taken) {
          completedDoses++;
          continue;
        }

        if (dose.status != DoseStatus.pending) {
          continue;
        }


        final medication = medications[dose.medicationId];

        if (medication == null) {
          continue;
        }


        final doseDate = dose.date;

        final doseDateTime = DateTime(
          doseDate.year,
          doseDate.month,
          doseDate.day,
          dose.time.hour,
          dose.time.minute,
        );

        final doseEndTime = doseDateTime.add(
          const Duration(hours: 1),
        );


        if (!now.isBefore(doseEndTime)) {
          await doc.reference.update({
            'status': DoseStatus.missed.name,
          });

          continue;
        }
        final historyData = HistoryDataModel(
          medication: medication,
          dose: dose,
        );


        if (!now.isBefore(doseDateTime)) {
          currentDoses.add(historyData);
        } else {
          // Future dose
          upcomingDoses.add(historyData);
        }
      }

      upcomingDoses.sort(
        (a, b) {
          return _timeToMinutes(a.dose.time).compareTo(
            _timeToMinutes(b.dose.time),
          );
        },
      );

      currentDoses.sort(
        (a, b) {
          return _timeToMinutes(a.dose.time).compareTo(
            _timeToMinutes(b.dose.time),
          );
        },
      );

      HistoryDataModel? currentDose;

      if (currentDoses.isNotEmpty) {
        currentDose = currentDoses.first;
      }


      int selectedIndex = 0;

      if (state is PatientHomeLoaded) {
        selectedIndex =
            (state as PatientHomeLoaded).selectedIndex;
      }

      emit(
        PatientHomeLoaded(
          upcomingDoses: upcomingDoses,
          currentDose: currentDose,
          completedDoses: completedDoses,
          totalDoses: totalDoses,
          selectedIndex: selectedIndex,
        ),
      );
    } catch (e, stackTrace) {
  print('PATIENT HOME ERROR: $e');
  print(stackTrace);

  emit(
    PatientHomeError(
      'حدث خطأ أثناء تحميل الأدوية: $e',
    ),
  );
    } finally {
      _isLoading = false;
    }
  }


  Future<void> takeDose(
    MedicationDoseModel dose,
  ) async {
    try {
      await _doseCollection
          .doc(dose.id)
          .update({
        'status': DoseStatus.taken.name,
      });

      await loadTodayDoses();
    } catch (e) {
      emit(
         PatientHomeError(
          'حدث خطأ أثناء تسجيل الدواء',
        ),
      );
    }
  }


  Future<void> remindMeAfterHour(
    MedicationDoseModel dose,
  ) async {
    try {
      final result = _addOneHour(
        date: dose.date,
        time: dose.time,
      );

      await _doseCollection
          .doc(dose.id)
          .update({
        'date': Timestamp.fromDate(result.date),
        'time': {
          'hour': result.time.hour,
          'minute': result.time.minute,
        },
      });

      await loadTodayDoses();
    } catch (e) {
      emit(
         PatientHomeError(
          'حدث خطأ أثناء تأجيل الدواء',
        ),
      );
    }
  }

  _DoseDateTime _addOneHour({
    required DateTime date,
    required TimeOfDay time,
  }) {
    final dateTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    final newDateTime = dateTime.add(
      const Duration(hours: 1),
    );

    return _DoseDateTime(
      date: newDateTime,
      time: TimeOfDay(
        hour: newDateTime.hour,
        minute: newDateTime.minute,
      ),
    );
  }


  int _timeToMinutes(
    TimeOfDay time,
  ) {
    return time.hour * 60 + time.minute;
  }



  void changeBottomNavIndex(
    int index,
  ) {
    if (state is! PatientHomeLoaded) {
      return;
    }

    final currentState =
        state as PatientHomeLoaded;

    emit(
      currentState.copyWith(
        selectedIndex: index,
      ),
    );
  }



  @override
  Future<void> close() {
    _timer?.cancel();

    return super.close();
  }
}


class _DoseDateTime {
  final DateTime date;
  final TimeOfDay time;

  const _DoseDateTime({
    required this.date,
    required this.time,
  });
}