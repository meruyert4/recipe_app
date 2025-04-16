import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:unicons/unicons.dart';
import 'package:recipe_app/widgets/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get the current user
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
              // ProfileHeader with dynamic user data
              ProfileHeader(
                imageUrl: user?.photoURL,
                userName: user?.displayName ?? 'User Name',
                userEmail: user?.email ?? 'Email not available',
              ),
              const ProfileListView(),
            ],
          ),
        ),
      ),
    );
  }
}


class ProfileHeader extends StatelessWidget {
  final String? imageUrl;
  final String userName;
  final String userEmail;

  const ProfileHeader({
    Key? key,
    this.imageUrl,
    required this.userName,
    required this.userEmail,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ProfileImage(
          height: 20.0.h,
          image: imageUrl ?? 'https://www.example.com/default-image.jpg',
        ),
        const SizedBox(height: 10.0),
        Text(userName, style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 5.0),
        Text(userEmail, style: Theme.of(context).textTheme.headlineSmall),
      ],
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
      onTap: onTapAction ?? () {}, // Use no-op function if onTapAction is null
    );
  }
}


class ProfileListView extends StatelessWidget {
  const ProfileListView({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.55,
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 20.0),
        children: [
          const ProfileListTile(
            text: 'Account',
            icon: UniconsLine.user_circle,
            onTapAction: null, // This will do nothing when tapped
          ),
          Divider(color: Colors.grey.shade400, indent: 10.0, endIndent: 10.0),
          const ProfileListTile(
            text: 'Settings',
            icon: UniconsLine.setting,
            onTapAction: null, // This will do nothing when tapped
          ),
          Divider(color: Colors.grey.shade400, indent: 10.0, endIndent: 10.0),
          const ProfileListTile(
            text: 'App Info',
            icon: UniconsLine.info_circle,
            onTapAction: null, // This will do nothing when tapped
          ),
          Divider(color: Colors.grey.shade400, indent: 10.0, endIndent: 10.0),
          ProfileListTile(
            text: 'Logout',
            icon: UniconsLine.sign_out_alt,
            onTapAction: () async {
              await FirebaseAuth.instance.signOut();
              // Navigate to the login screen or wherever appropriate
            },
          ),
        ],
      ),
    );
  }
}
