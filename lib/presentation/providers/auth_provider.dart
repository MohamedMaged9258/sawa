import 'package:flutter/foundation.dart';

class AuthProvider with ChangeNotifier {
  bool _isLoading = false;
  String? _currentUserRole;
  
  bool get isLoading => _isLoading;
  String? get currentUserRole => _currentUserRole;

  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    
    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));
    
    // For demo, set a role (in real app, get from API)
    _currentUserRole = 'member'; // Default role for demo
    _isLoading = false;
    notifyListeners();
  }

  Future<void> register({
    required String email,
    required String username,
    required String password,
    required String role,
  }) async {
    _isLoading = true;
    notifyListeners();
    
    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));
    
    // Save the role for redirection
    _currentUserRole = role;
    _isLoading = false;
    notifyListeners();
  }

  void logout() {
    _currentUserRole = null;
    notifyListeners();
  }
}