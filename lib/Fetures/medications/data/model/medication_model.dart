import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

enum MedicationFrequency { onceDaily, twiceDaily, threeTimesDaily, fourTimesDaily, onceWeekly }

enum MedicationStatus { active, stopped }

class MedicationModel {
  String id;
  String patientId;
  String medicationName;
  String administrationRoute;
  String dosage;
  MedicationFrequency frequency;
  List<TimeOfDay> intakeTimes;
  DateTime startDate;
  DateTime endDate;
  int remainingDoses;
  int remainingMedicationAmount;
  String notes;
  MedicationStatus status;

  MedicationModel({
    required this.id,
    required this.patientId,
    required this.medicationName,
    required this.administrationRoute,
    required this.dosage,
    required this.frequency,
    required this.intakeTimes,
    required this.startDate,
    required this.endDate,
    required this.remainingDoses,
    required this.remainingMedicationAmount,
    required this.notes,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patientId': patientId,
      'medicationName': medicationName,
      'administrationRoute': administrationRoute,
      'dosage': dosage,
      'frequency': frequency.name,
      'intakeTimes': intakeTimes.map((time) {
        return {'hour': time.hour, 'minute': time.minute};
      }).toList(),
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'remainingDoses': remainingDoses,
      'remainingMedicationAmount': remainingMedicationAmount,
      'notes': notes,
      'status': status.name,
    };
  }

  factory MedicationModel.fromMap(Map<String, dynamic> map) {
    return MedicationModel(
      id: map['id'] as String,
      patientId: map['patientId'] as String,
      medicationName: map['medicationName'] as String,
      administrationRoute: map['administrationRoute'] as String,
      dosage: map['dosage'] as String,
      frequency: MedicationFrequency.values.byName(map['frequency']),
      intakeTimes: (map['intakeTimes'] as List).map((time) {
        return TimeOfDay(
          hour: time['hour'] as int,
          minute: time['minute'] as int,
        );
      }).toList(),
      startDate: (map['startDate'] as Timestamp).toDate(),
      endDate: (map['endDate'] as Timestamp).toDate(),
      remainingDoses: map['remainingDoses'] as int,
      remainingMedicationAmount: map['remainingMedicationAmount'] as int,
      notes: map['notes'] as String,
      status: MedicationStatus.values.byName(map['status']),
    );
  }
}

class MedicationModelAdapter extends TypeAdapter<MedicationModel> {
  @override
  final int typeId = 0;

  @override
  MedicationModel read(BinaryReader reader) {
    return MedicationModel(
      id: reader.readString(),
      patientId: reader.readString(),
      medicationName: reader.readString(),
      administrationRoute: reader.readString(),
      dosage: reader.readString(),
      frequency: MedicationFrequency.values.byName(reader.readString()),
      intakeTimes: reader.readList().map((e) => e as TimeOfDay).toList(),
      startDate: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
      endDate: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
      remainingDoses: reader.readInt(),
      remainingMedicationAmount: reader.readInt(),
      notes: reader.readString(),
      status: MedicationStatus.values.byName(reader.readString()),
    );
  }

  @override
  void write(BinaryWriter writer, MedicationModel obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.patientId);
    writer.writeString(obj.medicationName);
    writer.writeString(obj.administrationRoute);
    writer.writeString(obj.dosage);
    writer.writeString(obj.frequency.name);
    writer.writeList(obj.intakeTimes);
    writer.writeInt(obj.startDate.millisecondsSinceEpoch);
    writer.writeInt(obj.endDate.millisecondsSinceEpoch);
    writer.writeInt(obj.remainingDoses);
    writer.writeInt(obj.remainingMedicationAmount);
    writer.writeString(obj.notes);
    writer.writeString(obj.status.name);
  }
}
