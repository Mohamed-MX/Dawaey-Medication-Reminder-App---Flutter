import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:dawaey/Fetures/Auth/data/local/auth_local_storage.dart';
import 'package:dawaey/Fetures/Auth/data/models/user_model.dart';

class AuthRepository {
  final FirebaseAuth auth = FirebaseAuth.instance;

  final FirebaseFirestore firestore =
      FirebaseFirestore.instance;

  Future<UserModel> signUp({
    required String name,
    required String email,
    required String password,
    required String phone,
    required UserRole role,
    String? patientPhone,
    String? profileImage,
  }) async {
    final credential =
        await auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final firebaseUser = credential.user;

    if (firebaseUser == null) {
      throw Exception(
        'حدث خطأ أثناء إنشاء الحساب',
      );
    }

    String? linkedUserId;

    try {
      if (role == UserRole.patient) {
        final result = await firestore
            .collection('users')
            .where(
              'phone',
              isEqualTo: phone,
            )
            .where(
              'role',
              isEqualTo: 'patient',
            )
            .limit(1)
            .get();

        if (result.docs.isNotEmpty) {
          throw Exception(
            'رقم الهاتف ده مسجل قبل كده',
          );
        }
      }

      if (role == UserRole.caregiver) {
        if (patientPhone == null ||
            patientPhone.trim().isEmpty) {
          throw Exception(
            'اكتب رقم هاتف المريض',
          );
        }

        final result = await firestore
            .collection('users')
            .where(
              'phone',
              isEqualTo: patientPhone.trim(),
            )
            .where(
              'role',
              isEqualTo: 'patient',
            )
            .limit(1)
            .get();

        if (result.docs.isEmpty) {
          throw Exception(
            'لا يوجد مريض بهذا الرقم',
          );
        }

        linkedUserId =
            result.docs.first.id;
      }

      final user = UserModel(
        uid: firebaseUser.uid,
        name: name,
        email: email,
        phone: phone,
        role: role,
        linkedUserId: linkedUserId,
        profileImage: profileImage,
      );

      await firestore
          .collection('users')
          .doc(user.uid)
          .set(
            user.toJson(),
          );

      await AuthLocalStorage.saveUser(
        user,
      );

      return user;
    } catch (e) {
      await firebaseUser.delete();

      rethrow;
    }
  }

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final credential =
        await auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final firebaseUser = credential.user;

    if (firebaseUser == null) {
      throw Exception(
        'حدث خطأ أثناء تسجيل الدخول',
      );
    }

    final document = await firestore
        .collection('users')
        .doc(firebaseUser.uid)
        .get();

    if (!document.exists) {
      throw Exception(
        'بيانات المستخدم غير موجودة',
      );
    }

    final data = document.data();

    if (data == null) {
      throw Exception(
        'بيانات المستخدم غير موجودة',
      );
    }

    final user =
        UserModel.fromJson(
      data,
    );

    await AuthLocalStorage.saveUser(
      user,
    );

    return user;
  }

  Future<UserModel?> getCurrentUser() async {
    final firebaseUser =
        auth.currentUser;

    if (firebaseUser == null) {
      return null;
    }

    final document = await firestore
        .collection('users')
        .doc(firebaseUser.uid)
        .get();

    if (!document.exists) {
      return null;
    }

    final data = document.data();

    if (data == null) {
      return null;
    }

    final user =
        UserModel.fromJson(
      data,
    );

    await AuthLocalStorage.saveUser(
      user,
    );

    return user;
  }

  Future<void> logout() async {
    await auth.signOut();

    await AuthLocalStorage.deleteUser();
  }
}