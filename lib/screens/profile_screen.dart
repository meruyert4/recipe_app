import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:unicons/unicons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:recipe_app/screens/edit_profile_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 6.0.h),
              Text('Profile', style: Theme.of(context).textTheme.displayLarge),
              SizedBox(height: 4.0.h),
              ProfileHeader(
                user: user,
              ),
              const ProfileListView(),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileHeader extends StatefulWidget {
  final User? user;

  const ProfileHeader({Key? key, this.user}) : super(key: key);

  @override
  State<ProfileHeader> createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends State<ProfileHeader> {
  String? base64Image;
  final picker = ImagePicker();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    final imageWidget = base64Image != null
        ? Image.memory(base64Decode(base64Image!), fit: BoxFit.cover)
        : Image.network(
            'https://plus.unsplash.com/premium_photo-1682023585957-f191203ab239?w=900&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NXx8ZGVmYXVsdCUyMGF2YXRhcnxlbnwwfHwwfHx8MA%3D%3D',
            fit: BoxFit.cover,
          );

    return Center(  // Wrap the column in a Center widget to center the contents
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,  // Align the contents centrally
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
          Text(widget.user?.displayName ?? 'User Name',
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 5.0),
          Text(widget.user?.email ?? 'Email not available',
              style: Theme.of(context).textTheme.headlineSmall),
        ],
      ),
    );
  }
}

class ProfileListTile extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback? onTapAction;

  const ProfileListTile({
    Key? key,
    required this.text,
    required this.icon,
    this.onTapAction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(text, style: Theme.of(context).textTheme.headlineSmall),
      horizontalTitleGap: 5.0,
      leading: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Icon(icon, color: Theme.of(context).iconTheme.color),
      ),
      trailing: Icon(
        UniconsLine.angle_right,
        size: 24.0.sp,
        color: Theme.of(context).iconTheme.color,
      ),
      onTap: onTapAction ?? () {},
    );
  }
}

class ProfileListView extends StatelessWidget {
  const ProfileListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.55,
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 20.0),
        children: [
          ProfileListTile(
            text: 'Account',
            icon: UniconsLine.user_circle,
            onTapAction: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EditProfileScreen(user: FirebaseAuth.instance.currentUser)),
              );
            },
          ),
          Divider(color: Colors.grey.shade400, indent: 10.0, endIndent: 10.0),
          const ProfileListTile(
            text: 'Settings',
            icon: UniconsLine.setting,
          ),
          Divider(color: Colors.grey.shade400, indent: 10.0, endIndent: 10.0),
          const ProfileListTile(
            text: 'App Info',
            icon: UniconsLine.info_circle,
          ),
          Divider(color: Colors.grey.shade400, indent: 10.0, endIndent: 10.0),
          ProfileListTile(
            text: 'Logout',
            icon: UniconsLine.sign_out_alt,
            onTapAction: () async {
              await FirebaseAuth.instance.signOut();
              // Navigate to login screen here if needed
            },
          ),
        ],
      ),
    );
  }
}
