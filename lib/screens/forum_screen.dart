import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  ForumPost({
    required this.userId,
    required this.userAvatarUrl,
    required this.userName,
    required this.title,
    required this.content,
    required this.tags,
    required this.timestamp,
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

  factory ForumPost.fromJson(Map<String, dynamic> json) => ForumPost(
    userId: json['userId'],
    userAvatarUrl: json['userAvatarUrl'],
    userName: json['userName'],
    title: json['title'],
    content: json['content'],
    tags: List<String>.from(json['tags']),
    timestamp: DateTime.parse(json['timestamp']),
  );
}

class ForumScreen extends StatefulWidget {
  const ForumScreen({Key? key}) : super(key: key);

  @override
  State<ForumScreen> createState() => _ForumScreenState();
}

class _ForumScreenState extends State<ForumScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final List<ForumPost> _posts = [];
  bool _isLoading = true;
  User? _currentUser;
  String? _avatarUrl;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadPosts();
  }

  Future<void> _loadUserData() async {
    _currentUser = _auth.currentUser;
    if (_currentUser != null) {
      // In a real app, load avatar URL from Firebase Storage
      // _avatarUrl = await FirebaseStorage.instance.ref('avatars/${_currentUser!.uid}').getDownloadURL();
    }
  }

  Future<void> _loadPosts() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? savedPosts = prefs.getStringList('forum_posts');

    setState(() {
      _isLoading = false;
      if (savedPosts != null) {
        _posts.addAll(savedPosts.map((post) => ForumPost.fromJson(jsonDecode(post))));
      } else {
        // Add demo posts if none exist
        _posts.addAll([
          ForumPost(
            userId: 'demo1',
            userAvatarUrl: null,
            userName: 'ChefMaster',
            title: 'Cooking Tip',
            content: 'Always sharpen your knives before cooking!',
            tags: ['#cooking', '#tips'],
            timestamp: DateTime.now().subtract(Duration(hours: 2)),
          ),
          ForumPost(
            userId: 'demo2',
            userAvatarUrl: null,
            userName: 'BakingPro',
            title: 'Dough Secrets',
            content: 'Let your dough rest for at least 30 minutes.',
            tags: ['#baking'],
            timestamp: DateTime.now().subtract(Duration(hours: 5)),
          ),
        ]);
        _savePosts();
      }
    });
  }

  Future<void> _savePosts() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'forum_posts',
      _posts.map((post) => jsonEncode(post.toJson())).toList(),
    );
  }

  Future<void> _addPost(String title, String content, List<String> tags) async {
    if (_currentUser == null) return;

    final newPost = ForumPost(
      userId: _currentUser!.uid,
      userAvatarUrl: _avatarUrl,
      userName: _currentUser!.displayName ?? 'Anonymous',
      title: title,
      content: content,
      tags: tags,
      timestamp: DateTime.now(),
    );

    setState(() => _posts.insert(0, newPost));
    await _savePosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Community Forum')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: _posts.length,
              itemBuilder: (context, index) => _PostCard(post: _posts[index]),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateDialog(context),
        child: Icon(Icons.add),
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
        title: Text('Create Post'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_currentUser != null)
              ListTile(
                leading: CircleAvatar(
                  backgroundImage: _avatarUrl != null 
                      ? CachedNetworkImageProvider(_avatarUrl!) 
                      : null,
                  child: _avatarUrl == null 
                      ? Text(_currentUser!.displayName?[0] ?? '?') 
                      : null,
                ),
                title: Text(_currentUser!.displayName ?? 'User'),
              ),
            TextField(controller: titleController, decoration: InputDecoration(labelText: 'Title')),
            SizedBox(height: 16),
            TextField(
              controller: contentController,
              decoration: InputDecoration(labelText: 'Content'),
              maxLines: 3,
            ),
            SizedBox(height: 16),
            TextField(
              controller: tagsController,
              decoration: InputDecoration(
                labelText: 'Tags (comma separated)',
                hintText: '#cooking, #tips',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
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
            child: Text('Post'),
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
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: post.userAvatarUrl != null
                      ? CachedNetworkImageProvider(post.userAvatarUrl!)
                      : null,
                  child: post.userAvatarUrl == null
                      ? Text(post.userName[0])
                      : null,
                ),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(post.userName, style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(_formatTime(post.timestamp), style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(post.title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text(post.content),
            SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: post.tags.map((tag) => Chip(label: Text(tag))).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
