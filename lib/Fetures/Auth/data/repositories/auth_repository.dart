import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../local/auth_local_storage.dart';
import '../models/user_model.dart';

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
  }) async {
    String? linkedUserId;

    // لو المستخدم Patient
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
          .get();

      if (result.docs.isNotEmpty) {
        throw Exception(
          'رقم الهاتف ده مسجل قبل كده',
        );
      }
    }

    // لو المستخدم Caregiver
    if (role == UserRole.caregiver) {
      if (patientPhone == null ||
          patientPhone.isEmpty) {
        throw Exception(
          'اكتب رقم هاتف المريض',
        );
      }

      final result = await firestore
          .collection('users')
          .where(
            'phone',
            isEqualTo: patientPhone,
          )
          .where(
            'role',
            isEqualTo: 'patient',
          )
          .get();

      if (result.docs.isEmpty) {
        throw Exception(
          'لا يوجد مريض بهذا الرقم',
        );
      }

      linkedUserId = result.docs.first.id;
    }

    // إنشاء الحساب على Firebase Authentication
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

    // إنشاء UserModel
    final user = UserModel(
      uid: firebaseUser.uid,
      name: name,
      email: email,
      phone: phone,
      role: role,
      linkedUserId: linkedUserId,
    );

    // حفظ بيانات المستخدم على Firestore
    await firestore
        .collection('users')
        .doc(user.uid)
        .set(
          user.toJson(),
        );

    // حفظ نسخة Local في Hive
    await AuthLocalStorage.saveUser(user);

    return user;
  }

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    // تسجيل الدخول باستخدام Firebase Authentication
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

    // هات بيانات المستخدم من Firestore
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

    // حول البيانات إلى UserModel
    final user = UserModel.fromJson(data);

    // احفظ نسخة Local
    await AuthLocalStorage.saveUser(user);

    return user;
  }

  Future<UserModel?> getCurrentUser() async {
    // هل Firebase عنده User مسجل دخول؟
    final firebaseUser = auth.currentUser;

    if (firebaseUser == null) {
      return null;
    }

    // جرب الأول تجيب المستخدم من Hive
    final localUser = AuthLocalStorage.getUser();

    if (localUser != null &&
        localUser.uid == firebaseUser.uid) {
      return localUser;
    }

    // لو مش موجود Local هاته من Firestore
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

    final user = UserModel.fromJson(data);

    // احفظه Local للمرة الجاية
    await AuthLocalStorage.saveUser(user);

    return user;
  }

  Future<void> logout() async {
    // Logout من Firebase
    await auth.signOut();

    // امسح المستخدم من Hive
    await AuthLocalStorage.deleteUser();
  }
}