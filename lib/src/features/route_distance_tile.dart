import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_24/src/features/distance_provider.dart';

class RouteDistanceTile extends StatelessWidget {
  final String title;
  final String routeKey; // Ahora recibe la routeKey directamente

  const RouteDistanceTile({
    super.key,
    required this.title,
    required this.routeKey,
  });

  String _formatDistance(double? distance) {
    if (distance == null) {
      return 'Error'; // Mostrar "Error" si la distancia es null
    } else if (distance < 1000) {
      return '${distance.toStringAsFixed(0)} m';
    } else {
      return '${(distance / 1000).toStringAsFixed(1)} km';
    }
  }

  @override
  Widget build(BuildContext context) {
    final distanceProvider = Provider.of<DistanceProvider>(context);
    final distance = distanceProvider.getDistance(routeKey);
    final isLoadingDistance = distanceProvider.isLoading(routeKey);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const SizedBox(width: 16),
            isLoadingDistance
                ? const CircularProgressIndicator()
                : Text(
                    _formatDistance(distance),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                  ),
          ],
        ),
      ),
    );
  }
}
