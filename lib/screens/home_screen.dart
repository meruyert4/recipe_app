import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart' show Provider;
import '../services/auth_service.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipe App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
                onPressed: () => Provider.of<AuthService>(context, listen: false).signOut()
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (user != null) ...[
              if (user.photoURL != null)
                CircleAvatar(
                  backgroundImage: NetworkImage(user.photoURL!),
                  radius: 40,
                ),
              const SizedBox(height: 16),
              Text(
                'Welcome, ${user.displayName ?? user.email}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
            ],
            const Text('Your recipes will appear here'),
          ],
        ),
      ),
    );
  }
}