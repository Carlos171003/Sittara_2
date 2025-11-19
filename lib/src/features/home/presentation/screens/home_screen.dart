import 'package:flutter/material.dart';
import 'teyasantalucia_screen.dart';
import 'apoala_screen.dart'; // Import the ApoalaScreen
import 'coyote_screen.dart'; // Import the CoyoteScreen
import 'babes_screen.dart'; // Import the BabesScreen
import '../../../restaurants_data.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Restaurant> _allRestaurants = [];
  List<Restaurant> _filteredRestaurants = [];
  String? _selectedFoodType; // Para el tipo de comida seleccionado

  // Lista de todos los tipos de comida disponibles
  final List<String> _foodTypes = [
    'Yucateca',
    'Mexicana',
    'Contemporánea',
    'Bistró',
    'Internacional',
    'Italiana',
    'Francesa',
    'Asiática',
    'Tailandesa',
    'Noodles',
  ];

  @override
  void initState() {
    super.initState();
    _allRestaurants = elegantRestaurantsMerida;
    _filteredRestaurants = _allRestaurants;
  }

        void _filterRestaurants(String query) {
          setState(() {
            _filteredRestaurants = _allRestaurants.where((restaurant) {
              final matchesQuery =
                  restaurant.name.toLowerCase().contains(query.toLowerCase());
              final matchesFoodType = _selectedFoodType == null ||
                  restaurant.foodTypes.contains(_selectedFoodType);
              return matchesQuery && matchesFoodType;
            }).toList();
          });
        }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Top section with gradient
          Container(
            height: MediaQuery.of(context).size.height *
                0.15, // Increased height to make it taller
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color.fromARGB(255, 138, 158, 141), Color(0xFFFFFFFF)],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
            child: SafeArea(
              // Removed const here to allow IconButton
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Stack(
                  // Changed from Row to Stack
                  alignment: Alignment.center, // Center the children by default
                  children: [
                    Align(
                      // Align IconButton to the left
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        padding: const EdgeInsets.all(
                            20), // Further increased padding for easier tap
                        icon: const Icon(Icons.menu,
                            size: 30, color: Colors.black87),
                        onPressed: () {
                          // Navigator.push( // This will be handled by named routes
                          //   context,
                          //   MaterialPageRoute(
                          //       builder: (context) => const MenuScreen()),
                          // );
                          Navigator.pushNamed(context, '/menu');
                        },
                      ),
                    ),
                    // CircleAvatar is now implicitly centered by the Stack's alignment
                    const CircleAvatar(
                      radius: 25, // Reduced radius for top bar
                      backgroundColor: Colors.white,
                      backgroundImage:
                          AssetImage('assets/images/LogoFinal.png'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Search bar and Food Type Filter
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                Flexible( // Usar Flexible en lugar de Expanded
                  flex: 2, // Ajustar flex
                  child: TextField(
                    controller: _searchController,
                    onChanged: (query) {
                      _filterRestaurants(query);
                    },
                    decoration: InputDecoration(
                      hintText: 'Buscar restaurantes...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8), // Reducir padding
                    ),
                  ),
                ),
                const SizedBox(width: 4), // Reducir espacio entre el buscador y el filtro
                Flexible( // Usar Flexible en lugar de Expanded
                  flex: 1, // Ajustar flex
                  child: DropdownButtonFormField<String>(
                    value: _selectedFoodType,
                    // Eliminamos el hintText para ahorrar espacio
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      contentPadding: EdgeInsets.zero, // Padding mínimo
                    ),
                    items: _foodTypes.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(
                          type,
                          overflow: TextOverflow.ellipsis, // Evitar desbordamiento de texto
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedFoodType = value;
                        _filterRestaurants(_searchController.text);
                      });
                    },
                    // Añadir una opción para limpiar el filtro
                    onTap: () {
                      // Solo limpiar si ya hay un valor seleccionado, para no interferir con la apertura
                      if (_selectedFoodType != null) {
                        setState(() {
                          _selectedFoodType = null;
                          _filterRestaurants(_searchController.text);
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          // Remaining content on white background
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: _filteredRestaurants.map((restaurant) {
                  // Helper to get image path, assuming a consistent naming convention
                  // This is a simplification and should be improved if image names vary greatly
                  String getImageName(String name) {
                    if (name == 'Teya Santa Lucía') return 'Teya Santa Lucia';
                    if (name == 'Babe’s') return 'Babes';
                    if (name == 'Pita Mediterránea') return 'Pita Mediterranea';
                    return name;
                  }

                  String imagePath =
                      'assets/images/${getImageName(restaurant.name)}.png';

                  // Determine the navigation target based on restaurant name
                  // This needs to be consistent with how the app's routes are defined
                  VoidCallback? navigationAction;
                  if (restaurant.name == 'Teya Santa Lucía') {
                    navigationAction = () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const TeyaSantaLuciaScreen()),
                      );
                    };
                  } else if (restaurant.name == 'Apoala') {
                    navigationAction = () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ApoalaScreen()),
                      );
                    };
                  } else if (restaurant.name == 'Babe’s') {
                    navigationAction = () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const BabesScreen()),
                      );
                    };
                  } else if (restaurant.name == 'Bistrola 57') {
                    navigationAction = () {
                      Navigator.pushNamed(context, '/bistrola57');
                    };
                  } else if (restaurant.name == 'Coyote Maya') {
                    navigationAction = () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const CoyoteScreen()),
                      );
                    };
                  } else if (restaurant.name == 'Pita Mediterránea') {
                    // Assuming a default screen or a message for this one if no specific screen exists
                    navigationAction = () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                'Navegando a la pantalla de ${restaurant.name}')),
                      );
                    };
                  }

                  return Column(
                    children: [
                      RestaurantCard(
                        imagePath: imagePath,
                        name: restaurant.name,
                        rating: restaurant.name == 'Teya Santa Lucía' ||
                                restaurant.name == 'Coyote Maya' ||
                                restaurant.name == 'Babe’s'
                            ? 4.5 // Original ratings from hardcoded list
                            : restaurant.name == 'Apoala' ||
                                    restaurant.name == 'Bistrola 57' ||
                                    restaurant.name == 'Pita Mediterránea'
                                ? 4.0 // Original ratings from hardcoded list
                                : 0.0, // Default if not found
                        onTap: navigationAction,
                      ),
                      const SizedBox(height: 20),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RestaurantCard extends StatelessWidget {
  final String imagePath;
  final String name;
  final double rating;
  final VoidCallback? onTap; // New property

  const RestaurantCard({
    super.key,
    required this.imagePath,
    required this.name,
    required this.rating,
    this.onTap, // New property
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: InkWell(
        // Wrapped with InkWell
        onTap: onTap, // Assign the onTap callback
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 6,
                offset: Offset(2, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      imagePath,
                      width: double.infinity, // Fill available width
                      fit: BoxFit.fitWidth, // Scale proportionally to fit width
                    ),
                    Container(
                      color: Colors.black.withAlpha(102),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                          Row(
                            children: List.generate(5, (index) {
                              double starValue = index + 1;
                              if (starValue <= rating) {
                                return const Icon(Icons.star,
                                    color: Colors.amber, size: 18);
                              } else if (starValue - rating < 1) {
                                return const Icon(Icons.star_half,
                                    color: Colors.amber, size: 18);
                              } else {
                                return const Icon(Icons.star_border,
                                    color: Colors.amber, size: 18);
                              }
                            }),
                          )
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
