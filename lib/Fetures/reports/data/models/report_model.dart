class ReportSummaryModel {
  final int commitmentPercentage;
  final int takenCount;
  final int missedCount;
  final int pendingCount;
  final List<double> weeklyData;

  ReportSummaryModel({
    required this.commitmentPercentage,
    required this.takenCount,
    required this.missedCount,
    required this.pendingCount,
    required this.weeklyData,
  });

  factory ReportSummaryModel.fromMap(Map<String, dynamic> map) {
    return ReportSummaryModel(
      commitmentPercentage: (map['commitmentPercentage'] as num).toInt(),
      takenCount: (map['takenCount'] as num).toInt(),
      missedCount: (map['missedCount'] as num).toInt(),
      pendingCount: (map['pendingCount'] as num).toInt(),
      weeklyData: (map['weeklyData'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'commitmentPercentage': commitmentPercentage,
      'takenCount': takenCount,
      'missedCount': missedCount,
      'pendingCount': pendingCount,
      'weeklyData': weeklyData,
    };
  }
}

class TodayMedicationReport {
  final String id;
  final String name;
  final String dosage;
  final String time;
  final String status; // 'taken', 'missed', 'pending'

  TodayMedicationReport({
    required this.id,
    required this.name,
    required this.dosage,
    required this.time,
    required this.status,
  });

  factory TodayMedicationReport.fromMap(Map<String, dynamic> map, String docId) {
    return TodayMedicationReport(
      id: docId,
      name: map['name'] ?? '',
      dosage: map['dosage'] ?? '',
      time: map['time'] ?? '',
      status: map['status'] ?? 'pending',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'dosage': dosage,
      'time': time,
      'status': status,
    };
  }
}
