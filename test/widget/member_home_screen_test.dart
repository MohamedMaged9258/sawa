import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sawa/presentation/screens/home/member_home_screen.dart';
import 'package:sawa/presentation/providers/auth_provider.dart';

void main() {
  group('MemberHomeScreen', () {
    late AuthProvider authProvider;

    setUp(() {
      authProvider = AuthProvider();
    });

    tearDown(() {
      authProvider.dispose();
    });

    testWidgets('renders dashboard with welcome message', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AuthProvider>.value(
            value: authProvider,
            child: const MemberHomeScreen(),
          ),
        ),
      );

      // Verify basic elements are present
      expect(find.text('SAWA Fitness'), findsOneWidget);
      expect(find.byType(BottomNavigationBar), findsOneWidget);
    });

    testWidgets('shows loading indicator initially', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AuthProvider>.value(
            value: authProvider,
            child: const MemberHomeScreen(),
          ),
        ),
      );

      // Initially should show loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('navigates between bottom navigation tabs', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AuthProvider>.value(
            value: authProvider,
            child: const MemberHomeScreen(),
          ),
        ),
      );

      // Wait for initial load
      await tester.pumpAndSettle();

      // Verify we're on dashboard (first tab)
      expect(find.text('Dashboard'), findsOneWidget);

      // Tap on Gyms tab (index 1)
      await tester.tap(find.byIcon(Icons.fitness_center));
      await tester.pumpAndSettle();

      // Tap on Restaurants tab (index 2)
      await tester.tap(find.byIcon(Icons.restaurant));
      await tester.pumpAndSettle();

      // Tap on Nutritionists tab (index 3)
      await tester.tap(find.byIcon(Icons.medical_services));
      await tester.pumpAndSettle();

      // Tap back on Dashboard tab (index 0)
      await tester.tap(find.byIcon(Icons.dashboard));
      await tester.pumpAndSettle();

      expect(find.text('Dashboard'), findsOneWidget);
    });
  });
}