import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => RecipeStore(),
      child: const RecipeHubApp(),
    ),
  );
}

const orange = Color(0xFFFF7043);
const cream = Color(0xFFFFF9F5);

// -------------------- RECIPE MODEL --------------------

class Recipe {
  Recipe({
    required this.id,
    required this.name,
    required this.category,
    required this.image,
    required this.description,
    required this.minutes,
    required this.rating,
    required this.ingredients,
    required this.steps,
  });

  final String id;
  final String name;
  final String category;
  final String image;
  final String description;
  final int minutes;
  final double rating;
  final List<String> ingredients;
  final List<String> steps;
}

ImageProvider<Object> recipeImageProvider(String image) {
  if (image.startsWith('assets/')) {
    return AssetImage(image);
  }
  return NetworkImage(image);
}

// -------------------- RECIPE STORE --------------------

class RecipeStore extends ChangeNotifier {
  bool darkMode = false;
  bool loading = false;
  String? apiError;

  final Set<String> favorites = {};

  final List<Recipe> recipes = [
    Recipe(
      id: '1',
      name: 'Vegetable Biryani',
      category: 'Indian',
      image: 'assets/vegetable_biryani.png',
      description: 'Aromatic rice cooked with vegetables and fragrant spices.',
      minutes: 45,
      rating: 4.8,
      ingredients: [
        '2 cups basmati rice',
        'Mixed vegetables',
        'Biryani masala',
        'Mint and coriander',
        'Salt and oil',
      ],
      steps: [
        'Wash and soak the rice for 20 minutes.',
        'Cook vegetables with spices until tender.',
        'Add rice and water, then cook until fluffy.',
        'Garnish with mint and serve warm.',
      ],
    ),
    Recipe(
      id: '2',
      name: 'Masala Dosa',
      category: 'Breakfast',
      image: 'assets/masala_dosa.png',
      description: 'Crispy South Indian dosa filled with spiced potato masala.',
      minutes: 30,
      rating: 4.7,
      ingredients: [
        'Dosa batter',
        'Potatoes',
        'Onion',
        'Mustard seeds',
        'Curry leaves',
      ],
      steps: [
        'Prepare a spiced potato filling.',
        'Spread dosa batter thinly on a hot pan.',
        'Add potato filling and fold.',
        'Serve with chutney and sambar.',
      ],
    ),
    Recipe(
      id: '3',
      name: 'Paneer Butter Masala',
      category: 'Indian',
      image:
          'https://images.unsplash.com/photo-1631452180519-c014fe946bc7?w=900',
      description: 'Soft paneer cubes in a creamy tomato and butter gravy.',
      minutes: 35,
      rating: 4.9,
      ingredients: [
        'Paneer',
        'Tomatoes',
        'Cream',
        'Butter',
        'Garam masala',
      ],
      steps: [
        'Prepare a smooth tomato gravy.',
        'Add spices, butter and cream.',
        'Add paneer cubes and simmer.',
        'Garnish with coriander.',
      ],
    ),
    Recipe(
      id: '4',
      name: 'Pasta Alfredo',
      category: 'Italian',
      image:
          'https://images.unsplash.com/photo-1473093295043-cdd812d0e601?w=900',
      description: 'Creamy pasta tossed in a rich garlic parmesan sauce.',
      minutes: 25,
      rating: 4.6,
      ingredients: [
        'Pasta',
        'Milk or cream',
        'Garlic',
        'Parmesan',
        'Black pepper',
      ],
      steps: [
        'Boil pasta until al dente.',
        'Saute garlic in butter.',
        'Add cream and parmesan.',
        'Toss pasta in the sauce and serve.',
      ],
    ),
    Recipe(
      id: '5',
      name: 'Chocolate Cake',
      category: 'Dessert',
      image:
          'https://images.unsplash.com/photo-1578985545062-69928b1d9587?w=900',
      description: 'Moist chocolate cake for a sweet treat.',
      minutes: 55,
      rating: 4.9,
      ingredients: [
        'Flour',
        'Cocoa powder',
        'Sugar',
        'Eggs',
        'Butter',
      ],
      steps: [
        'Mix the dry ingredients.',
        'Whisk wet ingredients separately.',
        'Combine and pour into a cake tin.',
        'Bake until a skewer comes out clean.',
      ],
    ),
    Recipe(
      id: '6',
      name: 'Mango Smoothie',
      category: 'Drinks',
      image:
          'https://images.unsplash.com/photo-1623065422902-30a2d299bbe4?w=900',
      description: 'A refreshing mango smoothie made with fresh fruit.',
      minutes: 10,
      rating: 4.5,
      ingredients: [
        'Ripe mango',
        'Milk',
        'Yogurt',
        'Honey',
        'Ice',
      ],
      steps: [
        'Peel and chop the mango.',
        'Add all ingredients to a blender.',
        'Blend until smooth.',
        'Pour into a glass and serve chilled.',
      ],
    ),
    Recipe(
      id: '7',
      name: 'Veg Fried Rice',
      category: 'Chinese',
      image:
          'https://images.unsplash.com/photo-1603133872878-684f208fb84b?w=900',
      description: 'Quick fried rice with crunchy vegetables.',
      minutes: 20,
      rating: 4.6,
      ingredients: [
        'Cooked rice',
        'Carrot',
        'Beans',
        'Spring onion',
        'Soy sauce',
      ],
      steps: [
        'Chop all vegetables.',
        'Stir-fry vegetables on high heat.',
        'Add cooked rice and soy sauce.',
        'Toss well and garnish with spring onion.',
      ],
    ),
    Recipe(
      id: '8',
      name: 'Pancakes',
      category: 'Breakfast',
      image:
          'https://images.unsplash.com/photo-1528207776546-365bb710ee93?w=900',
      description: 'Fluffy pancakes served with fruit and syrup.',
      minutes: 20,
      rating: 4.7,
      ingredients: [
        'Flour',
        'Milk',
        'Egg',
        'Baking powder',
        'Maple syrup',
      ],
      steps: [
        'Whisk flour and baking powder.',
        'Add milk and egg to make batter.',
        'Cook small portions on a pan.',
        'Serve with fruit and syrup.',
      ],
    ),
  ];

