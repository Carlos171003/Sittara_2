import 'package:flutter/material.dart';
import 'package:flutter_application_24/src/features/ors_service.dart'; // Importar de nuevo ors_service.dart

/// Un `ChangeNotifier` para gestionar el estado de los cálculos de distancia.
class DistanceProvider extends ChangeNotifier {
  final OpenRouteService _orsService; // Restaurar la declaración de _orsService

  DistanceProvider(
      {required String apiKey}) // Restaurar el constructor con apiKey
      : _orsService = OpenRouteService(apiKey: apiKey);

  final Map<String, double?> _distances = {};
  final Map<String, bool> _loadingStates = {};

  double? getDistance(String routeKey) => _distances[routeKey];
  bool isLoading(String routeKey) => _loadingStates[routeKey] ?? false;

  Future<void> fetchDistance({
    required double userLat,
    required double userLng,
    required double destinoLat,
    required double destinoLng,
  }) async {
    final start = [userLng, userLat];
    final end = [destinoLng, destinoLat];
    final routeKey = '${start.join(',')}-${end.join(',')}';

    if (_loadingStates[routeKey] == true || _distances.containsKey(routeKey)) {
      return;
    }

    _loadingStates[routeKey] = true;
    notifyListeners(); // Notificar que la carga ha comenzado

    try {
      final distance =
          await _orsService.getRouteDistance(start: start, end: end);
      _distances[routeKey] = distance;
    } catch (e) {
      // Manejo de errores: podrías registrar el error o almacenar un estado de error
      debugPrint('Error al obtener la distancia para la ruta $routeKey: $e');
      _distances[routeKey] =
          null; // Opcional: indicar que hubo un error en la distancia
    } finally {
      _loadingStates[routeKey] = false;
      notifyListeners(); // Notificar que la carga ha terminado (éxito o error)
    }
  }
}
