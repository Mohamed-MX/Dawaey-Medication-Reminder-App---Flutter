import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dawaey/Fetures/Auth/data/models/user_model.dart';
import 'package:dawaey/Fetures/history/data/model/history_data_model.dart';
import 'package:dawaey/Fetures/history/presentation/view_model/history_state.dart';
import 'package:dawaey/Fetures/medications/data/model/doise_model.dart';
import 'package:dawaey/Fetures/medications/data/model/medication_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HistoryCubit extends Cubit<HistoryState> {
  HistoryCubit() : super(HistoryIntialState());
  final urFirestore = FirebaseFirestore.instance;
  DateTime requiredMonth = DateTime(DateTime.now().year, DateTime.now().month);

  DateTime selected = DateTime.now();

  void nextMonth(UserModel currentUser) {
    requiredMonth = DateTime(requiredMonth.year, requiredMonth.month + 1);

    selected = requiredMonth;

    getRelativeMediciensWithDate(selected, currentUser);
  }

  void previousMonth(UserModel currentUser) {
    requiredMonth = DateTime(requiredMonth.year, requiredMonth.month - 1);

    selected = requiredMonth;

    getRelativeMediciensWithDate(selected, currentUser);
  }

  void selectDate(DateTime date, UserModel currentUser) {
    selected = date;

    getRelativeMediciensWithDate(date, currentUser);
  }

  Future<void> getRelativeMediciensWithDate(
    DateTime date,
    UserModel currentUser,
  ) async {
    emit(HistoryLoadingState());
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));
      
      final dosesSnapshot = await urFirestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('doses')
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('date', isLessThan: Timestamp.fromDate(endOfDay))
          .get();

      final doses = dosesSnapshot.docs
          .map((doc) => MedicationDoseModel.fromMap(doc.data()))
          .toList();
      final medicationIds = doses
          .map((dose) => dose.medicationId)
          .toSet()
          .toList();

      if (medicationIds.isEmpty) {
        emit(HistorySuccessState(thisDateMediciens: []));
        return;
      }

      final medicationsSnapshot = await urFirestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('medications')
          .where(FieldPath.documentId, whereIn: medicationIds)
          .get();

      final medications = medicationsSnapshot.docs
          .map((doc) => MedicationModel.fromMap(doc.data()))
          .toList();

      final historyData = doses.map((dose) {
        final medication = medications.firstWhere(
          (medication) => medication.id == dose.medicationId,
        );

        return HistoryDataModel(medication: medication, dose: dose);
      }).toList();
      emit(HistorySuccessState(thisDateMediciens: historyData));
    } catch (e) {
      emit(HistoryFailState(msg: e.toString()));
    }
  }
}
