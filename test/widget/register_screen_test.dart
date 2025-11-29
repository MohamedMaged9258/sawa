import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sawa/presentation/screens/auth/register_screen.dart';
import 'package:sawa/presentation/providers/auth_provider.dart';

void main() {
  group('RegisterScreen', () {
    late AuthProvider authProvider;

    setUp(() {
      authProvider = AuthProvider();
    });

    tearDown(() {
      authProvider.dispose();
    });

    testWidgets('renders registration form fields', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AuthProvider>.value(
            value: authProvider,
            child: const RegisterScreen(),
          ),
        ),
      );

      expect(find.text('Select Your Role'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(4)); // name, email, password, confirm password
      expect(find.text('Create Account'), findsOneWidget);
    });

    testWidgets('shows error message when name is empty', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AuthProvider>.value(
            value: authProvider,
            child: const RegisterScreen(),
          ),
        ),
      );

      // Tap create account button without filling form
      final createAccountButton = find.text('Create Account');
      await tester.tap(createAccountButton);
      await tester.pump();

      expect(find.text('Please enter your full name'), findsOneWidget);
    });

    testWidgets('shows error message for invalid name format', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AuthProvider>.value(
            value: authProvider,
            child: const RegisterScreen(),
          ),
        ),
      );

      // Enter invalid name (only first name)
      await tester.enterText(find.byType(TextFormField).at(0), 'John');
      await tester.pump();

      // Tap create account button
      final createAccountButton = find.text('Create Account');
      await tester.tap(createAccountButton);
      await tester.pump();

      expect(find.text('Please enter both first and last name'), findsOneWidget);
    });

    testWidgets('shows error message when email is empty', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AuthProvider>.value(
            value: authProvider,
            child: const RegisterScreen(),
          ),
        ),
      );

      // Tap create account button without filling form
      final createAccountButton = find.text('Create Account');
      await tester.tap(createAccountButton);
      await tester.pump();

      expect(find.text('Please enter your email address'), findsOneWidget);
    });

    testWidgets('shows error message for invalid email', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AuthProvider>.value(
            value: authProvider,
            child: const RegisterScreen(),
          ),
        ),
      );

      // Enter invalid email
      await tester.enterText(find.byType(TextFormField).at(1), 'invalid-email');
      await tester.pump();

      // Tap create account button
      final createAccountButton = find.text('Create Account');
      await tester.tap(createAccountButton);
      await tester.pump();

      expect(find.text('Please enter a valid email address'), findsOneWidget);
    });

    testWidgets('shows error message when password is empty', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AuthProvider>.value(
            value: authProvider,
            child: const RegisterScreen(),
          ),
        ),
      );

      // Tap create account button without filling form
      final createAccountButton = find.text('Create Account');
      await tester.tap(createAccountButton);
      await tester.pump();

      expect(find.text('Please enter a password'), findsOneWidget);
    });

    testWidgets('shows error message for short password', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AuthProvider>.value(
            value: authProvider,
            child: const RegisterScreen(),
          ),
        ),
      );

      // Enter short password
      await tester.enterText(find.byType(TextFormField).at(2), '123');
      await tester.pump();

      // Tap create account button
      final createAccountButton = find.text('Create Account');
      await tester.tap(createAccountButton);
      await tester.pump();

      expect(find.text('Password must be at least 6 characters'), findsOneWidget);
    });

    testWidgets('shows error message when password missing uppercase', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AuthProvider>.value(
            value: authProvider,
            child: const RegisterScreen(),
          ),
        ),
      );

      // Enter password without uppercase
      await tester.enterText(find.byType(TextFormField).at(2), 'password123');
      await tester.pump();

      // Tap create account button
      final createAccountButton = find.text('Create Account');
      await tester.tap(createAccountButton);
      await tester.pump();

      expect(find.text('Password must contain at least one uppercase letter'), findsOneWidget);
    });

    testWidgets('shows error message when password missing number', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AuthProvider>.value(
            value: authProvider,
            child: const RegisterScreen(),
          ),
        ),
      );

      // Enter password without number
      await tester.enterText(find.byType(TextFormField).at(2), 'Password');
      await tester.pump();

      // Tap create account button
      final createAccountButton = find.text('Create Account');
      await tester.tap(createAccountButton);
      await tester.pump();

      expect(find.text('Password must contain at least one number'), findsOneWidget);
    });

    testWidgets('shows error message when passwords do not match', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AuthProvider>.value(
            value: authProvider,
            child: const RegisterScreen(),
          ),
        ),
      );

      // Enter password
      await tester.enterText(find.byType(TextFormField).at(2), 'Password123');
      // Enter different confirm password
      await tester.enterText(find.byType(TextFormField).at(3), 'Different123');
      await tester.pump();

      // Tap create account button
      final createAccountButton = find.text('Create Account');
      await tester.tap(createAccountButton);
      await tester.pump();

      expect(find.text('Passwords do not match'), findsOneWidget);
    });
  });
}