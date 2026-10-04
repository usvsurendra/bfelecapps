import 'package:bf_elec_apps/core/theme/app_theme.dart';
import 'package:bf_elec_apps/core/config/firebase_bootstrap.dart';
import 'package:bf_elec_apps/features/auth/domain/services/auth_validator.dart';
import 'package:bf_elec_apps/features/auth/presentation/pages/auth_layout.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = 'Please fill in all fields.');
      return;
    }

    if (!email.endsWith('@vizagsteel.com') && !email.endsWith('@bf_elec.com')) {
      setState(() => _errorMessage = 'Please use a valid RINL/BF email domain.');
      return;
    }

    if (password.length < 6) {
      setState(() => _errorMessage = 'Password must be at least 6 characters.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final isAllowed = await AuthValidator.isEmailAllowed(email);
    if (!mounted) return;

    if (!isAllowed) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'This email is not authorized to register. Please contact admin.';
      });
      return;
    }

    final auth = safeAuth;
    if (auth == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Registration is not available on this platform.';
      });
      return;
    }

    try {
      await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      // GoRouter authStateProvider will automatically redirect to /dashboard
      if (mounted) context.go('/dashboard');
    } on FirebaseAuthException catch (e) {
      setState(() {
        _isLoading = false;
        if (e.code == 'weak-password') {
          _errorMessage = 'The password provided is too weak.';
        } else if (e.code == 'email-already-in-use') {
          _errorMessage = 'An account already exists for that email.';
        } else if (e.code == 'invalid-email') {
          _errorMessage = 'The email address is invalid.';
        } else {
          _errorMessage = 'Signup failed: ${e.message}';
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'An unexpected error occurred. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      title: 'Create Account',
      subtitle: 'Please use your official RINL mail id',
      headerColor: AppTheme.accentTeal,
      headerIcon: Icons.person_add_rounded,
      formContent: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Email field
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autocorrect: false,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.alternate_email_rounded, color: AppTheme.accentTeal),
              hintText: 'user@vizagsteel.com',
              labelText: 'Email Address',
            ),
          ),
          const SizedBox(height: 16),

          // Password field
          TextField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _signup(),
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.lock_outline_rounded, color: AppTheme.accentTeal),
              hintText: 'Password (min 6 chars)',
              labelText: 'Password',
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: AppTheme.slateText,
                ),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
          ),

          // Error message
          if (_errorMessage != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppTheme.dangerRed.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.dangerRed.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline_rounded, color: AppTheme.dangerRed, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(
                        color: AppTheme.dangerRed,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),

          // Signup button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _signup,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentTeal,
                foregroundColor: AppTheme.pureWhite,
                disabledBackgroundColor: AppTheme.accentTeal.withOpacity(0.6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : const Text(
                      'Create Account',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
                'Already a member? ',
                style: TextStyle(color: AppTheme.slateText),
              ),
              TextButton(
                onPressed: () => context.go('/login'),
                child: Text(
                  'Log in',
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