  void toggleFavorite(String id) {
    if (favorites.contains(id)) {
      favorites.remove(id);
    } else {
      favorites.add(id);
    }
    notifyListeners();
  }

  bool isFavorite(String id) {
    return favorites.contains(id);
  }

  void toggleTheme() {
    darkMode = !darkMode;
    notifyListeners();
  }

  void addRecipe(Recipe recipe) {
    recipes.insert(0, recipe);
    notifyListeners();
  }

  // Fetch recipes from TheMealDB public REST API.
  Future<void> fetchOnlineRecipes() async {
    loading = true;
    apiError = null;
    notifyListeners();

    try {
      final response = await http
          .get(
            Uri.parse(
              'https://www.themealdb.com/api/json/v1/1/search.php?s=chicken',
            ),
          )
          .timeout(const Duration(seconds: 12));

      if (response.statusCode != 200) {
        throw Exception('Unable to load recipes.');
      }

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final meals = (decoded['meals'] as List?) ?? [];

      for (final meal in meals.take(5)) {
        final id = 'api_${meal['idMeal']}';

        if (recipes.any((recipe) => recipe.id == id)) {
          continue;
        }

        recipes.add(
          Recipe(
            id: id,
            name: meal['strMeal'] ?? 'Online recipe',
            category: meal['strCategory'] ?? 'Other',
            image: meal['strMealThumb'] ?? '',
            description: 'Recipe loaded from TheMealDB public API.',
            minutes: 30,
            rating: 4.5,
            ingredients: [
              'Please see the original recipe for ingredients.',
            ],
            steps: [
              meal['strInstructions'] ??
                  'Follow the instructions from the recipe source.',
            ],
          ),
        );
      }
    } catch (e) {
      apiError =
          'Could not fetch online recipes. Check your internet connection.';
    }

    loading = false;
    notifyListeners();
  }
}

