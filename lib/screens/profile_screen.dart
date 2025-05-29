import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:unicons/unicons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'edit_profile_screen.dart';
import 'package:recipe_app/screens/screens.dart';
import 'package:recipe_app/screens/auth/login_screen.dart';
import 'package:recipe_app/screens/auth/auth.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final user = authService.getCurrentUser();
    final isGuest = authService.isGuest();
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 6.0.h),
              Text(
                'Profile',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
              ),
              SizedBox(height: 4.0.h),
              ProfileHeader(user: user, isDarkMode: isDarkMode, isGuest: isGuest),
              ProfileListView(isGuest: isGuest),
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
  final bool isGuest;

  const ProfileHeader({
    Key? key, 
    this.user, 
    required this.isDarkMode,
    required this.isGuest,
  }) : super(key: key);

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
    if (!widget.isGuest) {
      _loadProfileData();
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _loadProfileData() async {
    final userId = widget.user?.uid;
    if (userId != null) {
      try {
        final avatarRef = FirebaseDatabase.instance.ref('users/$userId/profileImage');
        final usernameRef = FirebaseDatabase.instance.ref('users/$userId/username');

        final avatarSnapshot = await avatarRef.get();
        final usernameSnapshot = await usernameRef.get();

        setState(() {
          avatarUrl = avatarSnapshot.exists ? avatarSnapshot.value as String? : null;
          username = usernameSnapshot.exists 
              ? usernameSnapshot.value as String 
              : widget.user?.displayName ?? 'User Name';
          isLoading = false;
        });
      } catch (e) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayName = widget.isGuest 
        ? 'Guest User' 
        : (username ?? 'User Name');
    
    final displayEmail = widget.isGuest 
        ? 'guest@example.com' 
        : (widget.user?.email ?? 'No email');

    final imageWidget = widget.isGuest
        ? Image.network(
            'https://i.pinimg.com/474x/34/95/ee/3495ee40657be72a6e7ef766a1ddc303.jpg',
            fit: BoxFit.cover,
          )
        : (avatarUrl != null && avatarUrl!.isNotEmpty
            ? Image.network(avatarUrl!, fit: BoxFit.cover)
            : Image.network(
                'https://i.pinimg.com/474x/34/95/ee/3495ee40657be72a6e7ef766a1ddc303.jpg',
                fit: BoxFit.cover,
              ));

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
            displayName,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: widget.isDarkMode ? Colors.white : Colors.black,
                ),
          ),
          const SizedBox(height: 5.0),
          Text(
            displayEmail,
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
  final bool isGuestAction;

  const ProfileListTile({
    Key? key,
    required this.text,
    required this.icon,
    this.onTapAction,
    this.isGuestAction = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

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
      onTap: () {
        if (isGuestAction) {
          _showGuestRestrictionMessage(context);
        } else {
          onTapAction?.call();
        }
      },
    );
  }

  void _showGuestRestrictionMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('This feature is not available for guest users'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
        ),
      ),
    );
  }
}

class ProfileListView extends StatelessWidget {
  final bool isGuest;

  const ProfileListView({Key? key, required this.isGuest}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.55,
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 20.0),
        children: [
          ProfileListTile(
            text: 'Account',
            icon: UniconsLine.user_circle,
            onTapAction: isGuest ? null : () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditProfileScreen(
                    user: user,
                  ),
                ),
              );
            },
            isGuestAction: isGuest,
          ),
          Divider(color: Colors.grey.shade400, indent: 10.0, endIndent: 10.0),
          ProfileListTile(
            text: 'Settings',
            icon: UniconsLine.setting,
            onTapAction: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          ),
          Divider(color: Colors.grey.shade400, indent: 10.0, endIndent: 10.0),
          ProfileListTile(
            text: 'About',
            icon: UniconsLine.info_circle,
            onTapAction: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AppInfoScreen(),
                ),
              );
            },
          ),
          Divider(color: Colors.grey.shade400, indent: 10.0, endIndent: 10.0),
          ProfileListTile(
            text: 'Logout',
            icon: UniconsLine.signout,
            onTapAction: () async {
              await AuthService().signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}
