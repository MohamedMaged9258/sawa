import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sawa/main.dart';

void main() {
  group('Authentication Flow Integration', () {
    testWidgets('app launches and shows splash screen', (WidgetTester tester) async {
      // Build our app and trigger a frame
      await tester.pumpWidget(const MyApp());

      // Verify that splash screen is shown initially
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Wait for splash screen to complete (3 seconds)
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Verify that login screen is shown after splash
      expect(find.text('Welcome Back'), findsOneWidget);
    });

    testWidgets('navigation from login to register screen', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      // Wait for splash screen to complete
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Verify we're on login screen
      expect(find.text('Welcome Back'), findsOneWidget);

      // Find and tap the sign up button
      final signUpButton = find.text('Sign Up');
      await tester.tap(signUpButton);
      await tester.pumpAndSettle();

      // Verify we're on register screen
      expect(find.text('Select Your Role'), findsOneWidget);
    });

    testWidgets('navigation from register to login screen', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      // Wait for splash screen to complete
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to register screen
      final signUpButton = find.text('Sign Up');
      await tester.tap(signUpButton);
      await tester.pumpAndSettle();

      // Verify we're on register screen
      expect(find.text('Select Your Role'), findsOneWidget);

      // Find and tap the login button
      final loginButton = find.text('Login');
      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      // Verify we're back on login screen
      expect(find.text('Welcome Back'), findsOneWidget);
    });

    testWidgets('navigation to forgot password screen', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      // Wait for splash screen to complete
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Verify we're on login screen
      expect(find.text('Welcome Back'), findsOneWidget);

      // Find and tap the forgot password button
      final forgotPasswordButton = find.text('Forgot Password?');
      await tester.tap(forgotPasswordButton);
      await tester.pumpAndSettle();

      // Verify we're on forgot password screen
      expect(find.text('Reset Your Password'), findsOneWidget);

      // Find and tap the back to login button
      final backButton = find.text('Back to Login');
      await tester.tap(backButton);
      await tester.pumpAndSettle();

      // Verify we're back on login screen
      expect(find.text('Welcome Back'), findsOneWidget);
    });
  });
}