import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class EditProfileScreen extends StatefulWidget {
  final User? user;

  const EditProfileScreen({Key? key, this.user}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _avatarUrlController = TextEditingController();
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  String? avatarUrl;
  bool isLoading = false;
  bool _showPasswordFields = false;
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final userId = widget.user?.uid;
    if (userId != null) {
      final avatarRef = FirebaseDatabase.instance.ref('users/$userId/avatar');
      final usernameRef = FirebaseDatabase.instance.ref('users/$userId/username');

      final avatarSnapshot = await avatarRef.get();
      final usernameSnapshot = await usernameRef.get();

      setState(() {
        avatarUrl = avatarSnapshot.exists ? avatarSnapshot.value as String? : null;
        _avatarUrlController.text = avatarUrl ?? '';
        _usernameController.text = usernameSnapshot.exists
            ? usernameSnapshot.value as String
            : widget.user?.displayName ?? '';
      });
    }
  }

  Future<void> _saveProfileChanges() async {
    final userId = widget.user?.uid;
    final username = _usernameController.text.trim();
    final avatarLink = _avatarUrlController.text.trim();

    if (userId != null && username.isNotEmpty) {
      setState(() => isLoading = true);
      try {
        await FirebaseDatabase.instance.ref('users/$userId/username').set(username);
        if (avatarLink.isNotEmpty) {
          await FirebaseDatabase.instance.ref('users/$userId/avatar').set(avatarLink);
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: ${e.toString()}')),
        );
      } finally {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _changePassword() async {
    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('New passwords do not match')),
      );
      return;
    }

    if (_newPasswordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password must be at least 6 characters')),
      );
      return;
    }

    setState(() => isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      final cred = EmailAuthProvider.credential(
        email: user?.email ?? '',
        password: _currentPasswordController.text,
      );

      await user?.reauthenticateWithCredential(cred);
      await user?.updatePassword(_newPasswordController.text);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password changed successfully')),
      );

      // Clear password fields
      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
      setState(() => _showPasswordFields = false);
    } on FirebaseAuthException catch (e) {
      String message = 'Password change failed';
      if (e.code == 'wrong-password') {
        message = 'Current password is incorrect';
      } else if (e.code == 'weak-password') {
        message = 'Password is too weak';
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageWidget = avatarUrl != null && avatarUrl!.isNotEmpty
        ? Image.network(avatarUrl!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _defaultAvatar())
        : _defaultAvatar();

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Center(
              child: ClipOval(
                child: SizedBox(
                  height: 100,
                  width: 100,
                  child: imageWidget,
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _avatarUrlController,
              decoration: const InputDecoration(
                labelText: 'Avatar Image URL',
                border: OutlineInputBorder(),
                hintText: 'Paste public image URL',
              ),
              onChanged: (value) => setState(() => avatarUrl = value.trim()),
            ),

            // Password Change Section
            const SizedBox(height: 30),
            Row(
              children: [
                const Text('Change Password', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: Icon(_showPasswordFields ? Icons.arrow_drop_up : Icons.arrow_drop_down),
                  onPressed: () => setState(() => _showPasswordFields = !_showPasswordFields),
                ),
              ],
            ),
            if (_showPasswordFields) ...[
              const SizedBox(height: 10),
              TextField(
                controller: _currentPasswordController,
                obscureText: _obscureCurrentPassword,
                decoration: InputDecoration(
                  labelText: 'Current Password',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureCurrentPassword ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _obscureCurrentPassword = !_obscureCurrentPassword),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _newPasswordController,
                obscureText: _obscureNewPassword,
                decoration: InputDecoration(
                  labelText: 'New Password',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureNewPassword ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _obscureNewPassword = !_obscureNewPassword),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                decoration: InputDecoration(
                  labelText: 'Confirm New Password',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureConfirmPassword ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _changePassword,
                child: const Text('Update Password'),
              ),
              const SizedBox(height: 20),
            ],

            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: isLoading ? null : _saveProfileChanges,
              icon: isLoading
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.save),
              label: const Text('Save Profile Changes'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _defaultAvatar() {
    return Image.network(
      'https://i.pinimg.com/474x/34/95/ee/3495ee40657be72a6e7ef766a1ddc303.jpg',
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => const Icon(Icons.person, size: 50),
    );
  }
}
