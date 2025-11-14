import 'package:flutter/material.dart';
import 'src/features/auth/presentation/screens/login_screen.dart';
import 'src/features/home/presentation/screens/menu_screen.dart';
import 'src/features/home/presentation/screens/home_screen.dart';
import 'src/features/home/presentation/screens/bistrola57_screen.dart'; // New import


void main() => runApp(const SittaraApp());

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
          brightness: Brightness.light, // Assuming a light theme
        ),
        useMaterial3: true, // Use Material 3 design
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/menu': (context) => const MenuScreen(),
        '/bistrola57': (context) => const Bistrola57Screen(), // New route
      },
    );
  }
}