// -------------------- MAIN APPLICATION --------------------

class RecipeHubApp extends StatelessWidget {
  const RecipeHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<RecipeStore>(
      builder: (_, store, __) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'RecipeHub',
          themeMode: store.darkMode ? ThemeMode.dark : ThemeMode.light,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: orange,
              brightness: Brightness.light,
            ),
            scaffoldBackgroundColor: cream,
            appBarTheme: const AppBarTheme(
              backgroundColor: cream,
              foregroundColor: Color(0xFF292524),
            ),
            fontFamily: 'Roboto',
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: orange,
              brightness: Brightness.dark,
            ),
          ),
          home: const MainShell(),
        );
      },
    );
  }
}

// -------------------- MAIN NAVIGATION --------------------

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int selected = 0;

  final pages = const [
    HomeScreen(),
    ExploreScreen(),
    FavoritesScreen(),
    CategoriesScreen(),
    ProfileScreen(),
  ];

  final titles = [
    'RecipeHub',
    'Explore',
    'Favorites',
    'Categories',
    'Profile',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          titles[selected],
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            tooltip: 'Add recipe',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AddRecipeScreen(),
                ),
              );
            },
            icon: const Icon(Icons.add_circle_outline),
          ),
        ],
      ),
      body: IndexedStack(
        index: selected,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selected,
        onDestinationSelected: (i) {
          setState(() {
            selected = i;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: 'Explore',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border),
            selectedIcon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          NavigationDestination(
            icon: Icon(Icons.grid_view_outlined),
            selectedIcon: Icon(Icons.grid_view),
            label: 'Categories',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// -------------------- HOME SCREEN --------------------

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<RecipeStore>();
    final featured = store.recipes.first;

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
      children: [
        const Text(
          'Good food, good mood! 👋',
          style: TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          'What would you like to cook today?',
          style: TextStyle(color: Theme.of(context).hintColor),
        ),
        const SizedBox(height: 18),
        SearchBox(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const SearchScreen(),
              ),
            );
          },
        ),
        const SizedBox(height: 22),
        const SectionTitle('Featured recipe'),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () => openRecipe(context, featured),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Stack(
              children: [
                Image(
                  image: recipeImageProvider(featured.image),
                  height: 190,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) {
                    return Container(
                      height: 190,
                      color: Colors.orange.shade100,
                      child: const Icon(
                        Icons.restaurant,
                        size: 60,
                      ),
                    );
                  },
                ),
                Container(
                  height: 190,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black87,
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'TODAY’S PICK',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      Text(
                        featured.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '⭐ ${featured.rating}  •  ${featured.minutes} min',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 22),
        const SectionTitle('Browse categories'),
        const SizedBox(height: 12),
        SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              'All',
              'Breakfast',
              'Indian',
              'Italian',
              'Chinese',
              'Dessert',
              'Drinks',
            ].map((category) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ActionChip(
                  label: Text(category),
                  backgroundColor:
                      category == 'All' ? orange.withOpacity(0.15) : null,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CategoryResultsScreen(
                          category: category,
                        ),
                      ),
                    );
                  },
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 22),
        const SectionTitle('Popular recipes'),
        const SizedBox(height: 10),
        RecipeGrid(
          recipes: store.recipes.take(6).toList(),
        ),
        const SizedBox(height: 18),
        FilledButton.icon(
          onPressed: store.loading ? null : store.fetchOnlineRecipes,
          icon: const Icon(Icons.cloud_download_outlined),
          label: Text(
            store.loading
                ? 'Loading online recipes...'
                : 'Discover online recipes',
          ),
        ),
        if (store.apiError != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              store.apiError!,
              style: const TextStyle(color: Colors.red),
            ),
          ),
      ],
    );
  }
}

