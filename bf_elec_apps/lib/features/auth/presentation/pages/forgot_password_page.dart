import 'package:bf_elec_apps/features/auth/presentation/pages/auth_layout.dart';
import 'package:flutter/material.dart';

class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      title: 'Forgot Password?',
      subtitle: 'We just need your email id to send\nPassword Reset instructions',
      headerColor: Colors.lightBlue,
      headerIcon: Icons.question_mark_rounded,
      formContent: Column(
        children: [
          const TextField(
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.alternate_email, color: Colors.orange),
              hintText: 'Email Address',
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Send reset link
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text('Reset Password'),
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      footerContent: const SizedBox.shrink(),
    );
  }
}
