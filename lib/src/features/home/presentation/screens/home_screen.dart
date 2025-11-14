import 'package:flutter/material.dart';
import 'teyasantalucia_screen.dart';
import 'apoala_screen.dart'; // Import the ApoalaScreen
import 'coyote_screen.dart'; // Import the CoyoteScreen
import 'babes_screen.dart'; // Import the BabesScreen

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

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
                child: Stack( // Changed from Row to Stack
                  alignment: Alignment.center, // Center the children by default
                  children: [
                    Align( // Align IconButton to the left
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        padding: const EdgeInsets.all(20), // Further increased padding for easier tap
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
                      backgroundImage: AssetImage('assets/images/LogoFinal.png'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar restaurantes...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
          // Remaining content on white background
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Removed CircleAvatar and SizedBox from here

                  // Tarjeta 1 (RestaurantCard) - positioned on white background
                  RestaurantCard(
                    imagePath: 'assets/images/Teya Santa Lucia.png',
                    name: 'TEYA SANTA LUCIA',
                    rating: 4.5,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const TeyaSantaLuciaScreen()),
                      );
                    },
                  ),

                  const SizedBox(height: 80), // Add SizedBox here

                  // Tarjeta 2 (RestaurantCard)
                  RestaurantCard(
                    imagePath:
                        'assets/images/Apoala.png', // Using a different image for variety
                    name: 'Apoala',
                    rating: 4.0,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ApoalaScreen()),
                      );
                    },
                  ),

                  const SizedBox(
                      height:
                          80), // Space between RestaurantCard2 and RestaurantCard3

                  // Tarjeta 3 (RestaurantCard)
                  RestaurantCard(
                    imagePath:
                        'assets/images/Babes.png', // Using a different image for variety
                    name: 'Babe´s',
                    rating: 4.5,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const BabesScreen()),
                      );
                    },
                  ),

                  const SizedBox(height: 80), // Space after RestaurantCard3

                  // Tarjeta 4 (RestaurantCard)
                  RestaurantCard(
                    imagePath:
                        'assets/images/Bistrola 57.png', // Using a different image for variety
                    name: 'Bistrola 57',
                    rating: 4.0,
                    onTap: () {
                      Navigator.pushNamed(context, '/bistrola57');
                    },
                  ),

                  const SizedBox(height: 80), // Space after RestaurantCard4

                  // Tarjeta 5 (RestaurantCard)
                  RestaurantCard(
                    imagePath:
                        'assets/images/Coyote Maya.png', // Using a different image for variety
                    name: 'Coyote Maya',
                    rating: 4.5,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const CoyoteScreen()),
                      );
                    },
                  ),

                  const SizedBox(height: 80), // Space after RestaurantCard5

                  // Tarjeta 6 (RestaurantCard)
                  const RestaurantCard(
                    imagePath:
                        'assets/images/Pita Mediterranea.png', // Using a different image for variety
                    name: 'Pita Mediterranea',
                    rating: 4.0,
                  ),
                ],
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
      child: InkWell( // Wrapped with InkWell
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
                      padding:
                          const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
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