// -------------------- EXPLORE SCREEN --------------------

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({
    super.key,
    this.initialQuery = '',
  });

  final String initialQuery;

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  late String query;
  late final TextEditingController searchController;

  @override
  void initState() {
    super.initState();
    query = widget.initialQuery;
    searchController = TextEditingController(text: query);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final recipes = context.watch<RecipeStore>().recipes.where((recipe) {
      return recipe.name.toLowerCase().contains(query.toLowerCase()) ||
          recipe.category.toLowerCase().contains(query.toLowerCase());
    }).toList();

    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        TextField(
          controller: searchController,
          decoration: InputDecoration(
            hintText: 'Search recipes or cuisines',
            prefixIcon: const Icon(Icons.search),
            filled: true,
            fillColor: Theme.of(context).cardColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
          onChanged: (value) {
            setState(() {
              query = value;
            });
          },
        ),
        const SizedBox(height: 18),
        SectionTitle(
          query.isEmpty ? 'Explore recipes' : '${recipes.length} results',
        ),
        const SizedBox(height: 12),
        RecipeGrid(recipes: recipes),
        if (recipes.isEmpty)
          const EmptyState(
            message: 'No recipes found. Try another search.',
          ),
      ],
    );
  }
}

// -------------------- FAVORITES SCREEN --------------------

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<RecipeStore>();

    final items =
        store.recipes.where((recipe) => store.isFavorite(recipe.id)).toList();

    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const Text(
          'Your saved dishes',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 14),
        if (items.isEmpty)
          const EmptyState(
            message:
                'Your favorite recipes will appear here. Tap the heart on any recipe to save it.',
          ),
        RecipeGrid(recipes: items),
      ],
    );
  }
}

// -------------------- CATEGORIES SCREEN --------------------

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  static const categories = [
    ('Breakfast', '🥞'),
    ('Indian', '🍛'),
    ('Italian', '🍝'),
    ('Chinese', '🥡'),
    ('Dessert', '🍰'),
    ('Drinks', '🥤'),
    ('Healthy', '🥗'),
    ('Snacks', '🥪'),
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(18),
      itemCount: categories.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.35,
      ),
      itemBuilder: (context, i) {
        return InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CategoryResultsScreen(
                  category: categories[i].$1,
                ),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 12,
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  categories[i].$2,
                  style: const TextStyle(fontSize: 34),
                ),
                const SizedBox(height: 8),
                Text(
                  categories[i].$1,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// -------------------- PROFILE SCREEN --------------------

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<RecipeStore>();

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const CircleAvatar(
          radius: 45,
          backgroundColor: Color(0xFFFFE0D2),
          child: Icon(
            Icons.person,
            color: orange,
            size: 48,
          ),
        ),
        const SizedBox(height: 12),
        const Center(
          child: Text(
            'Recipe Explorer',
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const Center(
          child: Text(
            'Welcome to your kitchen!',
            style: TextStyle(color: Colors.grey),
          ),
        ),
        const SizedBox(height: 24),
        Card(
          child: ListTile(
            leading: const Icon(Icons.favorite, color: orange),
            title: const Text('Saved recipes'),
            trailing: Text('${store.favorites.length}'),
          ),
        ),
        Card(
          child: SwitchListTile(
            secondary: const Icon(Icons.dark_mode_outlined),
            title: const Text('Dark theme'),
            value: store.darkMode,
            onChanged: (_) => store.toggleTheme(),
          ),
        ),
        const Card(
          child: ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('About RecipeHub'),
            subtitle: Text('Discover. Cook. Enjoy.'),
          ),
        ),
      ],
    );
  }
}

// -------------------- CATEGORY RESULTS --------------------

class CategoryResultsScreen extends StatelessWidget {
  const CategoryResultsScreen({
    super.key,
    required this.category,
  });

  final String category;

  @override
  Widget build(BuildContext context) {
    final all = context.watch<RecipeStore>().recipes;

    final items = category == 'All'
        ? all
        : all
            .where(
              (recipe) =>
                  recipe.category.toLowerCase() == category.toLowerCase(),
            )
            .toList();

    return Scaffold(
      appBar: AppBar(title: Text(category)),
      body: items.isEmpty
          ? const EmptyState(
              message: 'No recipes in this category yet.',
            )
          : RecipeGrid(recipes: items),
    );
  }
}

