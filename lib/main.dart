import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sawa/presentation/providers/auth_provider.dart';
import 'package:sawa/presentation/screens/auth/forget_password_screen.dart';
import 'package:sawa/presentation/screens/auth/login_screen.dart';
import 'package:sawa/presentation/screens/auth/register_screen.dart';
import 'package:sawa/presentation/screens/home/gym_owner_home_screen.dart';
import 'package:sawa/presentation/screens/home/member_home_screen.dart';
import 'package:sawa/presentation/screens/home/nutrionist_home_screen.dart';
import 'package:sawa/presentation/screens/home/restaurant_owner_home_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
// test rule set
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
        title: 'SAWA Fitness App',
        theme: ThemeData(
          primarySwatch: Colors.green,
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
        ),
        debugShowCheckedModeBanner: false,
        initialRoute: '/login',
        routes: {
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/forgot-password': (context) => const ForgotPasswordScreen(),
          '/member-home': (context) => const MemberHomeScreen(),
          '/gym-owner-home': (context) => const GymOwnerHomeScreen(),
          '/restaurant-owner-home': (context) => const RestaurantOwnerHomeScreen(),
          '/nutritionist-home': (context) => const NutritionistHomeScreen(),
        },
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    if (authProvider.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (authProvider.currentUserRole != null) {
      switch (authProvider.currentUserRole) {
        case 'member':
          return const MemberHomeScreen();
        case 'gymOwner':
          return const GymOwnerHomeScreen();
        case 'restaurantOwner':
          return const RestaurantOwnerHomeScreen();
        case 'nutritionist':
          return const NutritionistHomeScreen();
        default:
          return const LoginScreen();
      }
    }

    return const LoginScreen();
  }
}