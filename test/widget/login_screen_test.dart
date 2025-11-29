import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sawa/presentation/screens/auth/login_screen.dart';
import 'package:sawa/presentation/providers/auth_provider.dart';

void main() {
  group('LoginScreen', () {
    late AuthProvider authProvider;

    setUp(() {
      authProvider = AuthProvider();
    });

    tearDown(() {
      authProvider.dispose();
    });

    testWidgets('renders email and password fields', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AuthProvider>.value(
            value: authProvider,
            child: const LoginScreen(),
          ),
        ),
      );

      expect(find.text('Welcome Back'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.text('Login'), findsOneWidget);
    });

    testWidgets('shows error message when email is empty', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AuthProvider>.value(
            value: authProvider,
            child: const LoginScreen(),
          ),
        ),
      );

      // Find the login button and tap it
      final loginButton = find.text('Login');
      await tester.tap(loginButton);
      await tester.pump();

      // Expect to see validation error
      expect(find.text('Please enter your email address'), findsOneWidget);
    });

    testWidgets('shows error message for invalid email', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AuthProvider>.value(
            value: authProvider,
            child: const LoginScreen(),
          ),
        ),
      );

      // Enter invalid email
      await tester.enterText(find.byType(TextFormField).first, 'invalid-email');
      await tester.pump();

      // Find the login button and tap it
      final loginButton = find.text('Login');
      await tester.tap(loginButton);
      await tester.pump();

      // Expect to see validation error
      expect(find.text('Please enter a valid email address'), findsOneWidget);
    });

    testWidgets('shows error message when password is empty', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AuthProvider>.value(
            value: authProvider,
            child: const LoginScreen(),
          ),
        ),
      );

      // Find the login button and tap it
      final loginButton = find.text('Login');
      await tester.tap(loginButton);
      await tester.pump();

      // Expect to see validation error
      expect(find.text('Please enter your password'), findsOneWidget);
    });

    testWidgets('shows error message for short password', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AuthProvider>.value(
            value: authProvider,
            child: const LoginScreen(),
          ),
        ),
      );

      // Enter short password
      await tester.enterText(find.byType(TextFormField).at(1), '123');
      await tester.pump();

      // Find the login button and tap it
      final loginButton = find.text('Login');
      await tester.tap(loginButton);
      await tester.pump();

      // Expect to see validation error
      expect(find.text('Password must be at least 6 characters'), findsOneWidget);
    });
  });
}