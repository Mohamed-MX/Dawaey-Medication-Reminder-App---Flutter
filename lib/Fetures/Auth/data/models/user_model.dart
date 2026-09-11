enum UserRole {
  patient,
  caregiver,
}

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final UserRole role;
  final String? linkedUserId;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.linkedUserId,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      role: json['role'] == 'patient'
          ? UserRole.patient
          : UserRole.caregiver,
      linkedUserId: json['linkedUserId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role == UserRole.patient
          ? 'patient'
          : 'caregiver',
      'linkedUserId': linkedUserId,
    };
  }
}