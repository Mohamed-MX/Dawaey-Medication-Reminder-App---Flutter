import 'dart:convert';
import 'dart:typed_data';

import 'package:dawaey/Fetures/Auth/data/models/user_model.dart';
import 'package:dawaey/Fetures/Auth/data/repositories/auth_repository.dart';
import 'package:dawaey/Fetures/Auth/presentation/view_model/auth_state.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());

  final AuthRepository repository = AuthRepository();

  bool rememberMe = false;

  bool hidePassword = true;

  Uint8List? profileImageBytes;

  String? profileImageBase64;

  void changeRememberMe(bool value) {
    rememberMe = value;

    emit(
      AuthRememberMeChanged(),
    );
  }

  void changePasswordVisibility() {
    hidePassword = !hidePassword;

    emit(
      AuthPasswordVisibilityChanged(),
    );
  }

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

    final Uint8List bytes =
        await image.readAsBytes();

    profileImageBytes = bytes;

    profileImageBase64 =
        base64Encode(bytes);

    emit(
      AuthImageSelected(
        bytes,
      ),
    );
  }

  void removeProfileImage() {
    profileImageBytes = null;

    profileImageBase64 = null;

    emit(
      AuthImageRemoved(),
    );
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    emit(
      AuthLoading(),
    );

    try {
      final user =
          await repository.login(
        email: email,
        password: password,
      );

      emit(
        AuthSuccess(
          user,
        ),
      );
    } on FirebaseAuthException catch (e) {
      emit(
        AuthError(
          e.message ??
              'حدث خطأ أثناء تسجيل الدخول',
        ),
      );
    } catch (e) {
      emit(
        AuthError(
          e
              .toString()
              .replaceAll(
                'Exception: ',
                '',
              ),
        ),
      );
    }
  }

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
    required String phone,
    required UserRole role,
    String? patientPhone,
  }) async {
    emit(
      AuthLoading(),
    );

    try {
      final user =
          await repository.signUp(
        name: name,
        email: email,
        password: password,
        phone: phone,
        role: role,
        patientPhone: patientPhone,
        profileImage:
            profileImageBase64,
      );

      emit(
        AuthSuccess(
          user,
        ),
      );
    } on FirebaseAuthException catch (e) {
      emit(
        AuthError(
          e.message ??
              'حدث خطأ أثناء إنشاء الحساب',
        ),
      );
    } catch (e) {
      emit(
        AuthError(
          e
              .toString()
              .replaceAll(
                'Exception: ',
                '',
              ),
        ),
      );
    }
  }

  Future<void> checkCurrentUser() async {
    emit(
      AuthLoading(),
    );

    try {
      final user =
          await repository.getCurrentUser();

      if (user != null) {
        emit(
          AuthSuccess(
            user,
          ),
        );
      } else {
        emit(
          AuthUnauthenticated(),
        );
      }
    } catch (e) {
      emit(
        AuthUnauthenticated(),
      );
    }
  }

  Future<void> logout() async {
    try {
      await repository.logout();

      emit(
        AuthUnauthenticated(),
      );
    } catch (e) {
      emit(
        AuthError(
          e
              .toString()
              .replaceAll(
                'Exception: ',
                '',
              ),
        ),
      );
    }
  }
}