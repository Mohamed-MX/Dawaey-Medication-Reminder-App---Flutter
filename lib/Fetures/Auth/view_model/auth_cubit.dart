import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/models/user_model.dart';
import '../data/repositories/auth_repository.dart';
import 'auth_state.dart';

class AuthViewModel extends Cubit<AuthState> {
  final AuthRepository repository = AuthRepository();

  AuthViewModel() : super(AuthInitial());

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
          e.toString().replaceAll('Exception: ', ''),
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
    emit(AuthLoading());

    try {
      final user = await repository.signUp(
        name: name,
        email: email,
        password: password,
        phone: phone,
        role: role,
        patientPhone: patientPhone,
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
          e.toString().replaceAll('Exception: ', ''),
        ),
      );
    }
  }

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