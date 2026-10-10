import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/datasources/secure_storage_service.dart';
import '../../../data/repositories/customer_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final ICustomerRepository customerRepository;
  final SecureStorageService secureStorageService;
  String? _savedAccessToken;

  AuthBloc({
    required this.customerRepository,
    SecureStorageService? secureStorageService,
  })  : secureStorageService = secureStorageService ?? SecureStorageService(),
        super(Unauthenticated()) {
    on<SendLoginCodeEvent>(_onSendLoginCode);
    on<SendRegisterCodeEvent>(_onSendRegisterCode);
    on<VerifyOtpEvent>(_onVerifyOtp);
    on<ResendOtpEvent>(_onResendOtp);
    on<LoginEvent>(_onLogin);
    on<RegisterEvent>(_onRegister);
    on<ForgotPasswordEvent>(_onForgotPassword);
    on<LogoutEvent>(_onLogout);
    on<FetchCustomerProfileEvent>(_onFetchProfile);
  }

  Future<void> _onSendLoginCode(SendLoginCodeEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final token = await customerRepository.sendPasswordlessLogin(event.email);
      _savedAccessToken = token;
      await secureStorageService.saveCustomerToken(token);
      await secureStorageService.saveCredentials(event.email.trim(), 'passwordless_session');
      final profile = await customerRepository.getCustomerProfile(token);
      emit(Authenticated(profile, accessToken: token));
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onSendRegisterCode(SendRegisterCodeEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final token = await customerRepository.registerPasswordless(
        event.firstName,
        event.lastName,
        event.email,
      );
      _savedAccessToken = token;
      await secureStorageService.saveCustomerToken(token);
      await secureStorageService.saveCredentials(event.email.trim(), 'passwordless_session');
      final profile = await customerRepository.getCustomerProfile(token);
      emit(Authenticated(profile, accessToken: token));
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onVerifyOtp(VerifyOtpEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final token = await customerRepository.verifyPasswordlessCode(event.email, event.code);
      _savedAccessToken = token;
      await secureStorageService.saveCustomerToken(token);
      await secureStorageService.saveCredentials(event.email, 'passwordless_session');
      final profile = await customerRepository.getCustomerProfile(token);
      emit(Authenticated(profile, accessToken: token));
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onResendOtp(ResendOtpEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final token = await customerRepository.sendPasswordlessLogin(event.email);
      _savedAccessToken = token;
      await secureStorageService.saveCustomerToken(token);
      await secureStorageService.saveCredentials(event.email.trim(), 'passwordless_session');
      final profile = await customerRepository.getCustomerProfile(token);
      emit(Authenticated(profile, accessToken: token));
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    }
  }


  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final token = await customerRepository.login(event.email, event.password);
      _savedAccessToken = token;
      await secureStorageService.saveCustomerToken(token);
      await secureStorageService.saveCredentials(event.email, event.password);
      final profile = await customerRepository.getCustomerProfile(token);
      emit(Authenticated(profile, accessToken: token));
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onRegister(RegisterEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await customerRepository.register(
        event.firstName,
        event.lastName,
        event.email,
        event.password,
      );

      // Seamless auto-login right after registration
      try {
        final token = await customerRepository.login(event.email, event.password);
        _savedAccessToken = token;
        await secureStorageService.saveCustomerToken(token);
        await secureStorageService.saveCredentials(event.email, event.password);
        final profile = await customerRepository.getCustomerProfile(token);
        emit(Authenticated(profile, accessToken: token));
      } catch (_) {
        // Fallback if store requires email activation link
        emit(RegisterSuccess(
          'Account created successfully! Please sign in.',
          registeredEmail: event.email,
        ));
      }
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onForgotPassword(ForgotPasswordEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await customerRepository.recoverPassword(event.email);
      emit(const ForgotPasswordSuccess(
        'Password reset link has been sent to your email. Please check your inbox.',
      ));
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onFetchProfile(FetchCustomerProfileEvent event, Emitter<AuthState> emit) async {
    _savedAccessToken ??= await secureStorageService.getCustomerToken();
    if (_savedAccessToken == null) {
      emit(Unauthenticated());
      return;
    }
    emit(AuthLoading());
    try {
      final profile = await customerRepository.getCustomerProfile(_savedAccessToken!);
      emit(Authenticated(profile, accessToken: _savedAccessToken));
    } catch (e) {
      emit(Unauthenticated());
    }
  }

  void _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    _savedAccessToken = null;
    await secureStorageService.clearAll();
    emit(Unauthenticated());
  }
}
