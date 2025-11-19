import 'dart:io'; // Importar para Platform
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart'; // Necesario para mostrar diálogos

class LocationService {
  /// Verifica y solicita permisos de ubicación, y obtiene la posición actual del usuario.
  ///
  /// Retorna un [Position] si la ubicación se obtiene con éxito, o null si hay un error
  /// o el usuario deniega los permisos.
  Future<Position?> getCurrentLocation(BuildContext context) async {
    // 1. Revisar y pedir permisos de ubicación
    PermissionStatus permission = await Permission.locationWhenInUse.status;

    if (permission.isDenied) {
      permission = await Permission.locationWhenInUse.request();
      if (permission.isDenied) {
        // El usuario denegó los permisos, no podemos continuar
        if (!context.mounted) return null;
        _showPermissionDeniedDialog(context);
        return null;
      }
    }

    if (permission.isPermanentlyDenied) {
      if (!context.mounted) return null;
      _showPermissionPermanentlyDeniedDialog(context);
      return null;
    }

    // 2. Verificar si el GPS está activado
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (!context.mounted) return null;
      // El GPS está apagado, mostrar diálogo para activarlo
      bool? enable = await _showLocationServiceDisabledDialog(context);
      if (enable == null || !enable) {
        // El usuario decidió no activar el GPS
        return null;
      }
      // Si el usuario activó el GPS, esperamos un momento y volvemos a verificar
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Si aún no está activado, no podemos continuar
        return null;
      }
    }

    // 3. Regresar las coordenadas actuales del usuario
    try {
      LocationSettings locationSettings;

      if (Platform.isAndroid) {
        locationSettings = AndroidSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 0,
          forceLocationManager: true,
          intervalDuration: const Duration(seconds: 10),
          // Más configuraciones específicas de Android si son necesarias
        );
      } else if (Platform.isIOS) {
        locationSettings = AppleSettings(
          accuracy: LocationAccuracy.high,
          activityType: ActivityType.fitness,
          distanceFilter: 0,
          pauseLocationUpdatesAutomatically: true,
          // Más configuraciones específicas de iOS si son necesarias
        );
      } else {
        locationSettings = const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 0,
        );
      }

      return await Geolocator.getCurrentPosition(
        locationSettings: locationSettings,
      );
    } catch (e) {
      debugPrint('Error al obtener la ubicación: $e');
      if (!context.mounted) return null;
      _showErrorGettingLocationDialog(context);
      return null;
    }
  }

  void _showPermissionDeniedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Permiso de ubicación denegado'),
          content: const Text(
              'Necesitamos acceso a tu ubicación para mostrar el mapa. Por favor, concede el permiso.'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showPermissionPermanentlyDeniedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Permiso de ubicación denegado permanentemente'),
          content: const Text(
              'El permiso de ubicación ha sido denegado permanentemente. Por favor, ve a la configuración de la aplicación para activarlo manualmente.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Ir a Configuración'),
              onPressed: () {
                openAppSettings(); // Abre la configuración de la aplicación
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<bool?> _showLocationServiceDisabledDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Servicio de ubicación desactivado'),
          content: const Text(
              'Tu servicio de ubicación (GPS) está desactivado. ¿Deseas activarlo?'),
          actions: <Widget>[
            TextButton(
              child: const Text('No'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: const Text('Sí'),
              onPressed: () async {
                Navigator.of(context).pop(true);
                await Geolocator
                    .openLocationSettings(); // Abre la configuración de ubicación
              },
            ),
          ],
        );
      },
    );
  }

  void _showErrorGettingLocationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error de ubicación'),
          content: const Text(
              'No se pudo obtener tu ubicación actual. Por favor, inténtalo de nuevo.'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
