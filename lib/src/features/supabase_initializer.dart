import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseInitializer {
  static Future<Session?> initialize() async {
    final supabaseUrl = dotenv.env['SUPABASE_URL'];
    final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];

    if (supabaseUrl == null || supabaseUrl.isEmpty) {
      throw Exception(
          'La variable SUPABASE_URL no está definida en el archivo .env');
    }
    if (supabaseAnonKey == null || supabaseAnonKey.isEmpty) {
      throw Exception(
          'La variable SUPABASE_ANON_KEY no está definida en el archivo .env');
    }

    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
      authFlowType: AuthFlowType.implicit, // set to implicit by default
      authCallbackUrlHostname: 'auth-callback',
    );

    // Use `initialSession` to obtain the initial session when the app starts.
    final initialSession = await Supabase.instance.client.auth.initialSession;
    return initialSession;
  }
}

// Acceso global al cliente de Supabase
final supabase = Supabase.instance.client;
