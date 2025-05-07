import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:sizer/sizer.dart';

class AppInfoScreen extends StatefulWidget {

  const AppInfoScreen({Key? key}) : super(key: key);
  

  @override
  State<AppInfoScreen> createState() => _AppInfoScreenState();
}

class _AppInfoScreenState extends State<AppInfoScreen> {
  String? avatarUrl;
  String? username;
  String? email;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid;

    if (userId != null) {
      final avatarRef = FirebaseDatabase.instance.ref('users/$userId/avatar');
      final usernameRef = FirebaseDatabase.instance.ref('users/$userId/username');

      final avatarSnapshot = await avatarRef.get();
      final usernameSnapshot = await usernameRef.get();

      setState(() {
        avatarUrl = avatarSnapshot.exists ? avatarSnapshot.value as String? : null;
        username = usernameSnapshot.exists ? usernameSnapshot.value as String : user?.displayName ?? 'User Name';
        email = user?.email;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).scaffoldBackgroundColor == const Color(0xFF121212);

    return Scaffold(
      appBar: AppBar(
        title: Text('App Info', style: Theme.of(context).textTheme.displayLarge),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: Theme.of(context).iconTheme.color),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: Container(
                padding: EdgeInsets.all(5.w),
                margin: EdgeInsets.symmetric(horizontal: 5.w),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: isDarkMode ? Colors.black54 : Colors.grey.shade300,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ClipOval(
                      child: SizedBox(
                        height: 20.0.h,
                        width: 20.0.h,
                        child: (avatarUrl != null && avatarUrl!.isNotEmpty)
                            ? Image.network(avatarUrl!, fit: BoxFit.cover)
                            : Image.network(
                                'https://i.pinimg.com/474x/34/95/ee/3495ee40657be72a6e7ef766a1ddc303.jpg',
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      username ?? 'User Name',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      email ?? 'Email not available',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: isDarkMode ? Colors.white70 : Colors.black87,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
