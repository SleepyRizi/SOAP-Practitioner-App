// SETTINGS VIEW (Updated as requested)
// Requires:
//   image_picker: ^1.x
//   firebase_storage: ^12.4.10   // ← matches firebase_core ^3.15.2
// If you upgrade to firebase_core ^4, use firebase_storage ^13.x instead.
// Ensure Firebase is initialized in your main() and AuthService exposes
// currentUser, login, resetPasswordOnServer, logout.

import 'dart:io' show File; // Remove this import for Flutter Web builds.
import 'dart:typed_data';

import 'package:flutter/foundation.dart'; // kIsWeb
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // MissingPluginException
import 'package:get/get.dart';
import 'package:intl/intl.dart';

// Image picking + Firebase Storage
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../Services/auth_service.dart';
import '../Common/bottom_bar.dart';

const double _kCardWidth = 770;
const double _kCardRadius = 40;
const double _kMainCardBottomSpacer = 581; // ~15% taller than previous 505

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final nowStr = DateFormat('EEEE, MMM d, yyyy').format(DateTime.now());
    final scrW = MediaQuery.of(context).size.width;
    final isTab = scrW > 600;
    final titleSz = isTab ? 42.5 : 34.0;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFDFF),
      appBar: AppBar(
        toolbarHeight: isTab ? 100 : 86,
        backgroundColor: const Color(0xFFFAFDFF),
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 32,
        title: Text(
          'Settings',
          style: TextStyle(
            fontFamily: 'Cormorant Garamond',
            fontSize: titleSz,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 18),
              child: Text(
                nowStr,
                style: TextStyle(
                  fontFamily: 'Avenir',
                  fontSize: isTab ? 20 : 16,
                  fontWeight: FontWeight.w300,
                  color: const Color(0xFF696969),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 834),
            child: Column(
              children: const [
                _MainSettingsCard(),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const AppBottomBar(current: BottomTab.settings),
    );
  }
}

/* ─────────────────────────  MAIN SETTINGS CARD  ───────────────────────── */

class _MainSettingsCard extends StatelessWidget {
  const _MainSettingsCard();

  AuthService get _auth => Get.find<AuthService>();

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    final displayName = user?.displayName?.trim();
    final name = (displayName == null || displayName.isEmpty) ? 'Your Name' : displayName;

    return Container(
      width: _kCardWidth,
      padding: const EdgeInsets.all(30),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1, color: Color(0xFFE0E0E0)),
          borderRadius: BorderRadius.circular(_kCardRadius),
        ),
      ),
      child: Column(
        children: [
          // Top section with avatar/name and "View Profile"
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar + name + "View Profile"
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      // Avatar
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2D5661),
                          borderRadius: BorderRadius.circular(133.33),
                        ),
                        child: const Icon(Icons.person, color: Colors.white, size: 48),
                      ),
                      const SizedBox(width: 19),
                      Text(
                        name,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 24,
                          fontFamily: 'Avenir',
                          fontWeight: FontWeight.w500,
                          letterSpacing: -0.41,
                        ),
                      ),
                    ],
                  ),
                  InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const EditProfileView()),
                      );
                    },
                    child: Row(
                      children: const [
                        Text(
                          'View Profile',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontFamily: 'Avenir',
                            fontWeight: FontWeight.w500,
                            height: 1.10,
                            letterSpacing: -0.41,
                          ),
                        ),
                        SizedBox(width: 5),
                        Icon(Icons.chevron_right, color: Colors.black),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // Account Settings and Privacy row — NO BOX, only bottom divider
              InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AccountSettingsView()),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        'Account Settings and Privacy',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontFamily: 'Avenir',
                          fontWeight: FontWeight.w500,
                          height: 1.38,
                          letterSpacing: -0.41,
                        ),
                      ),
                      Icon(Icons.chevron_right, color: Colors.black),
                    ],
                  ),
                ),
              ),
              const Divider(color: Color(0xFFE0E0E0), height: 1, thickness: 1),
            ],
          ),

          // Keep card tall
          SizedBox(height: _kMainCardBottomSpacer),

          // Logout button
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(width: 1, color: Color(0xFFE0E0E0)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                    ),
                    onPressed: () async {
                      try {
                        await _auth.logout();
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Logout failed: $e')),
                          );
                        }
                      }
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        RotatedBox(
                          quarterTurns: 3,
                          child: Icon(Icons.logout, color: Colors.black, size: 20),
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Log Out',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontFamily: 'Avenir',
                            fontWeight: FontWeight.w500,
                            height: 1.38,
                            letterSpacing: -0.41,
                          ),
                        ),
                      ],
                    ),
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

