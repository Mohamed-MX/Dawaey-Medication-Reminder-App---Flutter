import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../Auth/data/local/auth_local_storage.dart';
import '../../../Auth/data/models/user_model.dart';
import '../../../medications/data/model/doise_model.dart';
import '../../../medications/data/model/medication_model.dart';
import '../../data/models/report_model.dart';
import 'reports_state.dart';

class ReportsCubit extends Cubit<ReportsState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  ReportsCubit() : super(ReportsInitial());

  /// Returns the currently logged-in user, or null.
  UserModel? _getUser() {
    return AuthLocalStorage.getUser();
  }

  /// Resolves the patient whose data should be displayed.
  /// - If the user is a patient → their own uid.
  /// - If the user is a caregiver → the linkedUserId.
  String? _resolvePatientId(UserModel user) {
    if (user.role == UserRole.patient) {
      return user.uid;
    }
    // Caregiver: use the linked patient's uid
    if (user.role == UserRole.caregiver) {
      return (user.linkedUserId != null && user.linkedUserId!.isNotEmpty)
          ? user.linkedUserId
          : user.uid;
    }
    return user.uid;
  }

  Future<void> loadReportsData() async {
    emit(ReportsLoading());

    final user = _getUser();
    if (user == null) {
      emit(ReportsError('المستخدم غير مسجل الدخول'));
      return;
    }

    final patientId = _resolvePatientId(user);
    if (patientId == null || patientId.isEmpty) {
      emit(ReportsError('لا يمكن تحديد المريض'));
      return;
    }

    try {
      // 1. Patient display name — use the logged-in user's name
      String patientName = user.name.isNotEmpty ? user.name : 'مستخدم';

      // Try to get age from the patients subcollection (if available)
      int? patientAge;
      try {
        final patientSnapshot = await _firestore
            .collection('users')
            .doc(patientId)
            .collection('patients')
            .limit(1)
            .get();

        if (patientSnapshot.docs.isNotEmpty) {
          final data = patientSnapshot.docs.first.data();
          if (data['age'] != null) {
            patientAge = (data['age'] as num).toInt();
          }
          // If the user is a caregiver, show the patient's name
          if (user.role == UserRole.caregiver &&
              data['name'] != null &&
              (data['name'] as String).isNotEmpty) {
            patientName = data['name'] as String;
          }
        }
      } catch (_) {
        // Ignore — age is optional
      }

      // 2. Fetch ALL doses for this patient from Firestore
      final dosesSnapshot = await _firestore
          .collection('users')
          .doc(patientId)
          .collection('doses')
          .get();

      final doses = dosesSnapshot.docs
          .map((doc) => MedicationDoseModel.fromMap(doc.data()))
          .toList();

      // 3. Compute weekly commitment ratios (Sat=1 to Fri=7 in our mapping)
      final now = DateTime.now();
      List<double> weeklyData = _calculateWeeklyData(doses);

      // 5. Fetch Today's Medications & Doses
      final todayStart = DateTime(now.year, now.month, now.day);
      final todayEnd = todayStart.add(const Duration(days: 1));

      final todayDoses = doses.where((d) {
        final doseDate = DateTime(d.date.year, d.date.month, d.date.day);
        return !doseDate.isBefore(todayStart) && doseDate.isBefore(todayEnd);
      }).toList();

      List<TodayMedicationReport> todayMedications = [];

      if (todayDoses.isNotEmpty) {
        // Get the medication IDs from today's doses
        final medIds = todayDoses.map((d) => d.medicationId).toSet().toList();

        // Firestore whereIn limit is 10, batch if needed
        List<MedicationModel> medications = [];
        for (int i = 0; i < medIds.length; i += 10) {
          final batch = medIds.sublist(
            i,
            i + 10 > medIds.length ? medIds.length : i + 10,
          );
          final medsSnapshot = await _firestore
              .collection('users')
              .doc(patientId)
              .collection('medications')
              .where(FieldPath.documentId, whereIn: batch)
              .get();

          medications.addAll(
            medsSnapshot.docs
                .map((doc) => MedicationModel.fromMap(doc.data()))
                .toList(),
          );
        }

        for (var dose in todayDoses) {
          MedicationModel? med;
          try {
            med = medications.firstWhere((m) => m.id == dose.medicationId);
          } catch (_) {
            med = null;
          }

          final hourStr =
              dose.time.hourOfPeriod == 0 ? 12 : dose.time.hourOfPeriod;
          final periodStr = dose.time.period == DayPeriod.am ? 'ص' : 'م';
          final minuteStr = dose.time.minute.toString().padLeft(2, '0');
          final timeFormatted = '$hourStr:$minuteStr $periodStr';

          todayMedications.add(
            TodayMedicationReport(
              id: dose.id,
              name: med?.medicationName ?? 'دواء غير معروف',
              dosage: med?.dosage ?? '',
              time: timeFormatted,
              status: dose.status.name,
            ),
          );
        }
      }

      // Compute stats scoped to the default period (weekly)
      final weekStart = now.subtract(const Duration(days: 7));
      final weekDoses = doses.where((d) =>
          d.date.isAfter(weekStart) || d.date.isAtSameMomentAs(weekStart));
      final weekTaken =
          weekDoses.where((d) => d.status == DoseStatus.taken).length;
      final weekMissed =
          weekDoses.where((d) => d.status == DoseStatus.missed).length;
      final weekPending =
          weekDoses.where((d) => d.status == DoseStatus.pending).length;
      final weekTotal = weekDoses.length;
      final weekCommitment =
          weekTotal == 0 ? 0 : ((weekTaken / weekTotal) * 100).round();

      final summary = ReportSummaryModel(
        commitmentPercentage: weekCommitment,
        takenCount: weekTaken,
        missedCount: weekMissed,
        pendingCount: weekPending,
        weeklyData: weeklyData,
      );

      final defaultWeeklyLabels = [
        'السبت',
        'الأحد',
        'الاثنين',
        'الثلاثاء',
        'الأربعاء',
        'الخميس',
        'الجمعة',
      ];

      emit(
        ReportsSuccess(
          summary: summary,
          todayMedications: todayMedications,
          selectedPeriod: 'أسبوعي',
          patientName: patientName,
          patientAge: patientAge,
          chartLabels: defaultWeeklyLabels,
          chartData: weeklyData,
          chartHeaderTitle: 'الأسبوع الحالي',
          allDoses: doses,
        ),
      );
    } catch (e) {
      emit(ReportsError('فشل تحميل التقارير: $e'));
    }
  }

  void changePeriod(String period) {
    if (state is! ReportsSuccess) return;
    final currentState = state as ReportsSuccess;

    List<String> labels;
    List<double> data;
    String headerTitle;
    List<MedicationDoseModel> periodDoses;

    final now = DateTime.now();

    switch (period) {
      case 'يومي':
        headerTitle = 'اليوم الحالي';
        labels = ['12-4 ص', '4-8 ص', '8-12 ص', '12-4 م', '4-8 م', '8-12 م'];
        data = _calculateDailyTimeSlotsData(currentState.allDoses);
        periodDoses = currentState.allDoses
            .where(
              (d) =>
                  d.date.year == now.year &&
                  d.date.month == now.month &&
                  d.date.day == now.day,
            )
            .toList();
        break;

      case 'شهري':
        headerTitle = 'الشهر الحالي';
        labels = ['أسبوع 1', 'أسبوع 2', 'أسبوع 3', 'أسبوع 4'];
        data = _calculateMonthlyWeeksData(currentState.allDoses);
        periodDoses = currentState.allDoses
            .where(
                (d) => d.date.year == now.year && d.date.month == now.month)
            .toList();
        break;

      case 'سنوي':
        headerTitle = 'السنة الحالية';
        labels = ['يناير', 'مارس', 'مايو', 'يوليو', 'سبتمبر', 'نوفمبر'];
        data = _calculateYearlyMonthsData(currentState.allDoses);
        periodDoses = currentState.allDoses
            .where((d) => d.date.year == now.year)
            .toList();
        break;

      case 'أسبوعي':
      default:
        headerTitle = 'الأسبوع الحالي';
        labels = [
          'السبت',
          'الأحد',
          'الاثنين',
          'الثلاثاء',
          'الأربعاء',
          'الخميس',
          'الجمعة',
        ];
        data = _calculateWeeklyData(currentState.allDoses);
        final weekStart = now.subtract(const Duration(days: 7));
        periodDoses = currentState.allDoses
            .where(
              (d) =>
                  d.date.isAfter(weekStart) ||
                  d.date.isAtSameMomentAs(weekStart),
            )
            .toList();
        break;
    }

    int taken = periodDoses.where((d) => d.status == DoseStatus.taken).length;
    int missed =
        periodDoses.where((d) => d.status == DoseStatus.missed).length;
    int pending =
        periodDoses.where((d) => d.status == DoseStatus.pending).length;
    int total = periodDoses.length;

    int commitment = total == 0 ? 0 : ((taken / total) * 100).round();

    final updatedSummary = ReportSummaryModel(
      commitmentPercentage: commitment,
      takenCount: taken,
      missedCount: missed,
      pendingCount: pending,
      weeklyData: currentState.summary.weeklyData,
    );

    emit(
      currentState.copyWith(
        summary: updatedSummary,
        selectedPeriod: period,
        chartLabels: labels,
        chartData: data,
        chartHeaderTitle: headerTitle,
      ),
    );
  }

  /// Calculates weekly bar chart data: commitment ratio per day of the week
  /// for the current week (last 7 days).
  List<double> _calculateWeeklyData(List<MedicationDoseModel> doses) {
    final now = DateTime.now();
    final weekStart = now.subtract(const Duration(days: 7));

    final weekDoses = doses.where((d) =>
        d.date.isAfter(weekStart) || d.date.isAtSameMomentAs(weekStart));

    // Saturday=6 in Dart (1=Mon..7=Sun), map to index 0-6 (Sat-Fri)
    List<double> weeklyData = List.filled(7, 0.0);

    for (int i = 0; i < 7; i++) {
      // Map index to Dart weekday: Sat=6, Sun=7, Mon=1, Tue=2, Wed=3, Thu=4, Fri=5
      final dartWeekday = (i + 6) % 7 + 1;
      final dayDoses =
          weekDoses.where((d) => d.date.weekday == dartWeekday).toList();
      if (dayDoses.isNotEmpty) {
        final dayTaken =
            dayDoses.where((d) => d.status == DoseStatus.taken).length;
        weeklyData[i] = dayTaken / dayDoses.length;
      }
    }
    return weeklyData;
  }

  List<double> _calculateDailyTimeSlotsData(List<MedicationDoseModel> doses) {
    final now = DateTime.now();
    final todayDoses = doses
        .where(
          (d) =>
              d.date.year == now.year &&
              d.date.month == now.month &&
              d.date.day == now.day,
        )
        .toList();

    List<double> slotData = List.filled(6, 0.0);
    for (int i = 0; i < 6; i++) {
      final startHour = i * 4;
      final endHour = (i + 1) * 4;
      final slotDoses = todayDoses
          .where((d) => d.time.hour >= startHour && d.time.hour < endHour)
          .toList();

      if (slotDoses.isNotEmpty) {
        final taken =
            slotDoses.where((d) => d.status == DoseStatus.taken).length;
        slotData[i] = taken / slotDoses.length;
      }
    }
    return slotData;
  }

  List<double> _calculateMonthlyWeeksData(List<MedicationDoseModel> doses) {
    final now = DateTime.now();
    final monthDoses = doses
        .where((d) => d.date.year == now.year && d.date.month == now.month)
        .toList();

    List<double> weekData = List.filled(4, 0.0);
    for (int w = 0; w < 4; w++) {
      final startDay = w * 7 + 1;
      final endDay = (w == 3) ? 31 : (w + 1) * 7;
      final wDoses = monthDoses
          .where((d) => d.date.day >= startDay && d.date.day <= endDay)
          .toList();

      if (wDoses.isNotEmpty) {
        final taken =
            wDoses.where((d) => d.status == DoseStatus.taken).length;
        weekData[w] = taken / wDoses.length;
      }
    }
    return weekData;
  }

  List<double> _calculateYearlyMonthsData(List<MedicationDoseModel> doses) {
    final now = DateTime.now();
    final yearDoses = doses.where((d) => d.date.year == now.year).toList();

    List<double> monthData = List.filled(6, 0.0);
    for (int m = 0; m < 6; m++) {
      final mDoses =
          yearDoses.where((d) => (d.date.month - 1) ~/ 2 == m).toList();
      if (mDoses.isNotEmpty) {
        final taken =
            mDoses.where((d) => d.status == DoseStatus.taken).length;
        monthData[m] = taken / mDoses.length;
      }
    }
    return monthData;
  }
}
