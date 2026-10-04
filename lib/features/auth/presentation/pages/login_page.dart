import 'dart:convert';
import 'package:bf_elec_apps/core/theme/app_theme.dart';
import 'package:bf_elec_apps/core/config/firebase_bootstrap.dart';
import 'package:bf_elec_apps/features/auth/domain/services/auth_validator.dart';
import 'package:bf_elec_apps/features/auth/presentation/pages/auth_layout.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  static const String _photoKey = 'profile_photo_base64';
  static const String _nameKey = 'profile_name';

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  String? _photoBase64;
  String? _savedName;

  @override
  void initState() {
    super.initState();
    _loadSavedProfile();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedProfile() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _photoBase64 = prefs.getString(_photoKey);
        _savedName = prefs.getString(_nameKey);
      });
    }
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (!firebaseReady) {
      setState(() => _errorMessage = 'Firebase is not initialized for Web. Please run flutterfire configure.');
      return;
    }

    if (email.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = 'Please enter your email and password.');
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
        _errorMessage = 'This email is not authorized. Please contact admin.';
      });
      return;
    }

    final auth = safeAuth;
    if (auth == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Sign in is not available on this platform.';
      });
      return;
    }

    try {
      await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (mounted) context.go('/dashboard');
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = _mapFirebaseError(e.code);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'An unexpected error occurred. Please try again.';
        _isLoading = false;
      });
    }
  }

  String _mapFirebaseError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found for this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This account has been disabled. Contact admin.';
      case 'too-many-requests':
        return 'Too many failed attempts. Try again later.';
      case 'invalid-credential':
        return 'Invalid credentials. Please check your email and password.';
      case 'network-request-failed':
        return 'Network error. Check your internet connection.';
      default:
        return 'Login failed. Please try again.';
    }
  }

  Widget _buildProfileAvatar() {
    if (_photoBase64 == null) {
      return CircleAvatar(
        radius: 28,
        backgroundColor: AppTheme.primaryBlue,
        child: Text(
          (_savedName ?? 'U').substring(0, 1).toUpperCase(),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 20),
        ),
      );
    }
    try {
      final bytes = base64Decode(_photoBase64!);
      return CircleAvatar(
        radius: 28,
        backgroundImage: MemoryImage(bytes),
      );
    } catch (_) {
      return CircleAvatar(
        radius: 28,
        backgroundColor: AppTheme.primaryBlue,
        child: Text(
          (_savedName ?? 'U').substring(0, 1).toUpperCase(),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 20),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      title: 'BFELECAPPS',
      subtitle: _savedName != null ? 'Welcome back, $_savedName' : 'Sign in to access all modules',
      headerColor: AppTheme.primaryBlue,
      headerIcon: Icons.lock_open_rounded,
      formContent: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(child: _buildProfileAvatar()),
          const SizedBox(height: 20),

          // Email field
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autocorrect: false,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.alternate_email_rounded, color: AppTheme.primaryBlue),
              hintText: 'RINL Email',
              labelText: 'Email',
            ),
          ),
          const SizedBox(height: 16),

          // Password field
          TextField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _login(),
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.lock_outline_rounded, color: AppTheme.goldAccent),
              hintText: 'Password',
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

          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => context.push('/forgot-password'),
              child: Text(
                'Forgot Password?',
                style: TextStyle(
                  color: AppTheme.primaryBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Login button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _login,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: AppTheme.pureWhite,
                disabledBackgroundColor: AppTheme.primaryBlue.withOpacity(0.6),
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
                      'Login',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
            ),
          ),

          if (safeAuth == null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppTheme.warningAmber.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.warningAmber.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded, color: AppTheme.warningAmber, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Signing in is not available on this platform.',
                      style: TextStyle(
                        color: AppTheme.warningAmber,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: () => context.go('/dashboard'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primaryBlue,
                  side: const BorderSide(color: AppTheme.primaryBlue, width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text(
                  'Continue without signing in',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
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
                onPressed: () => context.pushReplacement('/register'),
                child: Text(
                  'Create account',
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
