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
    // These are the async operations that were slowing down the start
    await dotenv.load(fileName: ".env");
    await SupabaseInitializer.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initialization,
      builder: (context, snapshot) {
        // While waiting for initialization, show a loading screen
        if (snapshot.connectionState == ConnectionState.waiting) {
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

        // Once initialization is complete, show the main app
        return ChangeNotifierProvider(
          create: (context) => DistanceProvider(
            apiKey: dotenv.env['ORS_API_KEY']!,
          ),
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
              '/nearby_restaurants': (context) => NearbyRestaurantsScreen(
                  userLocation:
                      ModalRoute.of(context)!.settings.arguments as Position),
            },
          ),
        );
      },
    );
  }
}
