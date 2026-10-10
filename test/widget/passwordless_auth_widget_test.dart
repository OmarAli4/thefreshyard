import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:the_fresh_yard/domain/entities/customer.dart';
import 'package:the_fresh_yard/data/repositories/customer_repository.dart';
import 'package:the_fresh_yard/presentation/bloc/auth/auth_bloc.dart';

import 'package:the_fresh_yard/presentation/widgets/auth_login_form.dart';
import 'package:the_fresh_yard/presentation/widgets/auth_register_form.dart';
import 'package:the_fresh_yard/presentation/widgets/otp_verification_form.dart';

class MockCustomerRepository implements ICustomerRepository {
  String? sentLoginEmail;
  String? registeredEmail;
  String? verifiedCode;

  @override
  Future<String> login(String email, String password) async => 'dummy_token';

  @override
  Future<void> register(String firstName, String lastName, String email, String password) async {}

  @override
  Future<void> recoverPassword(String email) async {}

  @override
  Future<Customer> getCustomerProfile(String accessToken) async {
    return const Customer(
      id: '1',
      firstName: 'Omar',
      lastName: 'Ali',
      email: 'omar@example.com',
      orders: [],
    );
  }

  @override
  Future<String> sendPasswordlessLogin(String email) async {
    sentLoginEmail = email;
    return 'token_login_123';
  }

  @override
  Future<String> registerPasswordless(String firstName, String lastName, String email) async {
    registeredEmail = email;
    return 'token_register_123';
  }

  @override
  Future<String> verifyPasswordlessCode(String email, String code) async {
    verifiedCode = code;
    return 'token_verified_123';
  }
}

void main() {
  group('Passwordless Authentication UI Widget Tests', () {
    late MockCustomerRepository mockRepo;
    late AuthBloc authBloc;

    setUp(() {
      mockRepo = MockCustomerRepository();
      authBloc = AuthBloc(customerRepository: mockRepo);
    });

    tearDown(() {
      authBloc.close();
    });

    testWidgets('AuthLoginForm has NO password fields and submits SendLoginCodeEvent', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider<AuthBloc>.value(
              value: authBloc,
              child: const AuthLoginForm(),
            ),
          ),
        ),
      );

      // Verify NO password text fields exist
      expect(find.text('Password'), findsNothing);
      expect(find.text('Confirm Password'), findsNothing);
      expect(find.byIcon(Icons.lock_outline), findsNothing);

      // Verify simplified login elements exist
      expect(find.text('Email Address'), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);

      // Enter valid email and tap Sign In
      await tester.enterText(find.byType(TextField), 'user@thefreshyard.shop');
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      expect(mockRepo.sentLoginEmail, 'user@thefreshyard.shop');
    });


    testWidgets('AuthRegisterForm has NO password fields and submits SendRegisterCodeEvent', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider<AuthBloc>.value(
              value: authBloc,
              child: const SingleChildScrollView(child: AuthRegisterForm()),
            ),
          ),
        ),
      );

      // Verify NO password text fields exist
      expect(find.text('Password'), findsNothing);
      expect(find.text('Confirm Password *'), findsNothing);

      // Verify first name, last name, email exist
      expect(find.text('First Name *'), findsOneWidget);
      expect(find.text('Last Name (Optional)'), findsOneWidget);
      expect(find.text('Email Address *'), findsOneWidget);

      final textFields = find.byType(TextField);
      expect(textFields, findsNWidgets(3));

      // Fill registration fields
      await tester.enterText(textFields.at(0), 'Layla');
      await tester.enterText(textFields.at(1), 'Hassan');
      await tester.enterText(textFields.at(2), 'layla@thefreshyard.shop');

      await tester.tap(find.text('Create Account'));
      await tester.pumpAndSettle();

      expect(mockRepo.registeredEmail, 'layla@thefreshyard.shop');
    });

    testWidgets('OtpVerificationForm displays email and submits VerifyOtpEvent', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider<AuthBloc>.value(
              value: authBloc,
              child: const SingleChildScrollView(
                child: OtpVerificationForm(
                  email: 'tester@thefreshyard.shop',
                  isNewUser: false,
                ),
              ),
            ),
          ),
        ),
      );

      // Verify elements
      expect(find.text('Enter Sign-In Code'), findsOneWidget);
      expect(find.text('tester@thefreshyard.shop'), findsOneWidget);
      expect(find.text('Open Email App'), findsOneWidget);
      expect(find.text('Verify & Continue'), findsOneWidget);

      // Enter 6 digit code
      await tester.enterText(find.byType(TextField), '654321');
      await tester.pumpAndSettle();

      expect(mockRepo.verifiedCode, '654321');
    });
  });
}
