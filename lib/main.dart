import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sawa/presentation/screens/auth/forget_password_screen.dart';
import 'firebase_options.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/screens/splash/splash_screen.dart'; // ADD THIS
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/auth/register_screen.dart';
import 'presentation/screens/home/member_home_screen.dart';
import 'presentation/screens/home/gym_owner_home_screen.dart';
import 'presentation/screens/home/restaurant_owner_home_screen.dart';
import 'presentation/screens/home/nutrionist_home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AuthProvider())],
      child: MaterialApp(
        title: 'Fitness App',
        initialRoute: '/splash', // CHANGE THIS
        routes: {
          '/splash': (context) => const SplashScreen(), // ADD THIS
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/forgot-password': (context) => const ForgotPasswordScreen(),
          '/member-home': (context) => const MemberHomeScreen(),
          '/gym-owner-home': (context) => const GymOwnerHomeScreen(),
          '/restaurant-owner-home': (context) =>
              const RestaurantOwnerHomeScreen(),
          '/nutritionist-home': (context) => const NutritionistHomeScreen(),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
