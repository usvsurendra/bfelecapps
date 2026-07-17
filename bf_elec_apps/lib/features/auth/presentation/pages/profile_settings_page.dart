import 'dart:convert';
import 'package:bf_elec_apps/core/theme/app_theme.dart';
import 'package:bf_elec_apps/core/widgets/responsive_scaffold.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileSettingsPage extends StatefulWidget {
  const ProfileSettingsPage({super.key});

  @override
  State<ProfileSettingsPage> createState() => _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends State<ProfileSettingsPage> {
  static const String _photoKey = 'profile_photo_base64';
  static const String _nameKey = 'profile_name';
  static const String _emailKey = 'profile_email';

  final ImagePicker _picker = ImagePicker();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  String? _photoBase64;
  bool _isLoading = false;
  String? _message;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _photoBase64 = prefs.getString(_photoKey);
      _nameController.text = prefs.getString(_nameKey) ?? '';
      _emailController.text = prefs.getString(_emailKey) ?? '';
    });
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        imageQuality: 70,
      );
      if (image == null) return;

      final bytes = await image.readAsBytes();
      final base64 = base64Encode(bytes);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_photoKey, base64);

      setState(() {
        _photoBase64 = base64;
        _message = 'Profile photo updated';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profile photo saved. It will appear on next login.'),
            backgroundColor: AppTheme.successGreen,
          ),
        );
      }
    } catch (e) {
      setState(() => _message = 'Failed to upload photo');
    }
  }

  Future<void> _changePassword() async {
    final current = _currentPasswordController.text.trim();
    final newPass = _newPasswordController.text.trim();
    final confirm = _confirmPasswordController.text.trim();

    if (current.isEmpty || newPass.isEmpty || confirm.isEmpty) {
      setState(() => _message = 'Please fill all password fields');
      return;
    }
    if (newPass != confirm) {
      setState(() => _message = 'New passwords do not match');
      return;
    }
    if (newPass.length < 4) {
      setState(() => _message = 'Password must be at least 4 characters');
      return;
    }

    setState(() {
      _isLoading = true;
      _message = null;
    });

    await Future.delayed(const Duration(milliseconds: 800));

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('saved_password', newPass);

    setState(() {
      _isLoading = false;
      _message = 'Password changed successfully';
    });

    _currentPasswordController.clear();
    _newPasswordController.clear();
    _confirmPasswordController.clear();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Password updated successfully'),
          backgroundColor: AppTheme.successGreen,
        ),
      );
    }
  }

  Future<void> _saveProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_nameKey, _nameController.text.trim());
    await prefs.setString(_emailKey, _emailController.text.trim());
    setState(() => _message = 'Profile saved');
  }

  Widget _buildPhotoPreview() {
    if (_photoBase64 == null) {
      return Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: AppTheme.lightGray,
          borderRadius: BorderRadius.circular(60),
          border: Border.all(color: AppTheme.borderGray, width: 2),
        ),
        child: Icon(Icons.person_rounded, size: 60, color: AppTheme.mediumGray),
      );
    }

    try {
      final bytes = base64Decode(_photoBase64!);
      return Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(60),
          border: Border.all(color: AppTheme.primaryBlue, width: 3),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryBlue.withValues(alpha: 0.25),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipOval(
          child: Image.memory(
            bytes,
            width: 120,
            height: 120,
            fit: BoxFit.cover,
          ),
        ),
      );
    } catch (_) {
      return Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: AppTheme.lightGray,
          borderRadius: BorderRadius.circular(60),
          border: Border.all(color: AppTheme.borderGray, width: 2),
        ),
        child: Icon(Icons.person_rounded, size: 60, color: AppTheme.mediumGray),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      currentRoute: '/dashboard/profile',
      title: 'Profile Settings',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  _buildPhotoPreview(),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.camera_alt_rounded),
                    label: const Text('Upload Photo'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      foregroundColor: AppTheme.pureWhite,
                    ),
                  ),
                  if (!kIsWeb)
                    TextButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.photo_library_rounded),
                      label: const Text('Choose from Gallery'),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            if (_message != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.successGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.successGreen.withValues(alpha: 0.3)),
                ),
                child: Text(
                  _message!,
                  style: const TextStyle(color: AppTheme.successGreen, fontWeight: FontWeight.w600),
                ),
              ),
            const SizedBox(height: 24),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Full Name',
                prefixIcon: Icon(Icons.person_outline_rounded, color: AppTheme.primaryBlue),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.alternate_email_rounded, color: AppTheme.primaryBlue),
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: _saveProfile,
                icon: const Icon(Icons.save_rounded),
                label: const Text('Save Profile'),
              ),
            ),
            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 24),
            Text(
              'Change Password',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppTheme.deepNavy,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _currentPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Current Password',
                prefixIcon: Icon(Icons.lock_outline_rounded, color: AppTheme.goldAccent),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _newPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'New Password',
                prefixIcon: Icon(Icons.lock_rounded, color: AppTheme.primaryBlue),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Confirm New Password',
                prefixIcon: Icon(Icons.lock_clock_rounded, color: AppTheme.primaryBlue),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _changePassword,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.pureWhite),
                      )
                    : const Icon(Icons.key_rounded),
                label: Text(_isLoading ? 'Updating...' : 'Change Password'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  foregroundColor: AppTheme.pureWhite,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Password must be at least 4 characters. This is stored locally on your device.',
              style: TextStyle(fontSize: 12, color: AppTheme.slateText, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
