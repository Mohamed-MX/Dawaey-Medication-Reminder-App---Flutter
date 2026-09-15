import 'package:dawaey/Fetures/history/data/model/history_data_model.dart';
import 'package:dawaey/Fetures/medications/data/model/medication_model.dart';

abstract class HistoryState {}
 class HistoryIntialState extends HistoryState{}
 class HistoryLoadingState extends HistoryState{}
 class HistorySuccessState extends HistoryState{
  final List<HistoryDataModel> thisDateMediciens ;
  HistorySuccessState({required this.thisDateMediciens});
}
 class HistoryFailState extends HistoryState {
  String msg ;
  HistoryFailState({required this.msg});
}