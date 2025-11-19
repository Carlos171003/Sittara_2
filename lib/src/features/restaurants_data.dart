class Restaurant {
  final String name;
  final double latitude;
  final double longitude;
  final String description;
  final String priceRange; // Ej: "\$\$\$", "\$\$"
  final List<String> foodTypes; // Ej: ['Yucateca', 'Mexicana']

  Restaurant({
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.description,
    required this.priceRange,
    required this.foodTypes,
  });
}

final List<Restaurant> elegantRestaurantsMerida = [
  Restaurant(
    name: 'Coyote Maya',
    latitude: 20.975370,
    longitude: -89.617700,
    description:
        'Cocina de autor con toques yucatecos en un ambiente sofisticado.',
    priceRange: '\$\$\$',
    foodTypes: ['Yucateca', 'Contemporánea'],
  ),
  Restaurant(
    name: 'Teya Santa Lucía',
    latitude: 20.973800,
    longitude: -89.623000,
    description:
        'Tradición yucateca en un hermoso patio colonial, con platillos auténticos.',
    priceRange: '\$\$',
    foodTypes: ['Yucateca', 'Mexicana'],
  ),
  Restaurant(
    name: 'Bistrola 57',
    latitude: 20.973000,
    longitude: -89.620500,
    description:
        'Bistro francés con un toque moderno, ideal para una cena elegante.',
    priceRange: '\$\$\$',
    foodTypes: ['Bistró', 'Francesa'],
  ),
  Restaurant(
    name: 'Apoala',
    latitude: 20.975000,
    longitude: -89.622000,
    description: 'Cocina oaxaqueña contemporánea en el corazón de Santa Lucía.',
    priceRange: '\$\$\$',
    foodTypes: ['Mexicana', 'Contemporánea'],
  ),
  Restaurant(
    name: 'Babe’s',
    latitude: 20.972500,
    longitude: -89.621000,
    description:
        'Un lugar con ambiente relajado y platillos internacionales con un toque único.',
    priceRange: '\$\$',
    foodTypes: ['Internacional', 'Asiática', 'Noodles'],
  ),
  Restaurant(
    name: 'Pita Mediterránea',
    latitude: 20.976000,
    longitude: -89.619000,
    description: 'Sabores auténticos del Mediterráneo en un ambiente acogedor.',
    priceRange: '\$\$',
    foodTypes: ['Internacional'],
  ),
];
