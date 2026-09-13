import 'dart:convert';
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository repository = AuthRepository();

  AuthCubit() : super(AuthInitial());

  // Login UI
  bool rememberMe = false;
  bool hidePassword = true;

  // Profile image
  String? profileImageBase64;
  Uint8List? profileImageBytes;

  // تغيير Remember Me
  void changeRememberMe(bool value) {
    rememberMe = value;

    emit(AuthRememberMeChanged());
  }

  // إظهار وإخفاء كلمة المرور
  void changePasswordVisibility() {
    hidePassword = !hidePassword;

    emit(AuthPasswordVisibilityChanged());
  }

  // اختيار صورة من Gallery
  Future<void> pickProfileImage() async {
    final ImagePicker picker = ImagePicker();

    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
      maxWidth: 500,
      maxHeight: 500,
    );

    if (image == null) {
      return;
    }

    final bytes = await image.readAsBytes();

    profileImageBytes = bytes;

    profileImageBase64 = base64Encode(bytes);

    emit(AuthImageSelected(bytes));
  }

  // حذف صورة البروفايل
  void removeProfileImage() {
    profileImageBytes = null;
    profileImageBase64 = null;

    emit(AuthImageRemoved());
  }

  // Login
  Future<void> login({
    required String email,
    required String password,
  }) async {
    emit(AuthLoading());

    try {
      final user = await repository.login(
        email: email,
        password: password,
      );

      emit(AuthSuccess(user));
    } on FirebaseAuthException catch (e) {
      emit(
        AuthError(
          e.message ?? 'حدث خطأ أثناء تسجيل الدخول',
        ),
      );
    } catch (e) {
      emit(
        AuthError(
          e.toString().replaceAll(
                'Exception: ',
                '',
              ),
        ),
      );
    }
  }

  // Signup
  Future<void> signUp({
    required String name,
    required String email,
    required String password,
    required String phone,
    required UserRole role,
    String? patientPhone,
  }) async {
    emit(AuthLoading());

    try {
      final user = await repository.signUp(
        name: name,
        email: email,
        password: password,
        phone: phone,
        role: role,
        patientPhone: patientPhone,
        profileImage: profileImageBase64,
      );

      emit(AuthSuccess(user));
    } on FirebaseAuthException catch (e) {
      emit(
        AuthError(
          e.message ?? 'حدث خطأ أثناء إنشاء الحساب',
        ),
      );
    } catch (e) {
      emit(
        AuthError(
          e.toString().replaceAll(
                'Exception: ',
                '',
              ),
        ),
      );
    }
  }

  // Auto Login
  Future<void> checkCurrentUser() async {
    emit(AuthLoading());

    try {
      final user = await repository.getCurrentUser();

      if (user == null) {
        emit(AuthUnauthenticated());
        return;
      }

      emit(AuthSuccess(user));
    } catch (e) {
      emit(
        AuthError(
          'حدث خطأ أثناء تحميل بيانات المستخدم',
        ),
      );
    }
  }

  // Logout
  Future<void> logout() async {
    emit(AuthLoading());

    try {
      await repository.logout();

      emit(AuthUnauthenticated());
    } catch (e) {
      emit(
        AuthError(
          'حدث خطأ أثناء تسجيل الخروج',
        ),
      );
    }
  }
}