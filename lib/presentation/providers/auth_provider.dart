import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  String? _currentUserRole;
  String? _name;
  String? _email;
  String? _uid;
  StreamSubscription<User?>? _authStateSubscription;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get currentUserRole => _currentUserRole;
  String? get name => _name;
  String? get email => _email;
  String? get uid => _uid;

  AuthProvider() {
    _authStateSubscription = _auth.authStateChanges().listen(
      _onAuthStateChanged,
    );
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> _onAuthStateChanged(User? user) async {
    _user = user;
    if (user == null) {
      _clearUserData();
    } else {
      await _fetchUserData(user.uid);
    }
    notifyListeners();
  }

  void _clearUserData() {
    _currentUserRole = null;
    _name = null;
    _email = null;
    _uid = null;
  }

  Future<void> _fetchUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        final data = doc.data();
        _currentUserRole = data?['role'];
        _name = data?['name'];
        _email = data?['email'];
        _uid = data?['uid'];
      }
    } catch (e) {
      debugPrint("Error fetching user data: $e");
      _clearUserData();
    }
  }

  Future<void> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      // Wait briefly for the auth state stream to pick up the user and role
      // This helps ensure currentUserRole is set before the UI tries to use it.
      await Future.delayed(const Duration(milliseconds: 500));
    } on FirebaseAuthException catch (e) {
      debugPrint("Firebase login error: ${e.message}");
      // Here you could set an error message to show in the UI
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> register({
    required String email,
    required String name,
    required String password,
    required String role,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'name': name,
        'email': email,
        'role': role,
        'createdAt': Timestamp.now(),
      });
    } on FirebaseAuthException catch (e) {
      debugPrint("Firebase register error: ${e.message}");
      // Here you could set an error message to show in the UI
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> resetPassword(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      debugPrint("Firebase password reset error: ${e.message}");
      rethrow; // Rethrow the exception to be caught in the UI
    }

    _isLoading = false;
    notifyListeners();
  }

  String _mapFirebaseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'The email address is badly formatted.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'operation-not-allowed':
        return 'This operation is not allowed.';
      case 'weak-password':
        return 'The password is too weak.';
      default:
        return e.message ?? 'An unknown error occurred.';
    }
  }

  Future<void> logout() async {
    _clearUserData();
    await _auth.signOut();
    notifyListeners();
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    super.dispose();
  }
}