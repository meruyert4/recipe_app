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

  String? avatarUrl;
  bool isLoading = false;

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

  Future<void> _saveChanges() async {
    final userId = widget.user?.uid;
    final username = _usernameController.text.trim();
    final avatarLink = _avatarUrlController.text.trim();

    if (userId != null && username.isNotEmpty && avatarLink.isNotEmpty) {
      await FirebaseDatabase.instance.ref('users/$userId/username').set(username);
      await FirebaseDatabase.instance.ref('users/$userId/avatar').set(avatarLink);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageWidget = avatarUrl != null
        ? Image.network(avatarUrl!, fit: BoxFit.cover)
        : Image.network(
            'https://i.pinimg.com/474x/34/95/ee/3495ee40657be72a6e7ef766a1ddc303.jpg',
            fit: BoxFit.cover,
          );

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
                hintText: 'Paste public image URL (e.g., from Unsplash)',
              ),
              onChanged: (value) {
                setState(() {
                  avatarUrl = value.trim();
                });
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _saveChanges,
              icon: const Icon(Icons.save),
              label: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
