import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthProvider with ChangeNotifier {
  bool _isLoading = false;
  String? _currentUserRole;
  User? _currentUser;
  String? _userName;
  String? _userPhone;

  bool get isLoading => _isLoading;
  String? get currentUserRole => _currentUserRole;
  User? get currentUser => _currentUser;
  String? get userName => _userName;
  String? get userPhone => _userPhone;

  Future<void> login(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();

      final UserCredential userCredential = 
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      _currentUser = userCredential.user;
      
      // Extract name from email or use display name
      _userName = _currentUser?.displayName ?? 
                  _currentUser?.email?.split('@').first ?? 
                  'User';
      _userPhone = _currentUser?.phoneNumber ?? '+1234567890';
      
      // For demo purposes, set role based on email
      if (email.contains('gym')) {
        _currentUserRole = 'gymOwner';
      } else if (email.contains('restaurant')) {
        _currentUserRole = 'restaurantOwner';
      } else if (email.contains('nutrition')) {
        _currentUserRole = 'nutritionist';
      } else {
        _currentUserRole = 'member';
      }

      _isLoading = false;
      notifyListeners();

    } on FirebaseAuthException {
      _isLoading = false;
      notifyListeners();
      rethrow;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> register({
    required String email,
    required String name,
    required String password,
    required String role,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final UserCredential userCredential = 
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      _currentUser = userCredential.user;
      _currentUserRole = role;
      _userName = name;

      // Update user profile in Firebase
      await _currentUser?.updateDisplayName(name);

      _isLoading = false;
      notifyListeners();

    } on FirebaseAuthException {
      _isLoading = false;
      notifyListeners();
      rethrow;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      _currentUser = null;
      _currentUserRole = null;
      _userName = null;
      _userPhone = null;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  // Check if user is already logged in
  Future<void> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();

    _currentUser = FirebaseAuth.instance.currentUser;
    
    if (_currentUser != null) {
      // Get user data from Firebase
      _userName = _currentUser?.displayName ?? 
                  _currentUser?.email?.split('@').first ?? 
                  'User';
      
      // In real app, you'd fetch user role from Firestore here
      // For demo, using email-based logic
      final email = _currentUser!.email ?? '';
      if (email.contains('gym')) {
        _currentUserRole = 'gymOwner';
      } else if (email.contains('restaurant')) {
        _currentUserRole = 'restaurantOwner';
      } else if (email.contains('nutrition')) {
        _currentUserRole = 'nutritionist';
      } else {
        _currentUserRole = 'member';
      }
    }

    _isLoading = false;
    notifyListeners();
  }
}