import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../../reserva/reserva_page.dart'; // Import the new ReservaPage

class _MenuItemWidget extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  const _MenuItemWidget({
    required this.icon,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.black, size: 30),
      title: Text(
        text,
        style: const TextStyle(fontSize: 18, color: Colors.black),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(vertical: 16),
    );
  }
}

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.grey[100],
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _MenuItemWidget(
                icon: Icons.home,
                text: 'Inicio',
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              _MenuItemWidget(
                icon: Icons.location_on,
                text: 'Mi Ubicación',
                onTap: () async {
                  LocationPermission permission =
                      await Geolocator.checkPermission();

                  if (permission == LocationPermission.denied ||
                      permission == LocationPermission.deniedForever) {
                    // Si los permisos no están concedidos, navegar a la pantalla de solicitud de ubicación

                    if (!context.mounted) return;

                    Navigator.pushNamed(context, '/location_request');
                  } else {
                    try {
                      Position position = await Geolocator.getCurrentPosition(
                        locationSettings: const LocationSettings(
                          accuracy: LocationAccuracy.high,

                          distanceFilter:
                              100, // Opcional: distancia mínima para actualizar la ubicación
                        ),
                      );

                      // Navegar a la pantalla de restaurantes cercanos, pasando la ubicación

                      if (!context.mounted) return;

                      Navigator.pushNamed(
                        context,
                        '/nearby_restaurants',
                        arguments: position,
                      );
                    } catch (e) {
                      // Manejar errores al obtener la ubicación

                      if (!context.mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('Error al obtener la ubicación: $e')),
                      );
                    }
                  }
                },
              ),
              _MenuItemWidget(
                icon: Icons.calendar_today,
                text: 'Generar Reserva',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const ReservaPage(),
                    ),
                  );
                },
              ),
              _MenuItemWidget(
                icon: Icons.chat_bubble,
                text: 'Opiniones',
                onTap: () {},
              ),
              _menuItemNotificaciones(),
              const SizedBox(height: 24), // Added SizedBox for spacing
              _MenuItemWidget(
                icon: Icons.logout,
                text: 'Cerrar Sesión',
                onTap: () {
                  Navigator.pushReplacementNamed(context, '/login');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _menuItemNotificaciones() {
    return ListTile(
      leading: Stack(
        clipBehavior: Clip.none,
        children: [
          const Icon(Icons.mail, color: Colors.black, size: 30),
          Positioned(
            right: -2,
            top: -2,
            child: Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
      title: const Text(
        'Notificaciones',
        style: TextStyle(fontSize: 18, color: Colors.black),
      ),
      onTap: () {},
      contentPadding: const EdgeInsets.symmetric(vertical: 16),
    );
  }
}
