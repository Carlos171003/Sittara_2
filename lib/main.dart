import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'src/features/supabase_initializer.dart';
import 'package:app_links/app_links.dart';

import 'src/features/auth/presentation/screens/login_screen.dart';
import 'src/features/auth/presentation/screens/auth_callback_screen.dart';
import 'src/features/home/presentation/screens/menu_screen.dart';
import 'src/features/home/presentation/screens/home_screen.dart';
import 'src/features/home/presentation/screens/bistrola57_screen.dart';
import 'src/features/home/presentation/screens/opiniones_screen.dart';
import 'src/features/home/presentation/screens/notificaciones_screen.dart';
import 'src/features/location_request_screen.dart';
import 'src/features/nearby_restaurants_screen.dart';

import 'package:flutter_application_24/src/features/reserva/reserva_page.dart';
import 'package:flutter_application_24/src/pages/confirmation_page.dart';

import 'package:provider/provider.dart';
import 'package:flutter_application_24/src/features/distance_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';
import 'dart:developer';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SittaraApp());
}

class SittaraApp extends StatefulWidget {
  const SittaraApp({super.key});

  @override
  State<SittaraApp> createState() => _SittaraAppState();
}

class _SittaraAppState extends State<SittaraApp> {
  late final Future<Session?> _initialization;
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _appLinksSubscription;

  @override
  void initState() {
    super.initState();
    _initialization = _initializeApp();
    _initDeepLinks();
  }

  @override
  void dispose() {
    _appLinksSubscription?.cancel();
    super.dispose();
  }

  Future<Session?> _initializeApp() async {
    try {
      log("Initializing app...", name: "INIT");
      await dotenv.load(fileName: ".env");
      log("dotenv loaded", name: "INIT");
      final session = await SupabaseInitializer.initialize();
      log("Supabase initialized", name: "INIT");
      log("App initialization complete.", name: "INIT");
      return session;
    } catch (e) {
      log("Error during app initialization: $e", name: "INIT");
      rethrow;
    }
  }

  Future<void> _initDeepLinks() async {
    _appLinks = AppLinks();

    final appLink = await _appLinks.getInitialLink();
    if (appLink != null) {
      _handleDeepLink(appLink);
    }

    _appLinksSubscription = _appLinks.uriLinkStream.listen((uri) {
      _handleDeepLink(uri);
    });
  }

  Future<void> _handleDeepLink(Uri uri) async {
    log("Deep Link received: $uri", name: "DEEPLINK");

    if (uri.scheme == 'io.supabase.flutterquickstart' &&
        uri.host == 'login-callback') {
      try {
        await Supabase.instance.client.auth.getSessionFromUrl(uri);
        navigatorKey.currentState
            ?.pushNamedAndRemoveUntil('/auth-callback', (route) => false);
      } catch (e) {
        log("Error handling deep link: $e", name: "DEEPLINK");
        navigatorKey.currentState
            ?.pushNamedAndRemoveUntil('/auth-callback', (route) => false);
      }
    } else if (uri.toString().contains('supabase.co') &&
        uri.queryParameters.containsKey('token')) {
      try {
        await Supabase.instance.client.auth.getSessionFromUrl(uri);
        navigatorKey.currentState
            ?.pushNamedAndRemoveUntil('/auth-callback', (route) => false);
      } catch (e) {
        log("Email verification deep link error: $e", name: "DEEPLINK");
        navigatorKey.currentState
            ?.pushNamedAndRemoveUntil('/auth-callback', (route) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Session?>(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          log("FutureBuilder: waiting", name: "INIT");
          return const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        if (snapshot.hasError) {
          log("FutureBuilder: error ${snapshot.error}", name: "INIT");
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

        log("FutureBuilder: done — loading app", name: "INIT");

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
            navigatorKey: navigatorKey,
            initialRoute: snapshot.data == null ? '/login' : '/home',
            routes: {
              '/login': (_) => const LoginScreen(),
              '/home': (_) => const HomeScreen(),
              '/menu': (_) => const MenuScreen(),
              '/bistrola57': (_) => const Bistrola57Screen(),
              '/opiniones': (_) => const OpinionesScreen(),
              '/notificaciones': (_) => const NotificacionesScreen(),
              '/auth-callback': (_) => const AuthCallbackScreen(),
              '/location_request': (_) => const LocationRequestScreen(),
              '/nearby_restaurants': (context) {
                final args = ModalRoute.of(context)?.settings.arguments;
                if (args is Position) {
                  return NearbyRestaurantsScreen(userLocation: args);
                }
                return const Scaffold(
                  body: Center(
                    child: Text('Error: Ubicación no proporcionada.'),
                  ),
                );
              },
              '/reserva': (_) => const ReservaPage(),
              '/congratulations': (_) => const ConfirmationPage(),
            },
          ),
        );
      },
    );
  }
}
