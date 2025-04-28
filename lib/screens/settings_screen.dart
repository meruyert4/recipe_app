import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe_app/provider/theme_provider.dart';
import 'package:recipe_app/provider/locale_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);

    final isDark = themeProvider.isDarkMode; // Directly from theme provider
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.settings),
        backgroundColor: theme.primaryColor,
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: Text(
              isDark
                ? AppLocalizations.of(context)!.darkMode
                : AppLocalizations.of(context)!.lightMode, // Change the title based on theme
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
          ListTile(
            title: Text(
              AppLocalizations.of(context)!.changeLanguage,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: isDark ? Colors.white : Colors.black, // Adjust text color based on theme
              ),
            ),
            trailing: const Icon(Icons.language),
            onTap: () {
              localeProvider.toggleLocale();
            },
          ), 
        ],
      ),
    );
  }
}
