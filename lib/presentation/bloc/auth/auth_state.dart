import 'package:equatable/equatable.dart';
import '../../../domain/entities/customer.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class Authenticated extends AuthState {
  final Customer customer;
  final String? accessToken;

  const Authenticated(this.customer, {this.accessToken});

  @override
  List<Object?> get props => [customer, accessToken];
}

/// Emitted when a 6-digit login/verification code has been sent to customer's email
class OtpSentState extends AuthState {
  final String email;
  final bool isNewUser;
  final String? message;

  const OtpSentState({
    required this.email,
    required this.isNewUser,
    this.message,
  });

  @override
  List<Object?> get props => [email, isNewUser, message];
}

class Unauthenticated extends AuthState {}


class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

class RegisterSuccess extends AuthState {
  final String message;
  final String? registeredEmail;

  const RegisterSuccess(this.message, {this.registeredEmail});

  @override
  List<Object?> get props => [message, registeredEmail];
}

class ForgotPasswordSuccess extends AuthState {
  final String message;

  const ForgotPasswordSuccess(this.message);

  @override
  List<Object?> get props => [message];
}
