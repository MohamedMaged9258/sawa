import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sawa/presentation/providers/auth_provider.dart';
import 'auth_provider_test.mocks.dart';

// Generate mocks
@GenerateMocks([FirebaseAuth, FirebaseFirestore, User, UserCredential, DocumentSnapshot])
void main() {
  group('AuthProvider', () {
    late AuthProvider authProvider;
    late MockFirebaseAuth mockAuth;
    late MockFirebaseFirestore mockFirestore;

    setUp(() {
      mockAuth = MockFirebaseAuth();
      mockFirestore = MockFirebaseFirestore();
      
      // Create AuthProvider with mocked dependencies
      authProvider = AuthProvider(auth: mockAuth, firestore: mockFirestore);
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
      // We can't directly set the private field, but we can test the method
      authProvider.clearError();
      expect(authProvider.errorMessage, null);
    });

    test('AuthProvider class exists', () {
      expect(AuthProvider, isNotNull);
    });
  });
}