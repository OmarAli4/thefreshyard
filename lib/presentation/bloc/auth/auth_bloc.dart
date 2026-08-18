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
    on<LoginEvent>(_onLogin);
    on<RegisterEvent>(_onRegister);
    on<LogoutEvent>(_onLogout);
    on<FetchCustomerProfileEvent>(_onFetchProfile);
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
      emit(const RegisterSuccess('Account created successfully! Please sign in.'));
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
