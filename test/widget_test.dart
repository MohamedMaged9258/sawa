// This file contains comprehensive widget tests for the SAWA Fitness app.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sawa/main.dart';

void main() {
  group('App Smoke Tests', () {
    testWidgets('App launches without crashing', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(const MyApp());

      // Verify that the app starts (splash screen should be visible)
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('App has correct title', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      // Verify that the app has the correct title
      expect(find.text('SAWA Fitness'), findsOneWidget);
    });
  });
}