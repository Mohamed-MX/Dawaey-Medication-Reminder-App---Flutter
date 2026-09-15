import 'dart:typed_data';

import 'package:dawaey/Fetures/Auth/data/models/user_model.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final UserModel user;

  AuthSuccess(
    this.user,
  );
}

class AuthUnauthenticated extends AuthState {}

class AuthRememberMeChanged extends AuthState {}

class AuthPasswordVisibilityChanged
    extends AuthState {}

class AuthImageSelected extends AuthState {
  final Uint8List imageBytes;

  AuthImageSelected(
    this.imageBytes,
  );
}

class AuthImageRemoved extends AuthState {}

class AuthError extends AuthState {
  final String message;

  AuthError(
    this.message,
  );
}