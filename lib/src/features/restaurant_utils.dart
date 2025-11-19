import 'package:geolocator/geolocator.dart';
import 'package:flutter_application_24/src/features/restaurants_data.dart';

/// Clase auxiliar para emparejar un restaurante con su distancia desde un punto dado.
class RestaurantWithDistance {
  final Restaurant restaurant;
  final double distance; // Distancia en metros

  RestaurantWithDistance({required this.restaurant, required this.distance});
}

/// Calcula la distancia a cada restaurante desde la ubicación actual del usuario
/// y devuelve una lista de restaurantes ordenada por distancia (de menor a mayor).
List<Restaurant> sortRestaurantsByDistance(Position userLocation) {
  List<RestaurantWithDistance> restaurantsWithDistances = [];

  for (var restaurant in elegantRestaurantsMerida) {
    double distance = Geolocator.distanceBetween(
      userLocation.latitude,
      userLocation.longitude,
      restaurant.latitude,
      restaurant.longitude,
    );
    restaurantsWithDistances.add(
      RestaurantWithDistance(restaurant: restaurant, distance: distance),
    );
  }

  // Ordenar la lista por distancia
  restaurantsWithDistances.sort((a, b) => a.distance.compareTo(b.distance));

  // Devolver solo los objetos Restaurant ordenados
  return restaurantsWithDistances.map((item) => item.restaurant).toList();
}
