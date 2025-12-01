import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    // 1. Wait for logo animation/branding time
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    // 2. Check Auth State
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // This property (currentUserRole) must exist in your AuthProvider
    if (authProvider.currentUserRole != null) {
      switch (authProvider.currentUserRole) {
        case 'member':
          Navigator.pushReplacementNamed(context, '/member-home');
          break;
        case 'gymOwner':
          Navigator.pushReplacementNamed(context, '/gym-owner-home');
          break;
        case 'restaurantOwner':
          Navigator.pushReplacementNamed(context, '/restaurant-owner-home');
          break;
        case 'nutritionist':
          Navigator.pushReplacementNamed(context, '/nutritionist-home');
          break;
        default:
          Navigator.pushReplacementNamed(context, '/login');
      }
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Access the Theme we defined in main.dart
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Image.asset(
              'assets/images/sawa_logo.png',
              width: 180,
              height: 180,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 30),

            // Loading Indicator (Themed)
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
            ),
          ],
        ),
      ),
    );
  }
}
