import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _user;
  bool _isLoading = false;

  String? _currentUserRole;
  String? _name;
  String? _email;
  StreamSubscription<User?>? _authStateSubscription;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get currentUserRole => _currentUserRole;
  String? get name => _name;
  String? get email => _email;

  AuthProvider() {
    _authStateSubscription = _auth.authStateChanges().listen(
      _onAuthStateChanged,
    );
  }

  Future<void> _onAuthStateChanged(User? user) async {
    _user = user;
    if (user == null) {
      _currentUserRole = null;
    } else {
      await _fetchUserData(user.uid);
    }
    notifyListeners();
  }

  Future<void> _fetchUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        final data = doc.data();
        _currentUserRole = data?['role'];
        _name = data?['name'];
        _email = data?['email'];
      }
    } catch (e) {
      debugPrint("Error fetching user data: $e");
      _currentUserRole = null;
      _name = null;
      _email = null;
    }
  }

  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      // The authStateChanges listener will handle the rest
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
    notifyListeners();

    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      // Save user data to Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'name': name,
        'email': email,
        'role': role,
        'createdAt': Timestamp.now(),
      });

      _name = name;
      _currentUserRole = role;
      _email = email;
      // The authStateChanges listener will handle the rest
    } on FirebaseAuthException catch (e) {
      debugPrint("Firebase register error: ${e.message}");
      // Here you could set an error message to show in the UI
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> resetPassword(String email) async {
    _isLoading = true;
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

  Future<void> logout() async {
    await _auth.signOut();
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    super.dispose();
  }
}