// -------------------- SEARCH SCREEN --------------------

class SearchScreen extends StatelessWidget {
  const SearchScreen({
    super.key,
    this.initialQuery = '',
  });

  final String initialQuery;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search recipes'),
      ),
      body: ExploreScreen(initialQuery: initialQuery),
    );
  }
}

// -------------------- RESPONSIVE RECIPE GRID --------------------

class RecipeGrid extends StatelessWidget {
  const RecipeGrid({
    super.key,
    required this.recipes,
  });

  final List<Recipe> recipes;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        final columns = box.maxWidth > 650 ? 3 : 2;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: recipes.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 12,
            mainAxisSpacing: 14,
            childAspectRatio: 0.72,
          ),
          itemBuilder: (context, i) {
            return RecipeTile(recipe: recipes[i]);
          },
        );
      },
    );
  }
}

// -------------------- RECIPE CARD --------------------

class RecipeTile extends StatelessWidget {
  const RecipeTile({
    super.key,
    required this.recipe,
  });

  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    final store = context.watch<RecipeStore>();

    return InkWell(
      onTap: () => openRecipe(context, recipe),
      borderRadius: BorderRadius.circular(18),
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image(
                    image: recipeImageProvider(recipe.image),
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) {
                      return Container(
                        color: Colors.orange.shade100,
                        child: const Icon(
                          Icons.restaurant,
                          size: 40,
                          color: orange,
                        ),
                      );
                    },
                  ),
                  Positioned(
                    right: 7,
                    top: 7,
                    child: CircleAvatar(
                      radius: 17,
                      backgroundColor: Colors.white,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        iconSize: 18,
                        onPressed: () {
                          store.toggleFavorite(recipe.id);
                        },
                        icon: Icon(
                          store.isFavorite(recipe.id)
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: orange,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 9, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        color: Colors.amber,
                        size: 15,
                      ),
                      Text(
                        ' ${recipe.rating}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.schedule,
                        size: 14,
                        color: Colors.grey,
                      ),
                      Text(
                        ' ${recipe.minutes} min',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -------------------- RECIPE DETAILS --------------------

class RecipeDetailScreen extends StatefulWidget {
  const RecipeDetailScreen({
    super.key,
    required this.recipe,
  });

  final Recipe recipe;

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  final Set<int> checked = {};

  @override
  Widget build(BuildContext context) {
    final recipe = widget.recipe;
    final store = context.watch<RecipeStore>();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: recipe.id,
                child: Image(
                  image: recipeImageProvider(recipe.image),
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) {
                    return Container(
                      color: Colors.orange.shade100,
                      child: const Icon(
                        Icons.restaurant,
                        size: 70,
                      ),
                    );
                  },
                ),
              ),
            ),
            actions: [
              IconButton(
                onPressed: () {
                  store.toggleFavorite(recipe.id);
                },
                icon: Icon(
                  store.isFavorite(recipe.id)
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.name,
                    style: const TextStyle(
                      fontSize: 27,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    recipe.description,
                    style: TextStyle(
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      InfoPill(
                        icon: Icons.schedule,
                        text: '${recipe.minutes} min',
                      ),
                      const SizedBox(width: 8),
                      InfoPill(
                        icon: Icons.star,
                        text: '${recipe.rating}',
                      ),
                      const SizedBox(width: 8),
                      InfoPill(
                        icon: Icons.restaurant_menu,
                        text: recipe.category,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const SectionTitle('Ingredients'),
                  ...recipe.ingredients.asMap().entries.map((entry) {
                    return CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      value: checked.contains(entry.key),
                      title: Text(
                        entry.value,
                        style: TextStyle(
                          decoration: checked.contains(entry.key)
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      activeColor: orange,
                      onChanged: (value) {
                        setState(() {
                          if (value == true) {
                            checked.add(entry.key);
                          } else {
                            checked.remove(entry.key);
                          }
                        });
                      },
                    );
                  }),
                  const SizedBox(height: 16),
                  const SectionTitle('Cooking instructions'),
                  ...recipe.steps.asMap().entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 14,
                            backgroundColor: orange.withOpacity(0.15),
                            child: Text(
                              '${entry.key + 1}',
                              style: const TextStyle(
                                color: orange,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(entry.value),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// -------------------- NAVIGATE TO RECIPE DETAILS --------------------

void openRecipe(BuildContext context, Recipe recipe) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => RecipeDetailScreen(recipe: recipe),
    ),
  );
}

// -------------------- ADD RECIPE FORM --------------------

class AddRecipeScreen extends StatefulWidget {
  const AddRecipeScreen({super.key});

  @override
  State<AddRecipeScreen> createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends State<AddRecipeScreen> {
  final form = GlobalKey<FormState>();

  final name = TextEditingController();
  final description = TextEditingController();
  final minutes = TextEditingController();
  final ingredients = TextEditingController();

  String category = 'Indian';

  @override
  void dispose() {
    name.dispose();
    description.dispose();
    minutes.dispose();
    ingredients.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add a recipe'),
      ),
      body: Form(
        key: form,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'Share your creation',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 18),
            TextFormField(
              controller: name,
              decoration: const InputDecoration(
                labelText: 'Recipe name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Enter a recipe name';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: description,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Enter a description';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              value: category,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
              items: [
                'Indian',
                'Breakfast',
                'Italian',
                'Chinese',
                'Dessert',
                'Drinks',
              ].map((item) {
                return DropdownMenuItem(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    category = value;
                  });
                }
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: minutes,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Cooking time (minutes)',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                final time = int.tryParse(value ?? '');

                if (time == null || time <= 0) {
                  return 'Enter a valid time';
                }

                return null;
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: ingredients,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Ingredients (separate with commas)',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Enter ingredients';
                }
                return null;
              },
            ),
            const SizedBox(height: 22),
            FilledButton(
              onPressed: () {
                if (!form.currentState!.validate()) {
                  return;
                }

                final newRecipe = Recipe(
                  id: DateTime.now().microsecondsSinceEpoch.toString(),
                  name: name.text.trim(),
                  category: category,
                  image:
                      'https://images.unsplash.com/photo-1546549032-9571cd6b27df?w=900',
                  description: description.text.trim(),
                  minutes: int.parse(minutes.text),
                  rating: 5.0,
                  ingredients: ingredients.text
                      .split(',')
                      .map((item) => item.trim())
                      .where((item) => item.isNotEmpty)
                      .toList(),
                  steps: [
                    'Prepare all ingredients.',
                    'Cook carefully and serve fresh.',
                  ],
                );

                context.read<RecipeStore>().addRecipe(newRecipe);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Recipe added successfully!'),
                  ),
                );

                Navigator.pop(context);
              },
              child: const Text('Add recipe'),
            ),
          ],
        ),
      ),
    );
  }
}

// -------------------- REUSABLE SEARCH BOX --------------------

class SearchBox extends StatelessWidget {
  const SearchBox({
    super.key,
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextField(
      readOnly: true,
      onTap: onTap,
      decoration: InputDecoration(
        hintText: 'Search delicious recipes...',
        prefixIcon: const Icon(
          Icons.search,
          color: orange,
        ),
        suffixIcon: const Icon(
          Icons.tune,
          color: orange,
        ),
        filled: true,
        fillColor: Theme.of(context).cardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

// -------------------- REUSABLE SECTION TITLE --------------------

class SectionTitle extends StatelessWidget {
  const SectionTitle(
    this.title, {
    super.key,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

// -------------------- REUSABLE INFORMATION PILL --------------------

class InfoPill extends StatelessWidget {
  const InfoPill({
    super.key,
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 9,
      ),
      decoration: BoxDecoration(
        color: orange.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 15,
            color: orange,
          ),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// -------------------- REUSABLE EMPTY STATE --------------------

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 60,
        horizontal: 25,
      ),
      child: Column(
        children: [
          Icon(
            Icons.restaurant_menu,
            size: 55,
            color: orange.withOpacity(0.6),
          ),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).hintColor,
            ),
          ),
        ],
      ),
    );
  }
}
