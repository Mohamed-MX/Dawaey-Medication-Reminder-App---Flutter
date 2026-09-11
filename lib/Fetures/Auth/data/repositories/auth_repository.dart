import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_model.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserModel> signUp({
    required String name,
    required String email,
    required String password,
    required String phone,
    required UserRole role,
    String? patientPhone,
  }) async {
    if (role == UserRole.patient) {
      final existingPatient = await _firestore
          .collection('users')
          .where('phone', isEqualTo: phone)
          .where('role', isEqualTo: 'patient')
          .limit(1)
          .get();

      if (existingPatient.docs.isNotEmpty) {
        throw Exception(
          'رقم الهاتف ده مسجل بحساب مريض قبل كده',
        );
      }
    }

    String? linkedUserId;

    if (role == UserRole.caregiver) {
      final query = await _firestore
          .collection('users')
          .where('phone', isEqualTo: patientPhone)
          .where('role', isEqualTo: 'patient')
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        throw Exception(
          'لا يوجد مريض مسجل بهذا الرقم',
        );
      }

      linkedUserId = query.docs.first.id;
    }

    final credential =
        await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final newUser = UserModel(
      uid: credential.user!.uid,
      name: name,
      email: email,
      phone: phone,
      role: role,
      linkedUserId: linkedUserId,
    );

    await _firestore
        .collection('users')
        .doc(newUser.uid)
        .set(
          newUser.toJson(),
        );

    return newUser;
  }

  Future<UserModel> login(
    String email,
    String password,
  ) async {
    final credential =
        await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final doc = await _firestore
        .collection('users')
        .doc(credential.user!.uid)
        .get();

    if (!doc.exists) {
      throw Exception(
        'بيانات المستخدم غير موجودة',
      );
    }

    return UserModel.fromJson(
      doc.data()!,
    );
  }

  Future<UserModel?> getCurrentUser() async {
    final firebaseUser = _auth.currentUser;

    if (firebaseUser == null) {
      return null;
    }

    final doc = await _firestore
        .collection('users')
        .doc(firebaseUser.uid)
        .get();

    if (!doc.exists) {
      return null;
    }

    return UserModel.fromJson(
      doc.data()!,
    );
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}