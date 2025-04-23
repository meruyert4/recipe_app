import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sizer/sizer.dart';

class EditProfileScreen extends StatefulWidget {
  final User? user;

  const EditProfileScreen({Key? key, this.user}) : super(key: key);

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  String? base64Image;
  final picker = ImagePicker();
  bool isLoading = false;
  final TextEditingController _usernameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _usernameController.text = widget.user?.displayName ?? '';
    _loadProfileImage();
  }

  Future<void> _loadProfileImage() async {
    final userId = widget.user?.uid;
    if (userId != null) {
      DatabaseReference ref = FirebaseDatabase.instance.ref('users/$userId/avatar');
      final snapshot = await ref.get();
      if (snapshot.exists) {
        setState(() {
          base64Image = snapshot.value as String?;
        });
      }
    }
  }

  Future<void> _pickAndUploadImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => isLoading = true);
      final bytes = await pickedFile.readAsBytes();
      final encoded = base64Encode(bytes);

      final userId = widget.user?.uid;
      if (userId != null) {
        DatabaseReference ref = FirebaseDatabase.instance.ref('users/$userId/avatar');
        await ref.set(encoded);
        setState(() {
          base64Image = encoded;
        });
      }
      setState(() => isLoading = false);
    }
  }

  Future<void> _updateUsername() async {
    final userId = widget.user?.uid;
    final newUsername = _usernameController.text.trim();
    if (userId != null && newUsername.isNotEmpty) {
      try {
        // Update in Realtime Database
        await FirebaseDatabase.instance.ref('users/$userId/username').set(newUsername);

        // Update FirebaseAuth profile
        await widget.user?.updateDisplayName(newUsername);
        await widget.user?.reload();

        // Refresh user state
        final updatedUser = FirebaseAuth.instance.currentUser;
        setState(() {
          _usernameController.text = updatedUser?.displayName ?? newUsername;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Username updated')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update username: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageWidget = base64Image != null
        ? Image.memory(base64Decode(base64Image!), fit: BoxFit.cover)
        : Image.network(
            'https://plus.unsplash.com/premium_photo-1682023585957-f191203ab239?w=900&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NXx8ZGVmYXVsdCUyMGF2YXRhcnxlbnwwfHwwfHx8MA%3D%3D',
            fit: BoxFit.cover,
          );

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: _pickAndUploadImage,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    ClipOval(
                      child: SizedBox(
                        height: 20.0.h,
                        width: 20.0.h,
                        child: isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : imageWidget,
                      ),
                    ),
                    Positioned(
                      bottom: 10,
                      right: 10,
                      child: Icon(Icons.camera_alt, size: 20.sp, color: Colors.white),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10.0),
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Username'),
              ),
              const SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: _updateUsername,
                child: const Text('Update Username'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
