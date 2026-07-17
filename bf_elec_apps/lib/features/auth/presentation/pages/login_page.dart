import 'dart:convert';
import 'package:bf_elec_apps/core/theme/app_theme.dart';
import 'package:bf_elec_apps/features/auth/presentation/pages/auth_layout.dart';
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

  String? _photoBase64;
  String? _savedName;

  @override
  void initState() {
    super.initState();
    _loadSavedProfile();
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

  Future<void> _login(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', true);
    if (context.mounted) context.go('/dashboard/drawings');
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
          Center(
            child: _buildProfileAvatar(),
          ),
          const SizedBox(height: 20),
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
                context.push('/forgot-password');
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
              onPressed: () => _login(context),
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
              onPressed: () => _login(context),
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
                  context.pushReplacement('/register');
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
