import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';

class ForumPost {
  final String userId;
  final String? userAvatarUrl;
  final String userName;
  final String title;
  final String content;
  final List<String> tags;
  final DateTime timestamp;
  String? firebaseKey;

  ForumPost({
    required this.userId,
    required this.userAvatarUrl,
    required this.userName,
    required this.title,
    required this.content,
    required this.tags,
    required this.timestamp,
    this.firebaseKey,
  });

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'userAvatarUrl': userAvatarUrl,
        'userName': userName,
        'title': title,
        'content': content,
        'tags': tags,
        'timestamp': timestamp.toIso8601String(),
      };

  factory ForumPost.fromJson(Map<String, dynamic> json, {String? key}) => ForumPost(
        userId: json['userId'],
        userAvatarUrl: json['userAvatarUrl'],
        userName: json['userName'],
        title: json['title'],
        content: json['content'],
        tags: List<String>.from(json['tags']),
        timestamp: DateTime.parse(json['timestamp']),
        firebaseKey: key,
      );
}

class ForumScreen extends StatefulWidget {
  const ForumScreen({Key? key}) : super(key: key);

  @override
  State<ForumScreen> createState() => _ForumScreenState();
}

class _ForumScreenState extends State<ForumScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _postsRef = FirebaseDatabase.instance.ref().child('forum_posts');
  final List<ForumPost> _posts = [];
  bool _isLoading = true;
  User? _currentUser;
  String? _avatarUrl;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadPostsFromFirebase(); 
  }

  Future<void> _loadUserData() async {
    _currentUser = _auth.currentUser;
    if (_currentUser != null) {
      setState(() {});
    }
  }

  Future<void> _loadPostsFromFirebase() async {
    setState(() => _isLoading = true);
    try {
      final snapshot = await _postsRef.orderByChild('timestamp').once();
      final List<ForumPost> loadedPosts = [];
      if (snapshot.snapshot.value != null) {
        final Map<dynamic, dynamic> postsMap = snapshot.snapshot.value as Map<dynamic, dynamic>;
        postsMap.forEach((key, value) {
          loadedPosts.add(ForumPost.fromJson(Map<String, dynamic>.from(value as Map), key: key as String));
        });
        loadedPosts.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      }
      setState(() {
        _posts.clear();
        _posts.addAll(loadedPosts);
        _isLoading = false;
      });
    } catch (error) {
      setState(() => _isLoading = false);
      print("Error loading posts from Firebase: $error");
    }
  }

  Future<List<ForumPost>> _loadPostsFromSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? savedPostsJson = prefs.getStringList('forum_posts');
    final List<ForumPost> localPosts = [];

    if (savedPostsJson != null) {
      localPosts.addAll(savedPostsJson.map((post) => ForumPost.fromJson(jsonDecode(post))));
    } else {
       localPosts.addAll([
          ForumPost(
            userId: 'demo1',
            userAvatarUrl: null,
            userName: 'ChefMaster',
            title: 'Cooking Tip (Local)',
            content: 'Always sharpen your knives before cooking!',
            tags: ['#cooking', '#tips'],
            timestamp: DateTime.now().subtract(Duration(hours: 2)),
          ),
          ForumPost(
            userId: 'demo2',
            userAvatarUrl: null,
            userName: 'BakingPro (Local)',
            title: 'Dough Secrets',
            content: 'Let your dough rest for at least 30 minutes.',
            tags: ['#baking'],
            timestamp: DateTime.now().subtract(Duration(hours: 5)),
          ),
       ]);
    }
    return localPosts;
  }


  Future<void> _addPost(String title, String content, List<String> tags) async {
    if (_currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to post.')),
      );
      return;
    }

    final newPost = ForumPost(
      userId: _currentUser!.uid,
      userAvatarUrl: _avatarUrl,
      userName: _currentUser!.displayName ?? 'Anonymous',
      title: title,
      content: content,
      tags: tags,
      timestamp: DateTime.now(),
    );

    try {
      DatabaseReference newPostRef = _postsRef.push();
      await newPostRef.set(newPost.toJson());
      newPost.firebaseKey = newPostRef.key;

      setState(() => _posts.insert(0, newPost));
    } catch (error) {
      print("Error adding post to Firebase: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create post: $error')),
      );
    }
  }

  Future<void> _syncPostsToFirebase() async {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Starting synchronization...')),
    );
    setState(() => _isLoading = true);

    try {
      final List<ForumPost> localPosts = await _loadPostsFromSharedPreferences();
      if (localPosts.isEmpty) {
         ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No local posts to synchronize.')),
        );
        setState(() => _isLoading = false);
        return;
      }

      for (final post in localPosts) {
        final query = _postsRef.orderByChild('title').equalTo(post.title);
        final snapshot = await query.once();

        bool exists = false;
        if (snapshot.snapshot.value != null) {
            final Map<dynamic, dynamic> results = snapshot.snapshot.value as Map<dynamic, dynamic>;
            results.forEach((key, value) {
                if (value['userId'] == post.userId && value['content'] == post.content) {
                    exists = true;
                }
            });
        }

        if (!exists) {
            await _postsRef.push().set(post.toJson());
        } else {
            print("Post titled '${post.title}' by ${post.userName} already exists. Skipping.");
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Synchronization complete! Pull down to refresh.')),
      );
      await _loadPostsFromFirebase();
    } catch (error) {
      print("Error syncing posts to Firebase: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Synchronization failed: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Community Forum'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            tooltip: 'Sync with Firebase',
            onPressed: _isLoading ? null : _syncPostsToFirebase,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadPostsFromFirebase,
        child: _isLoading && _posts.isEmpty 
            ? const Center(child: CircularProgressIndicator())
            : _posts.isEmpty
                ? Center(
                    child: Text(
                      'No posts yet. Be the first to create one or pull down to refresh!',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _posts.length,
                    itemBuilder: (context, index) => _PostCard(post: _posts[index]),
                  ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _currentUser == null ? null : () => _showCreateDialog(context),
        tooltip: _currentUser == null ? 'Login to post' : 'Create Post',
        backgroundColor: _currentUser == null ? Colors.grey : Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.add),
      ),
    );
  }

 void _showCreateDialog(BuildContext context) {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    final tagsController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Post'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_currentUser != null)
                ListTile(
                  leading: CircleAvatar(
                    backgroundImage: _avatarUrl != null && _avatarUrl!.isNotEmpty
                        ? CachedNetworkImageProvider(_avatarUrl!)
                        : null,
                    child: _avatarUrl == null || _avatarUrl!.isEmpty
                        ? Text(_currentUser!.displayName?[0].toUpperCase() ?? '?')
                        : null,
                  ),
                  title: Text(_currentUser!.displayName ?? 'User'),
                ),
              TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Title')),
              const SizedBox(height: 16),
              TextField(
                controller: contentController,
                decoration: const InputDecoration(labelText: 'Content'),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: tagsController,
                decoration: const InputDecoration(
                  labelText: 'Tags (comma separated)',
                  hintText: '#cooking, #tips',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isEmpty || contentController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Title and content cannot be empty.')),
                );
                return;
              }
              final tags = tagsController.text
                  .split(',')
                  .map((t) => t.trim())
                  .where((t) => t.isNotEmpty)
                  .map((t) => t.startsWith('#') ? t : '#$t')
                  .toList();

              _addPost(
                titleController.text,
                contentController.text,
                tags,
              );
              Navigator.pop(context);
            },
            child: const Text('Post'),
          ),
        ],
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  final ForumPost post;

  const _PostCard({required this.post});

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${(diff.inDays / 7).floor()}w ago';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: post.userAvatarUrl != null && post.userAvatarUrl!.isNotEmpty
                      ? CachedNetworkImageProvider(post.userAvatarUrl!)
                      : null,
                  child: post.userAvatarUrl == null || post.userAvatarUrl!.isEmpty
                      ? Text(post.userName.isNotEmpty ? post.userName[0].toUpperCase() : '?')
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(post.userName, style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(_formatTime(post.timestamp), style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(post.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(post.content),
            const SizedBox(height: 12),
            if (post.tags.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: post.tags.map((tag) => Chip(
                  label: Text(tag, style: const TextStyle(fontSize: 12)),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                )).toList(),
              ),
          ],
        ),
      ),
    );
  }
}