import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

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

class MedicationDoseModelAdapter extends TypeAdapter<MedicationDoseModel> {
  @override
  final int typeId = 1;

  @override
  MedicationDoseModel read(BinaryReader reader) {
    return MedicationDoseModel(
      id: reader.readString(),
      medicationId: reader.readString(),
      date: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
      time: reader.read() as TimeOfDay,
      status: DoseStatus.values.byName(reader.readString()),
    );
  }

  @override
  void write(BinaryWriter writer, MedicationDoseModel obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.medicationId);
    writer.writeInt(obj.date.millisecondsSinceEpoch);
    writer.write(obj.time);
    writer.writeString(obj.status.name);
  }
}