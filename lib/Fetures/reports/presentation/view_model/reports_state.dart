import '../../../medications/data/model/doise_model.dart';
import '../../data/models/report_model.dart';

abstract class ReportsState {}

class ReportsInitial extends ReportsState {}

class ReportsLoading extends ReportsState {}

class ReportsSuccess extends ReportsState {
  final ReportSummaryModel summary;
  final List<TodayMedicationReport> todayMedications;
  final String selectedPeriod;
  final String patientName;
  final int? patientAge;
  final List<String> chartLabels;
  final List<double> chartData;
  final String chartHeaderTitle;
  final List<MedicationDoseModel> allDoses;

  ReportsSuccess({
    required this.summary,
    required this.todayMedications,
    this.selectedPeriod = 'أسبوعي',
    this.patientName = 'مستخدم',
    this.patientAge,
    required this.chartLabels,
    required this.chartData,
    this.chartHeaderTitle = 'الأسبوع الحالي',
    this.allDoses = const [],
  });

  ReportsSuccess copyWith({
    ReportSummaryModel? summary,
    List<TodayMedicationReport>? todayMedications,
    String? selectedPeriod,
    String? patientName,
    int? patientAge,
    List<String>? chartLabels,
    List<double>? chartData,
    String? chartHeaderTitle,
    List<MedicationDoseModel>? allDoses,
  }) {
    return ReportsSuccess(
      summary: summary ?? this.summary,
      todayMedications: todayMedications ?? this.todayMedications,
      selectedPeriod: selectedPeriod ?? this.selectedPeriod,
      patientName: patientName ?? this.patientName,
      patientAge: patientAge ?? this.patientAge,
      chartLabels: chartLabels ?? this.chartLabels,
      chartData: chartData ?? this.chartData,
      chartHeaderTitle: chartHeaderTitle ?? this.chartHeaderTitle,
      allDoses: allDoses ?? this.allDoses,
    );
  }
}

class ReportsError extends ReportsState {
  final String message;
  ReportsError(this.message);
}
