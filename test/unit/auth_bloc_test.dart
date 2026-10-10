import 'package:flutter_test/flutter_test.dart';
import 'package:the_fresh_yard/domain/entities/customer.dart';
import 'package:the_fresh_yard/data/repositories/customer_repository.dart';
import 'package:the_fresh_yard/data/datasources/secure_storage_service.dart';
import 'package:the_fresh_yard/presentation/bloc/auth/auth_bloc.dart';
import 'package:the_fresh_yard/presentation/bloc/auth/auth_event.dart';
import 'package:the_fresh_yard/presentation/bloc/auth/auth_state.dart';

// In-Memory Fake for ICustomerRepository to isolate unit tests
class FakeCustomerRepository implements ICustomerRepository {
  bool shouldFailLogin = false;
  bool shouldFailRegister = false;
  String? lastRegisteredEmail;
  String fakeToken = 'test_token_xyz_123';

  static const sampleCustomer = Customer(
    id: 'gid://shopify/Customer/12345',
    firstName: 'Omar',
    lastName: 'Ali',
    email: 'omar@example.com',
    phone: '+201000000000',
    defaultAddress: '123 Garden City, Cairo, Egypt',
    orders: [
      CustomerOrder(
        id: 'gid://shopify/Order/999',
        orderNumber: 1001,
        processedAt: '2026-09-01T12:00:00Z',
        financialStatus: 'PAID',
        fulfillmentStatus: 'FULFILLED',
        totalPrice: 450.0,
        currencyCode: 'EGP',
        itemTitles: ['Organic Strawberries', 'Fresh Spinach'],
      ),
    ],
  );

  @override
  Future<String> login(String email, String password) async {
    if (shouldFailLogin || email == 'invalid@test.com') {
      throw Exception('Invalid email or password.');
    }
    return fakeToken;
  }

  @override
  Future<void> register(String firstName, String lastName, String email, String password) async {
    if (shouldFailRegister || email == 'duplicate@test.com') {
      throw Exception('Email has already been taken.');
    }
    lastRegisteredEmail = email;
  }

  @override
  Future<void> recoverPassword(String email) async {
    if (email.isEmpty) throw Exception('Email cannot be empty.');
  }

  @override
  Future<Customer> getCustomerProfile(String accessToken) async {
    if (accessToken != fakeToken) {
      throw Exception('Invalid token');
    }
    return sampleCustomer;
  }

  @override
  Future<String> sendPasswordlessLogin(String email) async {
    if (email == 'error@test.com') {
      throw Exception('Could not sign in with this email.');
    }
    return fakeToken;
  }

  @override
  Future<String> registerPasswordless(String firstName, String lastName, String email) async {
    if (email == 'duplicate@test.com') {
      throw Exception('Email already exists.');
    }
    lastRegisteredEmail = email;
    return fakeToken;
  }

  @override
  Future<String> verifyPasswordlessCode(String email, String code) async {
    if (code == '000000' || code.length < 6) {
      throw Exception('Invalid verification code.');
    }
    return fakeToken;
  }
}


// In-Memory Fake for SecureStorageService to avoid Native KeyStore reliance
class FakeSecureStorageService extends SecureStorageService {
  String? storedToken;
  String? storedEmail;
  String? storedPassword;

  @override
  Future<void> saveCustomerToken(String token) async {
    storedToken = token;
  }

  @override
  Future<String?> getCustomerToken() async {
    return storedToken;
  }

  @override
  Future<void> saveCredentials(String email, String password) async {
    storedEmail = email;
    storedPassword = password;
  }

  @override
  Future<Map<String, String>?> getCredentials() async {
    if (storedEmail != null && storedPassword != null) {
      return {'email': storedEmail!, 'password': storedPassword!};
    }
    return null;
  }

  @override
  Future<void> clearAll() async {
    storedToken = null;
    storedEmail = null;
    storedPassword = null;
  }
}

