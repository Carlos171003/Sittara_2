import 'package:flutter/material.dart';
import 'package:flutter_application_24/src/features/location_service.dart';

class LocationRequestScreen extends StatefulWidget {
  const LocationRequestScreen({super.key});

  @override
  State<LocationRequestScreen> createState() => _LocationRequestScreenState();
}

class _LocationRequestScreenState extends State<LocationRequestScreen> {
  bool _isLoading = false;

  Future<void> _requestLocation() async {
    setState(() {
      _isLoading = true;
    });

    final locationService = LocationService();
    final position = await locationService.getCurrentLocation(context);

    setState(() {
      _isLoading = false;
    });

    if (position != null) {
      // Ubicación obtenida con éxito. Navegar a NearbyRestaurantsScreen
      if (!mounted) {
        return; // Evitar errores si el widget ya no está en el árbol
      }
      Navigator.of(context).pushReplacementNamed(
        '/nearby_restaurants',
        arguments: position, // Pasar la posición como argumento
      );
    } else {
      // Si position es null, LocationService ya mostró un diálogo específico
      // (denegado, permanentemente denegado, GPS apagado).
      // Aquí solo mostramos un mensaje genérico si no se mostró un diálogo específico.
      // Esto es más bien un fallback, ya que LocationService debería manejar la mayoría de los casos.
      if (!mounted) {
        return; // Evitar errores si el widget ya no está en el árbol
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo obtener la ubicación.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ubicación Requerida'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(
              Icons.location_on,
              size: 100,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 32),
            Text(
              "Para mostrarte los restaurantes más cercanos, necesitamos tu ubicación.",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
            const SizedBox(height: 48),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton.icon(
                    onPressed: _requestLocation,
                    icon: const Icon(Icons.my_location),
                    label: const Text(
                      "Activar ubicación",
                      style: TextStyle(fontSize: 18),
                    ),
                    style: ElevatedButton.styleFrom(
                      minimumSize:
                          const Size(double.infinity, 60), // Botón grande
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
