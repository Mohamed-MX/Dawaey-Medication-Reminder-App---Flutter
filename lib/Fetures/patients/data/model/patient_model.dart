import 'package:hive/hive.dart';

class PatientModel {
  String id;
  String name;
  String relationship;

  PatientModel({
    required this.id,
    required this.name,
    required this.relationship,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'relationship': relationship,
    };
  }

  factory PatientModel.fromMap(Map<String, dynamic> map) {
    return PatientModel(
      id: map['id'] as String,
      name: map['name'] as String,
      relationship: map['relationship'] as String,
    );
  }
}

class PatientModelAdapter extends TypeAdapter<PatientModel> {
  @override
  final int typeId = 3; 

  @override
  PatientModel read(BinaryReader reader) {
    return PatientModel(
      id: reader.readString(),
      name: reader.readString(),
      relationship: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, PatientModel obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.name);
    writer.writeString(obj.relationship);
  }
}
