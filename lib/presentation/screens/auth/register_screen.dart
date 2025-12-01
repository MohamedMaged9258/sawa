import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../presentation/providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../../presentation/widgets/custom_textfield.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String? _selectedRole;

  final List<Map<String, dynamic>> _userRoles = [
    {'value': 'member', 'label': 'Member', 'icon': Icons.person},
    {'value': 'gymOwner', 'label': 'Gym Owner', 'icon': Icons.fitness_center},
    {
      'value': 'restaurantOwner',
      'label': 'Restaurant Owner',
      'icon': Icons.restaurant,
    },
    {
      'value': 'nutritionist',
      'label': 'Nutritionist',
      'icon': Icons.medical_services,
    },
  ];

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
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 20),
                Text(
                  'Select Your Role',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.5,
                  ),
                  itemCount: _userRoles.length,
                  itemBuilder: (context, index) {
                    final role = _userRoles[index];
                    final isSelected = _selectedRole == role['value'];
                    return Card(
                      color: isSelected
                          ? Theme.of(context).primaryColor.withOpacity(0.1)
                          : null,
                      elevation: isSelected ? 4 : 1,
                      child: InkWell(
                        onTap: () =>
                            setState(() => _selectedRole = role['value']),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                role['icon'],
                                color: isSelected
                                    ? Theme.of(context).primaryColor
                                    : Colors.grey,
                                size: 32,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                role['label'],
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: isSelected
                                      ? Theme.of(context).primaryColor
                                      : Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                CustomTextField(
                  controller: _nameController,
                  labelText: 'Full Name',
                  prefixIcon: Icons.person_outline,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please Enter Name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _emailController,
                  labelText: 'Email Address',
                  prefixIcon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter email';
                    }
                    if (!RegExp(
                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                    ).hasMatch(value)) {
                      return 'Please enter a valid email';
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
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _confirmPasswordController,
                  labelText: 'Confirm Password',
                  prefixIcon: Icons.lock_outline,
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm password';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                Consumer<AuthProvider>(
                  builder: (context, authProvider, _) {
                    if (authProvider.currentUserRole != null &&
                        !authProvider.isLoading &&
                        authProvider.user != null) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _navigateToRoleScreen(
                          authProvider.currentUserRole!,
                          context,
                        );
                      });
                    }
                    return CustomButton(
                      text: 'Create Account',
                      isLoading: authProvider.isLoading,
                      onPressed: _selectedRole == null
                          ? null
                          : () async {
                              if (_formKey.currentState!.validate()) {
                                try {
                                  await authProvider.register(
                                    email: _emailController.text.trim(),
                                    name: _nameController.text.trim(),
                                    password: _passwordController.text.trim(),
                                    role: _selectedRole!,
                                  );
                                } on FirebaseAuthException catch (e) {
                                  if (context.mounted) {
                                    _showErrorSnackBar(
                                      context,
                                      authProvider.errorMessage ?? 'Error',
                                    );

                                    // Clear fields based on specific error code
                                    if (e.code == 'weak-password') {
                                      _passwordController.clear();
                                      _confirmPasswordController.clear();
                                    }
                                    // Note: If 'email-already-in-use', we usually let user change it rather than clearing it.
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    _showErrorSnackBar(
                                      context,
                                      'Registration failed. Please try again.',
                                    );
                                  }
                                }
                              }
                            },
                    );
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account?"),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Login'),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
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
    _nameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
