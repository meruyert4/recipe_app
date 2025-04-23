import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe_app/provider/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    final isDark = themeProvider.isDarkMode; // Directly from theme provider
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: theme.primaryColor,
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: Text(
              isDark ? 'Dark Mode' : 'Light Mode', // Change the title based on theme
              style: theme.textTheme.bodyLarge?.copyWith(
                color: isDark ? Colors.white : Colors.black, // Adjust text color based on theme
              ),
            ),
            value: themeProvider.isDarkMode,
            onChanged: themeProvider.toggleTheme,
            secondary: Icon(
              isDark ? Icons.nightlight_round : Icons.wb_sunny, // Moon icon for dark mode, Sun for light mode
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
