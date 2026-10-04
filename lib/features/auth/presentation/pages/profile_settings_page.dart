import 'dart:convert';
import 'package:bf_elec_apps/core/theme/app_theme.dart';
import 'package:bf_elec_apps/core/config/firebase_bootstrap.dart';
import 'package:bf_elec_apps/core/widgets/responsive_scaffold.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;
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
  static const String _photoUrlKey = 'profile_photo_url';
  static const String _nameKey = 'profile_name';

  final ImagePicker _picker = ImagePicker();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  String? _photoUrl;
  String? _photoBase64;
  bool _isLoading = false;
  bool _isUploading = false;
  String? _message;
  bool _messageIsError = false;

  bool get _canUseCamera =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _setMessage(String message, {bool isError = false}) {
    if (!mounted) return;
    setState(() {
      _message = message;
      _messageIsError = isError;
    });
  }

  void _showSnack(String text, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: isError ? AppTheme.dangerRed : AppTheme.successGreen,
      ),
    );
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedUrl = prefs.getString(_photoUrlKey);
    final authPhotoUrl = safeAuth?.currentUser?.photoURL;
    if (!mounted) return;
    setState(() {
      _photoUrl = authPhotoUrl ?? cachedUrl;
      _photoBase64 = prefs.getString(_photoKey);
      _nameController.text = prefs.getString(_nameKey) ?? '';
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 512,
        imageQuality: 70,
      );
      if (image == null) return;

      final bytes = await image.readAsBytes();
      final storage = safeStorage;
      final user = safeAuth?.currentUser;

      if (storage == null || user == null) {
        final base64 = base64Encode(bytes);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_photoKey, base64);
        if (!mounted) return;
        setState(() {
          _photoBase64 = base64;
          _photoUrl = null;
        });
        _setMessage('Photo saved on this device only. Cloud sync is unavailable.');
        _showSnack('Photo saved on this device only. Cloud sync is unavailable.');
        return;
      }

      if (!mounted) return;
      setState(() {
        _isUploading = true;
        _message = null;
      });

      try {
        final ref = storage.ref().child('users/${user.uid}/profile_photo.jpg');
        final snapshot = await ref.putData(
          bytes,
          SettableMetadata(contentType: 'image/jpeg'),
        );
        final downloadUrl = await snapshot.ref.getDownloadURL();
        await user.updatePhotoURL(downloadUrl);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_photoUrlKey, downloadUrl);

        if (!mounted) return;
        setState(() {
          _photoUrl = downloadUrl;
          _photoBase64 = null;
          _isUploading = false;
        });
        _setMessage('Profile photo updated');
        _showSnack('Profile photo uploaded to your account.');
      } catch (e) {
        if (!mounted) return;
        setState(() => _isUploading = false);
        _setMessage('Failed to upload photo: $e', isError: true);
        _showSnack('Failed to upload photo', isError: true);
      }
    } catch (e) {
      _setMessage('Failed to read the selected image', isError: true);
      _showSnack('Failed to read the selected image', isError: true);
    }
  }

  Future<void> _changePassword() async {
    final newPass = _newPasswordController.text.trim();
    final confirm = _confirmPasswordController.text.trim();

    if (newPass.isEmpty || confirm.isEmpty) {
      setState(() => _message = 'Please fill all password fields');
      return;
    }
    if (newPass != confirm) {
      setState(() => _message = 'New passwords do not match');
      return;
    }
    if (newPass.length < 6) {
      setState(() => _message = 'Password must be at least 6 characters');
      return;
    }

    setState(() {
      _isLoading = true;
      _message = null;
    });

    try {
      final user = safeAuth?.currentUser;
      if (user != null) {
        await user.updatePassword(newPass);
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _message = 'Password changed successfully';
        });
        _newPasswordController.clear();
        _confirmPasswordController.clear();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Password updated successfully'),
              backgroundColor: AppTheme.successGreen,
            ),
          );
        }
      } else {
        setState(() {
          _isLoading = false;
          _message = 'No active user found. Please login again.';
        });
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        if (e.code == 'requires-recent-login') {
          _message = 'For security, please log out and log in again before changing password.';
        } else {
          _message = 'Failed to update password: ${e.message}';
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _message = 'An unexpected error occurred.';
      });
    }
  }

  Future<void> _saveProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_nameKey, _nameController.text.trim());
    _setMessage('Profile saved');
    _showSnack('Profile saved');
  }

  Widget _buildAvatarShell(Widget child) {
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
      child: ClipOval(child: child),
    );
  }

  Widget _buildPhotoPlaceholder() {
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

  Widget _buildLegacyPhoto() {
    final base64 = _photoBase64;
    if (base64 == null) return _buildPhotoPlaceholder();
    try {
      final bytes = base64Decode(base64);
      return _buildAvatarShell(
        Image.memory(bytes, width: 120, height: 120, fit: BoxFit.cover),
      );
    } catch (_) {
      return _buildPhotoPlaceholder();
    }
  }

  Widget _buildPhotoPreview() {
    final url = _photoUrl;
    if (url == null || url.isEmpty) return _buildLegacyPhoto();

    return _buildAvatarShell(
      Image.network(
        url,
        width: 120,
        height: 120,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Container(
            color: AppTheme.lightGray,
            child: const Center(
              child: SizedBox(
                width: 26,
                height: 26,
                child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryBlue),
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) => _buildLegacyPhoto(),
      ),
    );
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
                    onPressed: _isUploading
                        ? null
                        : () => _pickImage(
                              _canUseCamera ? ImageSource.camera : ImageSource.gallery,
                            ),
                    icon: _isUploading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.pureWhite),
                          )
                        : Icon(_canUseCamera ? Icons.camera_alt_rounded : Icons.upload_rounded),
                    label: Text(
                      _isUploading
                          ? 'Uploading...'
                          : _canUseCamera
                              ? 'Take Photo'
                              : 'Upload Photo',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      foregroundColor: AppTheme.pureWhite,
                    ),
                  ),
                  if (_canUseCamera)
                    TextButton.icon(
                      onPressed: _isUploading
                          ? null
                          : () => _pickImage(ImageSource.gallery),
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
                  color: (_messageIsError ? AppTheme.dangerRed : AppTheme.successGreen)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: (_messageIsError ? AppTheme.dangerRed : AppTheme.successGreen)
                        .withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  _message!,
                  style: TextStyle(
                    color: _messageIsError ? AppTheme.dangerRed : AppTheme.successGreen,
                    fontWeight: FontWeight.w600,
                  ),
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
              'Password must be at least 6 characters.',
              style: TextStyle(fontSize: 12, color: AppTheme.slateText, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