void main() {
  group('AuthBloc Automated Unit & Regression Tests', () {
    late FakeCustomerRepository fakeRepo;
    late FakeSecureStorageService fakeStorage;
    late AuthBloc authBloc;

    setUp(() {
      fakeRepo = FakeCustomerRepository();
      fakeStorage = FakeSecureStorageService();
      authBloc = AuthBloc(
        customerRepository: fakeRepo,
        secureStorageService: fakeStorage,
      );
    });

    tearDown(() {
      authBloc.close();
    });

    test('Initial state of AuthBloc must be Unauthenticated', () {
      expect(authBloc.state, isA<Unauthenticated>());
    });

    test('Successful login emits AuthLoading then Authenticated and saves token', () async {
      final states = <AuthState>[];
      final subscription = authBloc.stream.listen(states.add);

      authBloc.add(const LoginEvent(email: 'omar@example.com', password: 'secret123'));
      await Future.delayed(const Duration(milliseconds: 100));

      expect(states.length, 2);
      expect(states[0], isA<AuthLoading>());
      expect(states[1], isA<Authenticated>());

      final authenticatedState = states[1] as Authenticated;
      expect(authenticatedState.customer.fullName, 'Omar Ali');
      expect(authenticatedState.accessToken, 'test_token_xyz_123');
      expect(fakeStorage.storedToken, 'test_token_xyz_123');
      expect(fakeStorage.storedEmail, 'omar@example.com');

      await subscription.cancel();
    });

    test('Failed login with invalid credentials emits AuthLoading then AuthError', () async {
      final states = <AuthState>[];
      final subscription = authBloc.stream.listen(states.add);

      authBloc.add(const LoginEvent(email: 'invalid@test.com', password: 'wrongpass'));
      await Future.delayed(const Duration(milliseconds: 100));

      expect(states.length, 2);
      expect(states[0], isA<AuthLoading>());
      expect(states[1], isA<AuthError>());

      final errorState = states[1] as AuthError;
      expect(errorState.message, contains('Invalid email or password'));
      expect(fakeStorage.storedToken, isNull);

      await subscription.cancel();
    });

    test('Successful registration performs auto-login and emits Authenticated', () async {
      final states = <AuthState>[];
      final subscription = authBloc.stream.listen(states.add);

      authBloc.add(const RegisterEvent(
        firstName: 'Farah',
        lastName: 'Mostafa',
        email: 'farah@example.com',
        password: 'securePassword123',
      ));
      await Future.delayed(const Duration(milliseconds: 100));

      expect(states.length, 2);
      expect(states[0], isA<AuthLoading>());
      expect(states[1], isA<Authenticated>());

      final authState = states[1] as Authenticated;
      expect(authState.customer.firstName, 'Omar');
      expect(fakeStorage.storedToken, fakeRepo.fakeToken);
      expect(fakeRepo.lastRegisteredEmail, 'farah@example.com');

      await subscription.cancel();
    });

    test('Registration fallback emits RegisterSuccess if immediate login throws', () async {
      fakeRepo.shouldFailLogin = true;
      final states = <AuthState>[];
      final subscription = authBloc.stream.listen(states.add);

      authBloc.add(const RegisterEvent(
        firstName: 'Farah',
        lastName: 'Mostafa',
        email: 'farah@example.com',
        password: 'securePassword123',
      ));
      await Future.delayed(const Duration(milliseconds: 100));

      expect(states.length, 2);
      expect(states[0], isA<AuthLoading>());
      expect(states[1], isA<RegisterSuccess>());

      final successState = states[1] as RegisterSuccess;
      expect(successState.registeredEmail, 'farah@example.com');

      await subscription.cancel();
    });

    test('Registration with duplicate email emits AuthLoading then AuthError', () async {
      final states = <AuthState>[];
      final subscription = authBloc.stream.listen(states.add);

      authBloc.add(const RegisterEvent(
        firstName: 'Existing',
        lastName: 'User',
        email: 'duplicate@test.com',
        password: 'password',
      ));
      await Future.delayed(const Duration(milliseconds: 100));

      expect(states.length, 2);
      expect(states[0], isA<AuthLoading>());
      expect(states[1], isA<AuthError>());

      final errorState = states[1] as AuthError;
      expect(errorState.message, contains('Email has already been taken'));

      await subscription.cancel();
    });

    test('ForgotPasswordEvent emits AuthLoading then ForgotPasswordSuccess', () async {
      final states = <AuthState>[];
      final subscription = authBloc.stream.listen(states.add);

      authBloc.add(const ForgotPasswordEvent(email: 'omar@example.com'));
      await Future.delayed(const Duration(milliseconds: 100));

      expect(states.length, 2);
      expect(states[0], isA<AuthLoading>());
      expect(states[1], isA<ForgotPasswordSuccess>());

      await subscription.cancel();
    });

    test('LogoutEvent clears stored credentials and resets state to Unauthenticated', () async {
      // First log in
      fakeStorage.storedToken = 'active_token';
      fakeStorage.storedEmail = 'user@example.com';

      authBloc.add(LogoutEvent());
      await Future.delayed(const Duration(milliseconds: 50));

      expect(authBloc.state, isA<Unauthenticated>());
      expect(fakeStorage.storedToken, isNull);
      expect(fakeStorage.storedEmail, isNull);
    });

    test('SendLoginCodeEvent emits AuthLoading then Authenticated via auto-login', () async {
      final states = <AuthState>[];
      final subscription = authBloc.stream.listen(states.add);

      authBloc.add(const SendLoginCodeEvent(email: 'omar@example.com'));
      await Future.delayed(const Duration(milliseconds: 100));

      expect(states.length, 2);
      expect(states[0], isA<AuthLoading>());
      expect(states[1], isA<Authenticated>());

      final authState = states[1] as Authenticated;
      expect(authState.customer.fullName, 'Omar Ali');
      expect(fakeStorage.storedToken, fakeRepo.fakeToken);

      await subscription.cancel();
    });

    test('SendRegisterCodeEvent emits AuthLoading then Authenticated via auto-login', () async {
      final states = <AuthState>[];
      final subscription = authBloc.stream.listen(states.add);

      authBloc.add(const SendRegisterCodeEvent(
        firstName: 'Youssef',
        lastName: 'Ahmed',
        email: 'youssef@example.com',
      ));
      await Future.delayed(const Duration(milliseconds: 100));

      expect(states.length, 2);
      expect(states[0], isA<AuthLoading>());
      expect(states[1], isA<Authenticated>());

      final authState = states[1] as Authenticated;
      expect(authState.customer.fullName, 'Omar Ali');
      expect(fakeStorage.storedToken, fakeRepo.fakeToken);
      expect(fakeRepo.lastRegisteredEmail, 'youssef@example.com');

      await subscription.cancel();
    });

    test('VerifyOtpEvent emits AuthLoading then Authenticated and saves credentials', () async {
      final states = <AuthState>[];
      final subscription = authBloc.stream.listen(states.add);

      authBloc.add(const VerifyOtpEvent(
        email: 'omar@example.com',
        code: '123456',
      ));
      await Future.delayed(const Duration(milliseconds: 100));

      expect(states.length, 2);
      expect(states[0], isA<AuthLoading>());
      expect(states[1], isA<Authenticated>());

      final authState = states[1] as Authenticated;
      expect(authState.customer.fullName, 'Omar Ali');
      expect(fakeStorage.storedToken, fakeRepo.fakeToken);

      await subscription.cancel();
    });

    test('VerifyOtpEvent with invalid code emits AuthLoading then AuthError', () async {
      final states = <AuthState>[];
      final subscription = authBloc.stream.listen(states.add);

      authBloc.add(const VerifyOtpEvent(
        email: 'omar@example.com',
        code: '000000',
      ));
      await Future.delayed(const Duration(milliseconds: 100));

      expect(states.length, 2);
      expect(states[0], isA<AuthLoading>());
      expect(states[1], isA<AuthError>());

      final errState = states[1] as AuthError;
      expect(errState.message, contains('Invalid verification code'));

      await subscription.cancel();
    });

    test('ResendOtpEvent emits AuthLoading then Authenticated', () async {
      final states = <AuthState>[];
      final subscription = authBloc.stream.listen(states.add);

      authBloc.add(const ResendOtpEvent(email: 'omar@example.com'));
      await Future.delayed(const Duration(milliseconds: 100));

      expect(states.length, 2);
      expect(states[0], isA<AuthLoading>());
      expect(states[1], isA<Authenticated>());

      final authState = states[1] as Authenticated;
      expect(authState.customer.fullName, 'Omar Ali');

      await subscription.cancel();
    });
  });
}

