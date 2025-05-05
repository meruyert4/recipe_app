import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:unicons/unicons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'edit_profile_screen.dart';
import 'package:recipe_app/screens/screens.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    // Get the current theme's scaffold background color
    final isDarkMode = Theme.of(context).scaffoldBackgroundColor == const Color(0xFF121212);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 6.0.h),
              Text(
                AppLocalizations.of(context)!.profile,
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
              ),
              SizedBox(height: 4.0.h),
              ProfileHeader(user: user, isDarkMode: isDarkMode),
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
  final bool isDarkMode;

  const ProfileHeader({Key? key, this.user, required this.isDarkMode}) : super(key: key);

  @override
  State<ProfileHeader> createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends State<ProfileHeader> {
  String? avatarUrl;
  String? username;
  bool isLoading = true;

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
        username = usernameSnapshot.exists ? usernameSnapshot.value as String : widget.user?.displayName ?? 'User Name';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageWidget = avatarUrl != null && avatarUrl!.isNotEmpty
        ? Image.network(avatarUrl!, fit: BoxFit.cover)
        : Image.network(
            'https://i.pinimg.com/474x/34/95/ee/3495ee40657be72a6e7ef766a1ddc303.jpg',
            fit: BoxFit.cover,
          );

    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
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
          const SizedBox(height: 10.0),
          Text(
            username ?? AppLocalizations.of(context)!.userName,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: widget.isDarkMode ? Colors.white : Colors.black,
                ),
          ),
          const SizedBox(height: 5.0),
          Text(
            widget.user?.email ?? AppLocalizations.of(context)!.email,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: widget.isDarkMode ? Colors.white70 : Colors.black87,
                ),
          ),
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
    // Get the current theme's scaffold background color
    final isDarkMode = Theme.of(context).scaffoldBackgroundColor == const Color(0xFF121212);

    return ListTile(
      title: Text(
        text,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
      ),
      horizontalTitleGap: 5.0,
      leading: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Icon(icon, color: Theme.of(context).iconTheme.color),
      ),
      trailing: Icon(UniconsLine.angle_right,
          size: 24.0.sp, color: Theme.of(context).iconTheme.color),
      onTap: onTapAction ?? () {},
    );
  }
}

class ProfileListView extends StatelessWidget {
  const ProfileListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get the current theme's scaffold background color
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.55,
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 20.0),
        children: [
          ProfileListTile(
            text: AppLocalizations.of(context)!.account,
            icon: UniconsLine.user_circle,
            onTapAction: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => EditProfileScreen(
                        user: FirebaseAuth.instance.currentUser)),
              );
            },
          ),
          Divider(color: Colors.grey.shade400, indent: 10.0, endIndent: 10.0),
          ProfileListTile(
            text: AppLocalizations.of(context)!.settings,
            icon: UniconsLine.setting,
            onTapAction: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
          Divider(color: Colors.grey.shade400, indent: 10.0, endIndent: 10.0),
          ProfileListTile(
            text: AppLocalizations.of(context)!.about,
            icon: UniconsLine.info_circle,
            onTapAction: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AppInfoScreen()),
              );
            },
          ),
          Divider(color: Colors.grey.shade400, indent: 10.0, endIndent: 10.0),
          ProfileListTile(
            text: AppLocalizations.of(context)!.logout,
            icon: UniconsLine.sign_out_alt,
            onTapAction: () async {
              await FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
    );
  }
}
