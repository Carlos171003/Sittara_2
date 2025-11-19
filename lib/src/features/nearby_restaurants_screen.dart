import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart'; // Importar provider

import 'package:flutter_application_24/src/features/restaurant_utils.dart';
import 'package:flutter_application_24/src/features/distance_provider.dart'; // Importar DistanceProvider
import 'package:flutter_application_24/src/features/route_distance_tile.dart'; // Importar RouteDistanceTile

class NearbyRestaurantsScreen extends StatefulWidget {
  final Position userLocation;

  const NearbyRestaurantsScreen({super.key, required this.userLocation});

  @override
  State<NearbyRestaurantsScreen> createState() =>
      _NearbyRestaurantsScreenState();
}

class _NearbyRestaurantsScreenState extends State<NearbyRestaurantsScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Iniciar la carga de distancias cuando las dependencias cambian
    _fetchDistances();
  }

  Future<void> _fetchDistances() async {
    final distanceProvider =
        Provider.of<DistanceProvider>(context, listen: false);
    final sortedRestaurants = sortRestaurantsByDistance(widget.userLocation);

    final List<Future<void>> fetchFutures = [];
    for (var restaurant in sortedRestaurants) {
      fetchFutures.add(
        distanceProvider.fetchDistance(
          userLat: widget.userLocation.latitude,
          userLng: widget.userLocation.longitude,
          destinoLat: restaurant.latitude,
          destinoLng: restaurant.longitude,
        ),
      );
    }
    await Future.wait(fetchFutures);
  }

  @override
  Widget build(BuildContext context) {
    final sortedRestaurants = sortRestaurantsByDistance(widget.userLocation);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Restaurantes Cercanos'),
        centerTitle: true,
      ),
      body: sortedRestaurants.isEmpty
          ? const Center(
              child: Text('No se encontraron restaurantes cercanos.'),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: sortedRestaurants.length,
              itemBuilder: (context, index) {
                final restaurant = sortedRestaurants[index];
                final routeKey =
                    '${widget.userLocation.longitude},${widget.userLocation.latitude}-${restaurant.longitude},${restaurant.latitude}';

                return Card(
                  margin: const EdgeInsets.only(bottom: 16.0),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.restaurant,
                              color: Theme.of(context).colorScheme.primary,
                              size: 28,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                restaurant.name,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                    ),
                              ),
                            ),
                            // Usar RouteDistanceTile para mostrar la distancia
                            RouteDistanceTile(
                              title:
                                  '', // El título ya está en el nombre del restaurante
                              routeKey: routeKey,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          restaurant.description,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Text(
                            'Rango de precios: ${restaurant.priceRange}',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      fontStyle: FontStyle.italic,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
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
}
