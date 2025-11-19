import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'src/features/supabase_initializer.dart'; // Import SupabaseInitializer

import 'src/features/auth/presentation/screens/login_screen.dart';
import 'src/features/home/presentation/screens/menu_screen.dart';
import 'src/features/home/presentation/screens/home_screen.dart';
import 'src/features/home/presentation/screens/bistrola57_screen.dart';
import 'src/features/location_request_screen.dart';
import 'src/features/nearby_restaurants_screen.dart';

import 'package:provider/provider.dart'; // Importar provider
import 'package:flutter_application_24/src/features/distance_provider.dart'; // Importar DistanceProvider

Future<void> main() async {
  // Ensure Flutter widgets are initialized
  WidgetsFlutterBinding.ensureInitialized();
  // Cargar las variables de entorno desde .env
  await dotenv.load(fileName: ".env");

  // Initialize Supabase
  await SupabaseInitializer.initialize();

  runApp(
    ChangeNotifierProvider(
      // Envolver SittaraApp con ChangeNotifierProvider
      create: (context) => DistanceProvider(
        apiKey: dotenv.env['ORS_API_KEY']!, // Pasar la API Key desde .env
      ),
      child: const SittaraApp(),
    ),
  );
}

class SittaraApp extends StatelessWidget {
  const SittaraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sittara',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 138, 158, 141),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      // La ruta inicial vuelve a ser /login
      initialRoute: '/login',
      // Se restaura el sistema de rutas original
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/menu': (context) => const MenuScreen(),
        '/bistrola57': (context) => const Bistrola57Screen(),
        '/location_request': (context) => const LocationRequestScreen(),
        '/nearby_restaurants': (context) => NearbyRestaurantsScreen(
            userLocation:
                ModalRoute.of(context)!.settings.arguments as Position),
      },
    );
  }
}
