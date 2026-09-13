import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum DoseStatus {
  pending,
  taken,
  missed,
}

class MedicationDoseModel {
  final String id ; 
  final String medicationId;
  final DateTime date;
  final TimeOfDay time;
  final DoseStatus status;

  MedicationDoseModel({
    required this.id,
    required this.medicationId,
    required this.date,
    required this.time,
    required this.status,
  });

    Map<String, dynamic> toMap() {
    return {
      'id': id,
      'medicationId': medicationId,
      'date': Timestamp.fromDate(date),
      'time': {
        'hour': time.hour,
        'minute': time.minute,
      },
      'status': status.name,
    };
  }

  factory MedicationDoseModel.fromMap(Map<String, dynamic> map) {
    final time = map['time'] as Map<String, dynamic>;

    return MedicationDoseModel(
      id: map['id'] as String,
      medicationId: map['medicationId'] as String,
      date: (map['date'] as Timestamp).toDate(),
      time: TimeOfDay(
        hour: time['hour'] as int,
        minute: time['minute'] as int,
      ),
      status: DoseStatus.values.byName(map['status'] as String),
    );
  }
}