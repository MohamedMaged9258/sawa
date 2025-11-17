import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sawa/presentation/screens/auth/register_screen.dart';
import '../../../presentation/providers/auth_provider.dart';
import '../../../presentation/widgets/custom_button.dart';
import '../../../presentation/widgets/custom_textfield.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _navigateToRoleScreen(String role, BuildContext context) {
    switch (role) {
      case 'member':
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/member-home',
          (route) => false,
        );
        break;
      case 'gymOwner':
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/gym-owner-home',
          (route) => false,
        );
        break;
      case 'restaurantOwner':
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/restaurant-owner-home',
          (route) => false,
        );
        break;
      case 'nutritionist':
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/nutritionist-home',
          (route) => false,
        );
        break;
      default:
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/member-home',
          (route) => false,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          // ADD THIS
          padding: const EdgeInsets.all(16.0), // ADD THIS
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40), // ADD SPACING
                Text(
                  'Welcome Back',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 32),
                CustomTextField(
                  controller: _emailController,
                  labelText: 'Email or Username',
                  prefixIcon: Icons.person,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please Enter Email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _passwordController,
                  labelText: 'Password',
                  prefixIcon: Icons.lock,
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    // Redirect after successful login
                    if (authProvider.currentUserRole != null &&
                        !authProvider.isLoading) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _navigateToRoleScreen(
                          authProvider.currentUserRole!,
                          context,
                        );
                      });
                    }

                    return CustomButton(
                      text: 'Login',
                      isLoading: authProvider.isLoading,
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          authProvider.login(
                            _emailController.text.trim(),
                            _passwordController.text.trim(),
                          );
                        }
                      },
                    );
                  },
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/forgot-password');
                  },
                  child: const Text('Forgot Password?'),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account?"),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegisterScreen(),
                          ),
                        );
                      },
                      child: const Text('Sign Up'),
                    ),
                  ],
                ),
                const SizedBox(height: 40), // ADD EXTRA SPACE AT BOTTOM
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
