import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:recipe_app/models/recipe.dart';
import 'package:recipe_app/provider/saved_provider.dart';
import 'package:google_fonts/google_fonts.dart';

class RecipeDetailScreen extends StatefulWidget {
  const RecipeDetailScreen({Key? key}) : super(key: key);

  @override
  _RecipeDetailScreenState createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  bool _showInstructions = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 1, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    SchedulerBinding.instance.addPostFrameCallback((_) {
      _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _toggleInstructions() {
    setState(() {
      _showInstructions = !_showInstructions;
      if (_showInstructions) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final recipe = ModalRoute.of(context)!.settings.arguments as Recipe;
    final savedProvider = Provider.of<SavedProvider>(context);
    final isSaved = savedProvider.getSaved.containsKey(recipe.title);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Get colors from theme
    final primaryColor = Theme.of(context).primaryColor;
    final scaffoldBgColor = Theme.of(context).scaffoldBackgroundColor;
    final cardColor = Theme.of(context).cardColor;

    // Adaptive color palette
    final primaryTextColor = isDarkMode ? Colors.white : Colors.black87;
    final secondaryTextColor = isDarkMode ? Colors.white70 : Colors.grey[600]!;
    final accentColor = isDarkMode ? const Color(0xff00c2cb) : const Color(0xff084f57);
    final dividerColor = isDarkMode ? Colors.grey[800]! : Colors.grey[200]!;
    final cardBorderColor = isDarkMode ? Colors.grey[800]! : Colors.grey[200]!;
    final stepBgColor = isDarkMode ? const Color(0xFF262626) : Colors.grey[50]!;

    return Scaffold(
      backgroundColor: scaffoldBgColor,
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: CustomScrollView(
                controller: _scrollController,
                slivers: [
                  SliverAppBar(
                    expandedHeight: 280,
                    floating: false,
                    pinned: true,
                    backgroundColor: isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
                    elevation: isDarkMode ? 4.0 : 1.0,
                    flexibleSpace: FlexibleSpaceBar(
                      background: Hero(
                        tag: recipe.title,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.asset(
                              recipe.imageUrl,
                              fit: BoxFit.cover,
                            ),
                            // Overlay gradient for better text visibility
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: isDarkMode
                                      ? [
                                    Colors.black.withOpacity(0.2),
                                    Colors.black.withOpacity(0.7),
                                  ]
                                      : [
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.3),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    leading: IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isDarkMode ? Colors.black38 : Colors.white38,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.arrow_back,
                          color: isDarkMode ? Colors.white : Colors.black,
                          size: 20,
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    actions: [
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: IconButton(
                          icon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isDarkMode ? Colors.black38 : Colors.white38,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isSaved ? Icons.bookmark : Icons.bookmark_border,
                              color: isSaved
                                  ? accentColor
                                  : isDarkMode ? Colors.white : Colors.black,
                              size: 20,
                            ),
                          ),
                          onPressed: () {
                            savedProvider.addAndRemoveFromSaved(recipe);
                          },
                        ),
                      ),
                    ],
                  ),

                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title and rating
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Text(
                                  recipe.title,
                                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                    fontSize: 24,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: accentColor.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.star,
                                        color: accentColor, size: 18),
                                    const SizedBox(width: 4),
                                    Text(
                                      '4.8',
                                      style: TextStyle(
                                        color: accentColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 8),

                          // Meta info
                          Row(
                            children: [
                              Icon(Icons.timer,
                                  size: 18, color: secondaryTextColor),
                              const SizedBox(width: 4),
                              Text(
                                '${recipe.cookTime} min',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const SizedBox(width: 16),
                              Icon(Icons.restaurant,
                                  size: 18, color: secondaryTextColor),
                              const SizedBox(width: 4),
                              Text(
                                '2 servings',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // Tab selector
                          Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: isDarkMode
                                  ? [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                                  : null,
                              border: Border.all(
                                color: cardBorderColor,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => setState(() =>
                                    _showInstructions = false),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: !_showInstructions
                                            ? accentColor.withOpacity(0.2)
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        'Ingredients',
                                        style: TextStyle(
                                          color: !_showInstructions
                                              ? accentColor
                                              : secondaryTextColor,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => setState(() =>
                                    _showInstructions = true),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: _showInstructions
                                            ? accentColor.withOpacity(0.2)
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        'Instructions',
                                        style: TextStyle(
                                          color: _showInstructions
                                              ? accentColor
                                              : secondaryTextColor,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Content area
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: _showInstructions
                                ? _buildInstructions(recipe, primaryTextColor, accentColor, secondaryTextColor, isDarkMode, stepBgColor, cardBorderColor)
                                : _buildIngredients(recipe, primaryTextColor, accentColor, secondaryTextColor, isDarkMode, stepBgColor, cardBorderColor),
                          ),

                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildIngredients(Recipe recipe, Color textColor, Color accentColor, Color secondaryColor, bool isDarkMode, Color itemBgColor, Color borderColor) {
    final cardColor = isDarkMode ? const Color(0xFF1A1A1A) : Colors.grey[50]!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'You will need',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        ...recipe.ingredients.map((ingredient) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: cardColor, // Используем новый цвет
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: borderColor,
                width: 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 6, right: 12),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: accentColor,
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child: Text(
                    ingredient,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ],
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildInstructions(Recipe recipe, Color textColor, Color accentColor, Color secondaryColor, bool isDarkMode, Color itemBgColor, Color borderColor) {
    final cardColor = isDarkMode ? const Color(0xFF1A1A1A) : Colors.grey[50]!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Preparation steps',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        ...recipe.instructions.split('\n').asMap().entries.map((entry) {
          final int idx = entry.key;
          final String step = entry.value;

          return Container(
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardColor, // Используем новый цвет
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: borderColor,
                width: 1,
              ),
              boxShadow: isDarkMode
                  ? [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ]
                  : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 4, right: 12),
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${idx + 1}',
                    style: TextStyle(
                      color: accentColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    step,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }
}
