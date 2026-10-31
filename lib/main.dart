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
const olive = Color(0xFF697A45);
const cream = Color(0xFFFFF8E8);

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
              seedColor: olive,
              brightness: Brightness.light,
            ).copyWith(secondary: orange),
            scaffoldBackgroundColor: cream,
            cardColor: const Color(0xFFFFFCF4),
            appBarTheme: const AppBarTheme(
              backgroundColor: cream,
              foregroundColor: Color(0xFF292524),
            ),
            fontFamily: 'Roboto',
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: olive,
              brightness: Brightness.dark,
            ).copyWith(secondary: orange),
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
    final vibes = [
      (
        'Quick & easy',
        'Under 30 minutes',
        Icons.bolt_rounded,
        store.recipes.where((recipe) => recipe.minutes <= 30).toList(),
        const Color(0xFFE9EFD9),
      ),
      (
        'Indian comfort',
        'Full of flavor',
        Icons.local_fire_department_rounded,
        store.recipes.where((recipe) => recipe.category == 'Indian').toList(),
        const Color(0xFFF9E6D7),
      ),
      (
        'Sweet moments',
        'A little treat',
        Icons.cookie_outlined,
        store.recipes.where((recipe) => recipe.category == 'Dessert').toList(),
        const Color(0xFFF3E7EF),
      ),
      (
        'Your favorites',
        'Saved with love',
        Icons.favorite_rounded,
        store.recipes.where((recipe) => store.isFavorite(recipe.id)).toList(),
        const Color(0xFFF9E4DF),
      ),
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'YOUR KITCHEN, YOUR STORY',
                    style: TextStyle(
                      color: olive,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.6,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    'What sounds good today?',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontFamily: 'serif',
                          fontWeight: FontWeight.w700,
                          height: 1.1,
                        ),
                  ),
                ],
              ),
            ),
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: const Color(0xFFE8EDD9),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.restaurant_menu_rounded,
                color: olive,
                size: 23,
              ),
            ),
          ],
        ),
        const SizedBox(height: 7),
        Text(
          'A little inspiration for your next delicious meal.',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 13,
          ),
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
        const SizedBox(height: 24),
        _HomeSectionHeader(
          eyebrow: 'HANDPICKED FOR YOU',
          title: 'Today’s pick',
          trailing: '1 recipe',
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () => openRecipe(context, featured),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(26),
            child: SizedBox(
              height: 250,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image(
                    image: recipeImageProvider(featured.image),
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => ColoredBox(
                      color: const Color(0xFFE9D7BB),
                      child: Icon(
                        Icons.restaurant_rounded,
                        size: 64,
                        color: olive.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0x22000000),
                          Color(0x00000000),
                          Color(0xCC000000),
                        ],
                        stops: [0, 0.32, 1],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 14,
                    left: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFCF4).withValues(alpha: 0.94),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.auto_awesome, size: 14, color: olive),
                          SizedBox(width: 6),
                          Text(
                            'TODAY’S PICK',
                            style: TextStyle(
                              color: olive,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Material(
                      color: Colors.black.withValues(alpha: 0.3),
                      shape: const CircleBorder(),
                      child: IconButton(
                        tooltip: store.isFavorite(featured.id)
                            ? 'Remove from favorites'
                            : 'Save to favorites',
                        onPressed: () => store.toggleFavorite(featured.id),
                        icon: Icon(
                          store.isFavorite(featured.id)
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 18,
                    right: 18,
                    bottom: 18,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          featured.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 25,
                            fontWeight: FontWeight.w800,
                            height: 1.05,
                            shadows: [
                              Shadow(color: Colors.black26, blurRadius: 8),
                            ],
                          ),
                        ),
                        const SizedBox(height: 7),
                        Text(
                          featured.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            shadows: [
                              Shadow(color: Colors.black38, blurRadius: 8),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _HeroMeta(
                              icon: Icons.star_rounded,
                              label: '${featured.rating}',
                            ),
                            const SizedBox(width: 14),
                            _HeroMeta(
                              icon: Icons.schedule_rounded,
                              label: '${featured.minutes} min',
                            ),
                            const SizedBox(width: 14),
                            _HeroMeta(
                              icon: Icons.restaurant_menu_rounded,
                              label: featured.category,
                            ),
                            const Spacer(),
                            const Icon(
                              Icons.arrow_outward_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 26),
        _HomeSectionHeader(
          eyebrow: 'FIND YOUR NEXT FAVORITE',
          title: 'Browse by mood',
          trailing: 'See all',
          onTrailingTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const CategoriesScreen(),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 48,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: const [
              ('All recipes', Icons.restaurant_rounded, 'All'),
              ('Breakfast', Icons.free_breakfast_rounded, 'Breakfast'),
              ('Indian', Icons.rice_bowl_rounded, 'Indian'),
              ('Italian', Icons.local_pizza_rounded, 'Italian'),
              ('Chinese', Icons.ramen_dining_rounded, 'Chinese'),
              ('Dessert', Icons.cake_rounded, 'Dessert'),
              ('Drinks', Icons.local_cafe_rounded, 'Drinks'),
            ].map((item) {
              return Padding(
                padding: const EdgeInsets.only(right: 9),
                child: ActionChip(
                  avatar: Icon(item.$2, size: 17, color: olive),
                  label: Text(item.$1),
                  backgroundColor: const Color(0xFFFFFCF4),
                  side: BorderSide(color: olive.withValues(alpha: 0.12)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            CategoryResultsScreen(category: item.$3),
                      ),
                    );
                  },
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 26),
        const _HomeSectionHeader(
          eyebrow: 'A COLLECTION FOR EVERY CRAVING',
          title: 'Your recipe vibes ✨',
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 154,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: vibes.length,
            separatorBuilder: (_, __) => const SizedBox(width: 11),
            itemBuilder: (context, index) {
              final vibe = vibes[index];
              return _RecipeVibeCard(
                title: vibe.$1,
                subtitle: vibe.$2,
                icon: vibe.$3,
                count: vibe.$4.length,
                color: vibe.$5,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RecipeCollectionScreen(
                        title: vibe.$1,
                        recipes: vibe.$4,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        const SizedBox(height: 26),
        _HomeSectionHeader(
          eyebrow: 'SOMETHING GOOD IS COOKING',
          title: 'Popular recipes',
          trailing: '${store.recipes.length} recipes',
        ),
        const SizedBox(height: 12),
        RecipeGrid(recipes: store.recipes.take(6).toList()),
        const SizedBox(height: 20),
        OutlinedButton.icon(
          onPressed: store.loading ? null : store.fetchOnlineRecipes,
          icon: const Icon(Icons.travel_explore_rounded),
          label: Text(
            store.loading
                ? 'Finding fresh inspiration...'
                : 'Discover more recipes',
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: olive,
            side: BorderSide(color: olive.withValues(alpha: 0.28)),
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
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

class _HomeSectionHeader extends StatelessWidget {
  const _HomeSectionHeader({
    required this.eyebrow,
    required this.title,
    this.trailing,
    this.onTrailingTap,
  });

  final String eyebrow;
  final String title;
  final String? trailing;
  final VoidCallback? onTrailingTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                eyebrow,
                style: const TextStyle(
                  color: olive,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.3,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontFamily: 'serif',
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
        ),
        if (trailing != null && onTrailingTap == null)
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 2),
            child: Text(
              trailing!,
              style: const TextStyle(
                color: olive,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          )
        else if (trailing != null)
          TextButton(
            onPressed: onTrailingTap,
            style: TextButton.styleFrom(
              foregroundColor: olive,
              padding: const EdgeInsets.only(left: 8, bottom: 2),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              trailing!,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
      ],
    );
  }
}

class _HeroMeta extends StatelessWidget {
  const _HeroMeta({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: const Color(0xFFFFD16C)),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _RecipeVibeCard extends StatelessWidget {
  const _RecipeVibeCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.count,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final int count;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 148,
      child: Material(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(17),
                  ),
                  child: Icon(icon, color: olive, size: 24),
                ),
                const Spacer(),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$count recipes · $subtitle',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
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

class RecipeCollectionScreen extends StatelessWidget {
  const RecipeCollectionScreen({
    super.key,
    required this.title,
    required this.recipes,
  });

  final String title;
  final List<Recipe> recipes;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Text(
            '${recipes.length} ${recipes.length == 1 ? 'recipe' : 'recipes'} to explore',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          if (recipes.isEmpty)
            const EmptyState(
              message: 'No recipes in this collection just yet.',
            )
          else
            RecipeGrid(recipes: recipes),
        ],
      ),
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
