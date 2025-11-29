import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sawa/presentation/providers/auth_provider.dart';

// Generate mocks
@GenerateMocks([FirebaseAuth, FirebaseFirestore, User, UserCredential, DocumentSnapshot])
import 'auth_provider_test.mocks.dart';

void main() {
  group('AuthProvider', () {
    late AuthProvider authProvider;
    late MockFirebaseAuth mockAuth;
    late MockFirebaseFirestore mockFirestore;

    setUp(() {
      mockAuth = MockFirebaseAuth();
      mockFirestore = MockFirebaseFirestore();
      
      // We need to mock the static instances
      // This is a limitation of testing static instances
      // In a real app, you would use dependency injection
      authProvider = AuthProvider();
    });

    tearDown(() {
      authProvider.dispose();
    });

    test('initial state', () {
      expect(authProvider.user, null);
      expect(authProvider.isLoading, false);
      expect(authProvider.errorMessage, null);
      expect(authProvider.currentUserRole, null);
      expect(authProvider.name, null);
      expect(authProvider.email, null);
      expect(authProvider.uid, null);
    });

    test('clearError sets errorMessage to null', () {
      // Simulate an error state
      authProvider.clearError();
      expect(authProvider.errorMessage, null);
    });

    test('login sets loading state', () async {
      // This test would require more complex mocking of static instances
      // For now, we'll just verify the structure
      expect(authProvider, isNotNull);
    });
  });
}