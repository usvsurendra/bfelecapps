import 'package:bf_elec_apps/features/auth/presentation/pages/auth_layout.dart';
import 'package:bf_elec_apps/features/auth/presentation/pages/login_page.dart';
import 'package:flutter/material.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _isEmailValid = true;

  void _validateAndSubmit() {
    final email = _emailController.text;
    if (!email.endsWith('@vizagsteel.com') && !email.endsWith('@bf_elec.com')) {
      setState(() {
        _isEmailValid = false;
      });
      return;
    }
    
    setState(() {
      _isEmailValid = true;
    });
    
    // Proceed with Signup
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      title: 'Signup',
      subtitle: 'Please use your RINL mail id',
      headerColor: Theme.of(context).colorScheme.secondary,
      headerIcon: Icons.person_add_alt_1,
      formContent: Column(
        children: [
          TextField(
            controller: _usernameController,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.person, color: Colors.orange),
              hintText: 'Username',
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _emailController,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.alternate_email, color: Colors.blue),
              hintText: 'Email Address',
              errorText: !_isEmailValid ? 'Please enter valid bf elec mail id' : null,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.lock, color: Colors.orange),
              hintText: 'Password',
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _validateAndSubmit,
              icon: const Icon(Icons.person_add),
              label: const Text('SIGNUP'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.secondary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ),
        ],
      ),
      footerContent: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Already a member please '),
          TextButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            },
            child: Text(
              'Login',
              style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
