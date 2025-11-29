import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sawa/presentation/screens/splash/splash_screen.dart';
import 'firebase_options.dart';

// Providers
import 'package:sawa/presentation/providers/auth_provider.dart';

// Screens
import 'package:sawa/presentation/screens/auth/forget_password_screen.dart';
import 'package:sawa/presentation/screens/auth/login_screen.dart';
import 'package:sawa/presentation/screens/auth/register_screen.dart';
import 'package:sawa/presentation/screens/home/gym_owner_home_screen.dart';
import 'package:sawa/presentation/screens/home/member_home_screen.dart';
import 'package:sawa/presentation/screens/home/nutrionist_home_screen.dart';
import 'package:sawa/presentation/screens/home/restaurant_owner_home_screen.dart';

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
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MaterialApp(
        title: 'SAWA Fitness',
        debugShowCheckedModeBanner: false,
        
        // --- NEW THEME (Teal & Orange) ---
        theme: ThemeData(
          useMaterial3: true,
          // Colors
          primaryColor: const Color(0xFF009688), // Teal
          scaffoldBackgroundColor: const Color(0xFFF5F5F5), // Light Grey
          
          // Color Scheme
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF009688),
            primary: const Color(0xFF009688),
            secondary: const Color(0xFFFF7043), // Orange
          ),

          // AppBar Theme
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF009688),
            foregroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
            titleTextStyle: TextStyle(
              fontSize: 20, 
              fontWeight: FontWeight.bold, 
              color: Colors.white
            ),
            iconTheme: IconThemeData(color: Colors.white),
          ),

          // Button Theme
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF009688),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              elevation: 2,
            ),
          ),

          // Text Field Theme
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.all(16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF009688), width: 2),
            ),
          ),
        ),

        // --- START SCREEN ---
        // We use SplashScreen instead of AuthWrapper now
        home: const SplashScreen(),

        // --- ROUTES ---
        routes: {
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/forgot-password': (context) => const ForgotPasswordScreen(),
          '/member-home': (context) => const MemberHomeScreen(),
          '/gym-owner-home': (context) => const GymOwnerHomeScreen(),
          '/restaurant-owner-home': (context) => const RestaurantOwnerHomeScreen(),
          '/nutritionist-home': (context) => const NutritionistHomeScreen(),
        },
      ),
    );
  }
}