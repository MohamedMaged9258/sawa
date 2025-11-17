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
    _navigateToNextScreen();
  }

  void _navigateToNextScreen() async {
    // Wait for 3 seconds
    await Future.delayed(const Duration(seconds: 3));

    // Check if user is logged in (in real app, check from shared preferences or provider)
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (mounted) {
      if (authProvider.currentUserRole != null) {
        // User is logged in, go to appropriate home screen
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
        // User is not logged in, go to login screen
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Or your preferred background color
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Your splash image
            Image.asset(
              'assets/images/sawa_logo.png', // Change to your image path
              width: 200,
              height: 200,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 20),
            // Optional: Loading indicator
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
            const SizedBox(height: 20),
            // Optional: App name
            const Text(
              'Fitness App',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
