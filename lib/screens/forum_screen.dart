import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class ForumScreen extends StatelessWidget {
  const ForumScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final forumPosts = [
      {
        'user': 'Darkhan',
        'avatar': '🧑‍🍳',
        'title': 'Kitchen Lifehack',
        'content': 'Use a binder clip to hold a sponge upright so it dries faster.',
        'tags': ['#lifehack', '#kitchen'],
        'time': '1h ago',
      },
      {
        'user': 'Dayana',
        'avatar': '👨‍💻',
        'title': 'Focus Tips',
        'content': 'Try the Pomodoro technique. 25 mins work, 5 mins break.',
        'tags': ['#productivity'],
        'time': '2h ago',
      },
      {
        'user': 'Khadisha',
        'avatar': '🧘‍♀️',
        'title': 'Stress Relief',
        'content': 'Breathing deeply for 5 mins helps more than you think!',
        'tags': ['#mentalhealth', '#wellbeing'],
        'time': '3h ago',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Community Forum'),
        elevation: 2,
      ),
      body: ListView.separated(
        padding: EdgeInsets.all(3.h),
        itemCount: forumPosts.length,
        separatorBuilder: (_, __) => SizedBox(height: 2.h),
        itemBuilder: (context, index) {
          final post = forumPosts[index];
          return Material(
            elevation: 2,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: EdgeInsets.all(2.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        child: Text(post['avatar']! as String),
                        radius: 22,
                        backgroundColor: Colors.grey.shade200,
                      ),
                      SizedBox(width: 2.h),
                      Text(
                        post['user']! as String,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      Text(
                        post['time']! as String,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  SizedBox(height: 1.5.h),
                  Text(
                    post['title']! as String,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    post['content']! as String,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  SizedBox(height: 1.5.h),
                  Wrap(
                    spacing: 8,
                    children: (post['tags']! as List<String>)
                        .map<Widget>(
                          (tag) => Chip(
                            label: Text(tag),
                            backgroundColor: Colors.green.shade50,
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Create Post clicked!')),
          );
        },
        label: const Text('Create Post'),
        icon: const Icon(Icons.edit),
      ),
    );
  }
}
