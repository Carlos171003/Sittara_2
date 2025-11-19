import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Un servicio para interactuar con la API de OpenRouteService.
///
/// Incluye un mecanismo de caché en memoria para evitar llamadas duplicadas
/// a la API para la misma ruta durante la sesión de la aplicación.
class OpenRouteService {
  final String _apiKey;
  static const String _baseUrl =
      'https://api.openrouteservice.org/v2/directions/driving-car';

  // Caché en memoria para almacenar distancias calculadas.
  final Map<String, double> _cache = {};

  OpenRouteService({required String apiKey}) : _apiKey = apiKey;

  /// Calcula la distancia de una ruta entre dos puntos.
  ///
  /// Antes de hacer una llamada a la API, revisa si el resultado ya está en caché.
  /// Si es así, devuelve el valor cacheado para mejorar la eficiencia.
  Future<double?> getRouteDistance({
    required List<double> start,
    required List<double> end,
  }) async {
    // Genera una clave única para la ruta.
    final cacheKey = '${start.join(',')}-${end.join(',')}';
    if (_cache.containsKey(cacheKey)) {
      debugPrint('Devolviendo distancia desde caché para: $cacheKey');
      return _cache[cacheKey];
    }

    debugPrint('Calculando distancia con API para: $cacheKey');
    final headers = {
      'Authorization': _apiKey,
      'Content-Type': 'application/json; charset=utf-8',
    };

    final body = jsonEncode({
      'coordinates': [start, end]
    });

    try {
      final response =
          await http.post(Uri.parse(_baseUrl), headers: headers, body: body);

      if (response.statusCode == 200) {
        // Imprimir la respuesta cruda de la API para depuración.
        debugPrint('Respuesta cruda de la API: ${response.body}');

        final data = jsonDecode(response.body);
        final features = data['features'] as List?;
        if (features != null && features.isNotEmpty) {
          final properties = features[0]['properties'] as Map<String, dynamic>?;
          final summary = properties?['summary'] as Map<String, dynamic>?;
          final distanceInMeters = summary?['distance'] as num?;

          if (distanceInMeters != null) {
            final distanceInKm = distanceInMeters / 1000.0;
            // Guarda el resultado en caché antes de devolverlo.
            _cache[cacheKey] = distanceInKm;
            return distanceInKm;
          }
        }
        debugPrint('OpenRouteService: No se pudo parsear la distancia.');
        return null;
      } else {
        debugPrint(
            'Error en OpenRouteService: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Excepción en OpenRouteService: $e');
      return null;
    }
  }
}
