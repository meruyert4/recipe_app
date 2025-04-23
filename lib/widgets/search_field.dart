import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:unicons/unicons.dart';
import 'package:recipe_app/provider/recipe_provider.dart';
class SearchField extends StatefulWidget {
  const SearchField({Key? key}) : super(key: key);

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final recipeProvider = Provider.of<RecipeProvider>(context);
    final theme = Theme.of(context);

    return Material(
      elevation: 2.0,
      color: theme.cardColor,
      borderRadius: BorderRadius.circular(8.0),
      child: TextField(
        controller: _controller,
        style: theme.textTheme.bodyMedium,
        decoration: InputDecoration(
          filled: true,
          fillColor: theme.cardColor,
          isDense: true,
          prefixIcon: Icon(
            UniconsLine.search,
            color: theme.primaryColor,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              UniconsLine.multiply,
              color: _controller.text.isNotEmpty ? theme.primaryColor : Colors.grey,
            ),
            onPressed: () {
              _controller.clear();
              recipeProvider.searchRecipe('');
            },
          ),
          hintText: 'Search recipe here...',
          hintStyle: TextStyle(
            color: theme.brightness == Brightness.dark ? Colors.white70 : Colors.black54, // Ensure hintStyle color
            fontSize: 10.0.sp,
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(width: 1.0, color: theme.dividerColor),
            borderRadius: BorderRadius.circular(8.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(width: 1.0, color: theme.primaryColor),
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        onChanged: (value) {
          recipeProvider.searchRecipe(value.toLowerCase());
        },
      ),
    );
  }
}
