import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Initiates passwordless login by dispatching a verification code & magic link to customer's email
class SendLoginCodeEvent extends AuthEvent {
  final String email;

  const SendLoginCodeEvent({required this.email});

  @override
  List<Object?> get props => [email];
}

/// Registers a new customer without requiring a password and dispatches verification
class SendRegisterCodeEvent extends AuthEvent {
  final String firstName;
  final String lastName;
  final String email;

  const SendRegisterCodeEvent({
    required this.firstName,
    required this.lastName,
    required this.email,
  });

  @override
  List<Object?> get props => [firstName, lastName, email];
}

/// Verifies 6-digit OTP code or session token and logs the customer in
class VerifyOtpEvent extends AuthEvent {
  final String email;
  final String code;

  const VerifyOtpEvent({
    required this.email,
    required this.code,
  });

  @override
  List<Object?> get props => [email, code];
}

/// Requests a new OTP code to be resent
class ResendOtpEvent extends AuthEvent {
  final String email;

  const ResendOtpEvent({required this.email});

  @override
  List<Object?> get props => [email];
}

class LoginEvent extends AuthEvent {
  final String email;
  final String password;

  const LoginEvent({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class RegisterEvent extends AuthEvent {
  final String firstName;
  final String lastName;
  final String email;
  final String password;

  const RegisterEvent({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [firstName, lastName, email, password];
}

class ForgotPasswordEvent extends AuthEvent {
  final String email;

  const ForgotPasswordEvent({required this.email});

  @override
  List<Object?> get props => [email];
}

class LogoutEvent extends AuthEvent {}

class FetchCustomerProfileEvent extends AuthEvent {}

