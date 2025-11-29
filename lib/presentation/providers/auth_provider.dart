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
  String? _uid;
  StreamSubscription<User?>? _authStateSubscription;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get currentUserRole => _currentUserRole;
  String? get name => _name;
  String? get email => _email;
  String? get uid => _uid;

  AuthProvider() {
    _authStateSubscription = _auth.authStateChanges().listen(
      _onAuthStateChanged,
    );
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
    notifyListeners();

    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      // Wait briefly for the auth state stream to pick up the user and role
      // This helps ensure currentUserRole is set before the UI tries to use it.
      await Future.delayed(const Duration(milliseconds: 500));
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'An error occurred';
      if (e.code == 'user-not-found' || e.code == 'invalid-credential') {
        errorMessage = 'Invalid email or password.';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Invalid email or password.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'The email address is invalid.';
      } else if (e.code == 'user-disabled') {
        errorMessage = 'This user account has been disabled.';
      } else if (e.code == 'too-many-requests') {
        errorMessage = 'Too many attempts. Try again later.';
      }
      debugPrint("Firebase login error: $errorMessage");
      throw errorMessage;
    } catch (e) {
      throw 'An unexpected error occurred. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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

      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'name': name,
        'email': email,
        'role': role,
        'createdAt': Timestamp.now(),
      });
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Registration failed';
      if (e.code == 'weak-password') {
        errorMessage = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        errorMessage = 'The account already exists for that email.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'The email address is invalid.';
      }
      debugPrint("Firebase register error: $errorMessage");
      throw errorMessage;
    } catch (e) {
      throw 'An unexpected error occurred. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> resetPassword(String email) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Reset password failed';
      if (e.code == 'user-not-found') {
        errorMessage = 'No user found for that email.';
      }
      throw errorMessage;
    } finally {
      _isLoading = false;
      notifyListeners();
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