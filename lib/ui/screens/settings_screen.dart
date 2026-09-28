import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../providers/security_provider.dart';
import '../../providers/theme_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _uploading = false;
  late Future<Map<String, dynamic>?> _profileFuture;

  User? get _user => FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _profileFuture = _getProfile();
  }

  /// Re-fetches the profile only when it actually changed.
  void _reloadProfile() {
    if (mounted) setState(() => _profileFuture = _getProfile());
  }

  Future<void> _toggleBiometric(SecurityProvider security, bool enabled) async {
    final ok = await security.setBiometricEnabled(enabled);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Could not enable Biometric Lock. Make sure a fingerprint, face or screen lock is set up.')));
    }
  }

  // --------------------------------------------------
  // Profile helpers
  // --------------------------------------------------

  Future<Map<String, dynamic>?> _getProfile() async {
    if (_user == null) return null;
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(_user!.uid)
        .get();
    return doc.data();
  }

  void _showEditProfileDialog(Map<String, dynamic>? profile) {
    final nameCtrl = TextEditingController(text: profile?['displayName'] ?? _user?.displayName ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(ctx).cardColor,
        title: Text('Edit Profile',
            style: TextStyle(color: Theme.of(ctx).textTheme.bodyLarge?.color)),
        content: TextField(
          controller: nameCtrl,
          style: TextStyle(color: Theme.of(ctx).textTheme.bodyLarge?.color),
          decoration: InputDecoration(
            labelText: 'Display Name',
            prefixIcon: const Icon(Icons.person_outline),
            filled: true,
            fillColor: Theme.of(ctx).scaffoldBackgroundColor,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
            onPressed: () async {
              final name = nameCtrl.text.trim();
              if (name.isEmpty) return;
              Navigator.pop(ctx);
              try {
                await _user!.updateDisplayName(name);
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(_user!.uid)
                    .set({'displayName': name}, SetOptions(merge: true));
                _reloadProfile();
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              }
            },
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _pickAndUploadPhoto() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(
        source: ImageSource.gallery, imageQuality: 80, maxWidth: 512);
    if (image == null) return;

    setState(() => _uploading = true);
    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('profile_photos/${_user!.uid}.jpg');
      await ref.putFile(
          File(image.path), SettableMetadata(contentType: 'image/jpeg'));
      final url = await ref.getDownloadURL();

      await _user!.updatePhotoURL(url);
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_user!.uid)
          .set({'photoURL': url}, SetOptions(merge: true));

      _reloadProfile();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Upload failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  // --------------------------------------------------
  // Build
  // --------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final security = Provider.of<SecurityProvider>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Settings',
            style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge?.color,
                fontWeight: FontWeight.bold,
                fontSize: 28)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // ── Profile Card ──────────────────────────────────
          FutureBuilder<Map<String, dynamic>?>(
            future: _profileFuture,
            builder: (context, snap) {
              final profile = snap.data;
              final displayName = profile?['displayName'] ??
                  _user?.displayName ??
                  'Your Name';
              final email = _user?.email ?? '';
              final photoURL = profile?['photoURL'] ?? _user?.photoURL;

              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    // Avatar with upload overlay
                    GestureDetector(
                      onTap: _pickAndUploadPhoto,
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 34,
                            backgroundColor: AppTheme.primary.withOpacity(0.2),
                            backgroundImage: photoURL != null
                                ? NetworkImage(photoURL) as ImageProvider
                                : null,
                            child: photoURL == null
                                ? Text(
                                    displayName.isNotEmpty
                                        ? displayName[0].toUpperCase()
                                        : '?',
                                    style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.primary))
                                : null,
                          ),
                          if (_uploading)
                            Positioned.fill(
                              child: CircleAvatar(
                                backgroundColor: Colors.black45,
                                radius: 34,
                                child: const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                        color: Colors.white, strokeWidth: 2)),
                              ),
                            ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                  color: AppTheme.primary,
                                  shape: BoxShape.circle),
                              child: const Icon(Icons.camera_alt,
                                  size: 12, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(displayName,
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).textTheme.bodyLarge?.color)),
                          const SizedBox(height: 4),
                          Text(email,
                              style: const TextStyle(
                                  fontSize: 13, color: AppTheme.textSecondary)),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _showEditProfileDialog(profile),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                            color: AppTheme.tabActiveBg,
                            borderRadius: BorderRadius.circular(14)),
                        child: const Icon(Icons.edit_outlined,
                            color: AppTheme.primary, size: 20),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 32),

          // ── Security ──────────────────────────────────────
          const Text('SECURITY',
              style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2)),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(24)),
            child: Column(children: [
              _tile(Icons.fingerprint, 'Biometric Lock',
                  trailing: Switch(
                      value: security.biometricEnabled,
                      activeColor: AppTheme.primary,
                      onChanged: (v) => _toggleBiometric(security, v))),
              const Divider(height: 1, indent: 64, endIndent: 20),
              _tile(Icons.lock_reset, 'Change Password',
                  trailing: const Icon(Icons.chevron_right,
                      color: AppTheme.textSecondary),
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Feature coming soon.')))),
            ]),
          ),
          const SizedBox(height: 32),

          // ── Preferences ───────────────────────────────────
          const Text('PREFERENCES',
              style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2)),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(24)),
            child: _tile(Icons.dark_mode_outlined, 'Dark Mode',
                trailing: Switch(
                    value: themeProvider.isDarkMode,
                    activeColor: AppTheme.primary,
                    onChanged: (v) => themeProvider.toggleTheme(v))),
          ),
          const SizedBox(height: 32),

          // ── Log Out ────────────────────────────────────────
          Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFFECACA)),
            ),
            child: TextButton.icon(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
              },
              icon: const Icon(Icons.logout, color: Color(0xFFDC2626)),
              label: const Text('Log Out',
                  style: TextStyle(
                      color: Color(0xFFDC2626),
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _tile(IconData icon, String title, {Widget? trailing, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                  color: AppTheme.tabActiveBg, shape: BoxShape.circle),
              child: Icon(icon, color: AppTheme.primary, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
                child: Text(title,
                    style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).textTheme.bodyLarge?.color))),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }
}
