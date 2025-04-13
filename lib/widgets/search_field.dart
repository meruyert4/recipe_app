import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final recipeProvider = Provider.of<RecipeProvider>(context);
    return Material(
      elevation: 2.0,
      child: TextField(
        controller: _controller,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          isDense: true,
          prefixIcon: Icon(
            UniconsLine.search, 
            color: Theme.of(context).primaryColor,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              UniconsLine.multiply,
              color: _controller.text.isNotEmpty ? Theme.of(context).primaryColor : Colors.grey,
            ),
            onPressed: () {
              _controller.clear();
              recipeProvider.searchRecipe(''); // Clear search when clearing text
            },
          ),
          hintText: 'Search recipe here...',
          hintStyle: Theme.of(context).textTheme.bodyMedium,
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(width: 1.0, color: Colors.white),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              width: 1.0,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
        onChanged: (value) {
          recipeProvider.searchRecipe(value.toLowerCase());
        },
      ),
    );
  }
}
