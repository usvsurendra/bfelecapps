import 'package:bf_elec_apps/core/theme/app_theme.dart';
import 'package:bf_elec_apps/features/auth/presentation/pages/auth_layout.dart';
import 'package:bf_elec_apps/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:bf_elec_apps/features/auth/presentation/pages/signup_page.dart';
import 'package:bf_elec_apps/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      title: 'BFELECAPPS',
      subtitle: 'Sign in to access all modules',
      headerColor: AppTheme.primaryBlue,
      headerIcon: Icons.lock_open_rounded,
      formContent: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.alternate_email_rounded, color: AppTheme.primaryBlue),
              hintText: 'RINL Email',
              labelText: 'Email',
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            obscureText: true,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.lock_outline_rounded, color: AppTheme.goldAccent),
              hintText: 'Password',
              labelText: 'Password',
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ForgotPasswordPage()),
                );
              },
              child: Text(
                'Forgot Password?',
                style: TextStyle(
                  color: AppTheme.primaryBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const DashboardPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: AppTheme.pureWhite,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Login',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const DashboardPage()),
                );
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppTheme.primaryBlue, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_outline_rounded, color: AppTheme.primaryBlue, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Guest Login',
                    style: TextStyle(
                      color: AppTheme.primaryBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      footerContent: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Don't have an Account? ",
                style: TextStyle(color: AppTheme.slateText),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const SignupPage()),
                  );
                },
                child: Text(
                  'create account',
                  style: TextStyle(
                    color: AppTheme.primaryBlue,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