/* ─────────────────────────  VIEW PROFILE  ───────────────────────── */

class EditProfileView extends StatefulWidget {
  const EditProfileView({super.key});

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  final _nameCtrl = TextEditingController();
  Uint8List? _photoPreview; // local preview
  bool _saving = false;
  bool _photoUploading = false;
  bool _editingName = false;

  final _picker = ImagePicker();
  AuthService get _auth => Get.find<AuthService>();

  @override
  void initState() {
    super.initState();
    final user = _auth.currentUser;
    _nameCtrl.text = user?.displayName ?? '';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadPhoto() async {
    try {
      setState(() => _photoUploading = true);
      final user = _auth.currentUser;
      if (user == null) throw Exception('Not signed in.');

      final XFile? picked = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        imageQuality: 85,
      );
      if (picked == null) return;

      // Local preview
      final bytes = await picked.readAsBytes();
      setState(() => _photoPreview = bytes);

      final ref = FirebaseStorage.instance.ref('user_photos/${user.uid}.jpg');

      if (kIsWeb) {
        await ref.putData(
          bytes,
          SettableMetadata(contentType: 'image/jpeg'),
        );
      } else {
        await ref.putFile(
          File(picked.path),
          SettableMetadata(contentType: 'image/jpeg'),
        );
      }

      final url = await ref.getDownloadURL();
      await user.updatePhotoURL(url);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile photo updated')),
        );
      }
    } on MissingPluginException catch (_) {
      if (!mounted) return;
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Plugin not ready'),
          content: const Text(
            'Image picking/storage plugin isn’t loaded yet. '
                'If you just added the plugin, do a full rebuild:\n\n'
                '• flutter clean\n• flutter pub get\n• (iOS) pod install\n• flutter run',
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('OK')),
          ],
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Photo update failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _photoUploading = false);
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('Not signed in.');
      final newName = _nameCtrl.text.trim();
      if (_editingName && newName.isNotEmpty && newName != (user.displayName ?? '')) {
        await user.updateDisplayName(newName);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated')),
        );
      }
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFDFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAFDFF),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black), // back arrow
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.black,
            fontFamily: 'Cormorant Garamond',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _kCardWidth),
            child: Container(
              padding: const EdgeInsets.all(30),
              decoration: ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  side: const BorderSide(width: 1, color: Color(0xFFE0E0E0)),
                  borderRadius: BorderRadius.circular(_kCardRadius),
                ),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final halfW = constraints.maxWidth * 0.5;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Avatar + "Profile Photo" + "Change"
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: const Color(0xFF2D5661),
                            backgroundImage: _photoPreview != null ? MemoryImage(_photoPreview!) : null,
                            child: _photoPreview == null
                                ? const Icon(Icons.person, color: Colors.white, size: 48)
                                : null,
                          ),
                          const SizedBox(width: 19),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Profile Photo',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 24,
                                  fontFamily: 'Avenir',
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: -0.41,
                                ),
                              ),
                              const SizedBox(height: 6),
                              TextButton.icon(
                                onPressed: _photoUploading ? null : _pickAndUploadPhoto,
                                icon: const Icon(Icons.edit_outlined, size: 18, color: Colors.black),
                                label: Text(
                                  _photoUploading ? 'Uploading…' : 'Change',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontFamily: 'Avenir',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.black,
                                  padding: EdgeInsets.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),

                      // Full Name (view + pencil -> 50% width text field)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const _LabeledTop('Full Name'),
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, color: Colors.black),
                            tooltip: 'Edit name',
                            onPressed: () => setState(() => _editingName = !_editingName),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      if (_editingName)
                        SizedBox(
                          width: halfW,
                          child: _BoxField(
                            controller: _nameCtrl,
                            hintText: 'Enter full name',
                          ),
                        )
                      else
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            _nameCtrl.text.isEmpty ? 'Your Name' : _nameCtrl.text,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontFamily: 'Avenir',
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ),

                      // Keep card tall (match main)
                      SizedBox(height: _kMainCardBottomSpacer),

                      Row(
                        children: [
                          Expanded(
                            child: _outlinePillButton(
                              label: 'Cancel',
                              onPressed: _saving
                                  ? null
                                  : () {
                                Navigator.of(context).maybePop();
                              },
                            ),
                          ),
                          const SizedBox(width: 19),
                          Expanded(
                            child: _solidPillButton(
                              label: _saving ? 'Saving…' : 'Save',
                              onPressed: _saving ? null : _save,
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/* ─────────────────────  ACCOUNT SETTINGS & PRIVACY  ───────────────────── */

class AccountSettingsView extends StatefulWidget {
  const AccountSettingsView({super.key});

  @override
  State<AccountSettingsView> createState() => _AccountSettingsViewState();
}

class _AccountSettingsViewState extends State<AccountSettingsView> {
  final _emailCtrl = TextEditingController();
  final _currentPwCtrl = TextEditingController();
  final _newPwCtrl = TextEditingController();
  final _confirmPwCtrl = TextEditingController();

  AuthService get _auth => Get.find<AuthService>();

  bool _saving = false;
  String? _pwError;
  bool _editingPassword = false;

  @override
  void initState() {
    super.initState();
    _emailCtrl.text = _auth.currentUser?.email ?? '';
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _currentPwCtrl.dispose();
    _newPwCtrl.dispose();
    _confirmPwCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _pwError = null;
    });

    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('Not signed in.');

      if (_editingPassword) {
        final current = _currentPwCtrl.text;
        final next = _newPwCtrl.text;
        final confirm = _confirmPwCtrl.text;

        if (next.length < 6) {
          setState(() => _pwError = 'Password must be at least 6 characters.');
          return;
        }
        if (next != confirm) {
          setState(() => _pwError = 'Passwords do not match.');
          return;
        }

        final email = user.email;
        if (email == null) throw Exception('No email on account.');
        await _auth.login(email, current);
        await _auth.resetPasswordOnServer(email: email, newPassword: next);
        _currentPwCtrl.clear();
        _newPwCtrl.clear();
        _confirmPwCtrl.clear();
        setState(() => _editingPassword = false);

        if (!mounted) return;
        await showDialog(
          context: context,
          builder: (_) => Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            child: Container(
              padding: const EdgeInsets.all(24),
              width: 420,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(24)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle, color: Color(0xFF2D5661), size: 64),
                  const SizedBox(height: 16),
                  const Text(
                    'Password changed successfully!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 22,
                      fontFamily: 'Cormorant Garamond',
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2D5661),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Ok'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Settings saved')),
        );
        Navigator.of(context).pop();
      }
    } on MissingPluginException catch (_) {
      if (!mounted) return;
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Plugin not ready'),
          content: const Text(
            'A native plugin (e.g., Firebase or image picker) isn’t loaded. '
                'Do a full rebuild:\n\n• flutter clean\n• flutter pub get\n• (iOS) pod install\n• flutter run',
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('OK')),
          ],
        ),
      );
    } catch (e) {
      setState(() => _pwError ??= 'Incorrect password');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFDFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAFDFF),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black), // back arrow
        title: const Text(
          'Account Settings & Privacy',
          style: TextStyle(
            color: Colors.black,
            fontFamily: 'Cormorant Garamond',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _kCardWidth),
            child: Container(
              padding: const EdgeInsets.all(30),
              decoration: ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  side: const BorderSide(width: 1, color: Color(0xFFE0E0E0)),
                  borderRadius: BorderRadius.circular(_kCardRadius),
                ),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final halfW = constraints.maxWidth * 0.5;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title (no gear icon)
                      const Text(
                        'Account Settings and Privacy',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 24,
                          fontFamily: 'Avenir',
                          fontWeight: FontWeight.w500,
                          height: 0.92,
                          letterSpacing: -0.41,
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Email (read-only, 50% width)
                      const _LabeledTop('Email'),
                      const SizedBox(height: 4),
                      SizedBox(
                        width: halfW,
                        child: _BoxField(
                          controller: _emailCtrl,
                          hintText: 'name@example.com',
                          keyboardType: TextInputType.emailAddress,
                          readOnly: true,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Password row (masked) with pencil (50% width)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const _LabeledTop('Password'),
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, color: Colors.black),
                            tooltip: 'Change password',
                            onPressed: () => setState(() => _editingPassword = !_editingPassword),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      if (!_editingPassword)
                        SizedBox(
                          width: halfW,
                          child: Container(
                            height: 52,
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            decoration: ShapeDecoration(
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                side: const BorderSide(width: 1, color: Color(0xFFE0E0E0)),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            alignment: Alignment.centerLeft,
                            child: const Text(
                              '*************',
                              style: TextStyle(
                                color: Colors.black,
                                fontFamily: 'Avenir',
                                fontSize: 16,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ),
                        )
                      else ...[
                        SizedBox(
                          width: halfW,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const _LabeledTop('Current Password'),
                              const SizedBox(height: 4),
                              _BoxField(controller: _currentPwCtrl, hintText: '*************', obscure: true),
                              if (_pwError != null) ...[
                                const SizedBox(height: 6),
                                Text(
                                  _pwError!,
                                  style: const TextStyle(
                                    color: Color(0xFFEE3B3B),
                                    fontSize: 14,
                                    fontFamily: 'Avenir',
                                    fontWeight: FontWeight.w500,
                                    height: 1.57,
                                    letterSpacing: -0.41,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 16),
                              const _LabeledTop('New Password'),
                              const SizedBox(height: 4),
                              _BoxField(controller: _newPwCtrl, hintText: '*************', obscure: true),
                              const SizedBox(height: 16),
                              const _LabeledTop('Confirm Password'),
                              const SizedBox(height: 4),
                              _BoxField(controller: _confirmPwCtrl, hintText: '*************', obscure: true),
                            ],
                          ),
                        ),
                      ],

                      // Keep card tall (match main)
                      SizedBox(height: _kMainCardBottomSpacer),

                      Row(
                        children: [
                          Expanded(
                            child: _outlinePillButton(
                              label: 'Cancel',
                              onPressed: _saving
                                  ? null
                                  : () {
                                Navigator.of(context).maybePop();
                              },
                            ),
                          ),
                          const SizedBox(width: 19),
                          Expanded(
                            child: _solidPillButton(
                              label: _saving ? 'Saving…' : 'Save',
                              onPressed: _saving ? null : _save,
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/* ─────────────────────────  SHARED UI ATOMS  ───────────────────────── */

class _LabeledTop extends StatelessWidget {
  const _LabeledTop(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 330,
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 16,
          fontFamily: 'Avenir',
          fontWeight: FontWeight.w500,
          height: 1.38,
          letterSpacing: -0.41,
        ),
      ),
    );
  }
}

class _BoxField extends StatelessWidget {
  const _BoxField({
    required this.controller,
    required this.hintText,
    this.obscure = false,
    this.keyboardType,
    this.readOnly = false,
  });

  final TextEditingController controller;
  final String hintText;
  final bool obscure;
  final TextInputType? keyboardType;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1, color: Color(0xFFE0E0E0)),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscure,
        readOnly: readOnly,
        textAlignVertical: TextAlignVertical.center, // vertically center text
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
            color: Color(0xFF696969),
            fontFamily: 'Avenir',
            fontSize: 16,
            fontWeight: FontWeight.w300,
          ),
          border: InputBorder.none,
          // Center the text within 52px height
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
        style: const TextStyle(
          color: Colors.black,
          fontFamily: 'Avenir',
          fontSize: 16,
          fontWeight: FontWeight.w300,
        ),
      ),
    );
  }
}

Widget _solidPillButton({required String label, VoidCallback? onPressed}) {
  return SizedBox(
    height: 52,
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF2D5661),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
      ),
      onPressed: onPressed,
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontFamily: 'Avenir',
          fontWeight: FontWeight.w500,
          height: 1.38,
          letterSpacing: -0.41,
        ),
      ),
    ),
  );
}

Widget _outlinePillButton({required String label, VoidCallback? onPressed}) {
  return SizedBox(
    height: 52,
    child: OutlinedButton(
      style: OutlinedButton.styleFrom(
        side: const BorderSide(width: 1, color: Color(0xFFE0E0E0)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
      ),
      onPressed: onPressed,
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 16,
          fontFamily: 'Avenir',
          fontWeight: FontWeight.w500,
          height: 1.38,
          letterSpacing: -0.41,
        ),
      ),
    ),
  );
}
