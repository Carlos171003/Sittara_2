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

void main() {
  // Ensure Flutter widgets are initialized before running the app
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SittaraApp());
}

class SittaraApp extends StatefulWidget {
  const SittaraApp({super.key});

  @override
  State<SittaraApp> createState() => _SittaraAppState();
}

class _SittaraAppState extends State<SittaraApp> {
  // Future to represent the initialization process
  late final Future<void> _initialization;

  @override
  void initState() {
    super.initState();
    _initialization = _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      print("Initializing app...");
      // These are the async operations that were slowing down the start
      await dotenv.load(fileName: ".env");
      print("dotenv loaded");
      await SupabaseInitializer.initialize();
      print("Supabase initialized");
      print("App initialization complete.");
    } catch (e) {
      print("Error during app initialization: $e");
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initialization,
      builder: (context, snapshot) {
        print("FutureBuilder snapshot state: ${snapshot.connectionState}");
        // While waiting for initialization, show a loading screen
        if (snapshot.connectionState == ConnectionState.waiting) {
          print("FutureBuilder: waiting");
          return const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }

        // If initialization fails, show an error screen
        if (snapshot.hasError) {
          print("FutureBuilder: has error: ${snapshot.error}");
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              body: Center(
                child: Text(
                    'Error al inicializar la aplicación: ${snapshot.error}'),
              ),
            ),
          );
        }

        print("FutureBuilder: done, showing app");
        // Once initialization is complete, show the main app
        return ChangeNotifierProvider(
          create: (context) {
            final apiKey = dotenv.env['ORS_API_KEY'];
            if (apiKey == null || apiKey.isEmpty) {
              throw Exception('ORS_API_KEY no se encuentra en el archivo .env');
            }
            return DistanceProvider(apiKey: apiKey);
          },
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Sittara',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color.fromARGB(255, 138, 158, 141),
                brightness: Brightness.light,
              ),
              useMaterial3: true,
            ),
            initialRoute: '/login',
            routes: {
              '/login': (context) => const LoginScreen(),
              '/home': (context) => const HomeScreen(),
              '/menu': (context) => const MenuScreen(),
              '/bistrola57': (context) => const Bistrola57Screen(),
              '/location_request': (context) => const LocationRequestScreen(),
              '/nearby_restaurants': (context) {
                final Object? args = ModalRoute.of(context)?.settings.arguments;
                if (args is Position) {
                  return NearbyRestaurantsScreen(userLocation: args);
                }
                return const Scaffold(
                  body: Center(
                    child: Text('Error: Ubicación no proporcionada.'),
                  ),
                );
              },
            },
          ),
        );
      },
    );
  }
}
