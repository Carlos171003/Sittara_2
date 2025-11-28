import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthCallbackScreen extends StatefulWidget {
  const AuthCallbackScreen({super.key});

  @override
  State<AuthCallbackScreen> createState() => _AuthCallbackScreenState();
}

class _AuthCallbackScreenState extends State<AuthCallbackScreen> {
  bool _isVerifying = true;
  bool _isVerified = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _verificarEmail();
  }

  Future<void> _verificarEmail() async {
    try {
      final supabase = Supabase.instance.client;

      // Primero intentar obtener la sesión actual
      Session? session = supabase.auth.currentSession;

      // Consultar directamente el estado del usuario en Supabase
      // Verificar si el email está confirmado consultando la base de datos
      try {
        // Obtener información actualizada del usuario desde Supabase
        final userResponse = await supabase.auth.getUser();

        if (userResponse.user != null) {
          final currentUser = userResponse.user!;

          // Verificar directamente si el email está confirmado
          if (currentUser.emailConfirmedAt != null) {
            setState(() {
              _isVerified = true;
              _isVerifying = false;
            });
            return;
          }

          // Si no está confirmado, intentar refrescar la sesión para obtener el estado más reciente
          if (session != null) {
            await supabase.auth.refreshSession();
            final refreshedSession = supabase.auth.currentSession;

            if (refreshedSession != null) {
              final refreshedUser = refreshedSession.user;

              // Verificar nuevamente después del refresh
              if (refreshedUser.emailConfirmedAt != null) {
                setState(() {
                  _isVerified = true;
                  _isVerifying = false;
                });
                return;
              }
            }
          }

          // Si aún no está confirmado, consultar directamente desde la base de datos
          // Esperar un momento y verificar nuevamente (el usuario puede haber verificado mientras tanto)
          await Future.delayed(const Duration(seconds: 2));

          final finalUserResponse = await supabase.auth.getUser();
          if (finalUserResponse.user?.emailConfirmedAt != null) {
            setState(() {
              _isVerified = true;
              _isVerifying = false;
            });
            return;
          }

          // Si llegamos aquí, el correo aún no está verificado
          setState(() {
            _isVerified = false;
            _isVerifying = false;
            _errorMessage =
                'El correo aún no ha sido verificado. Por favor, revisa tu correo electrónico y haz clic en el enlace de confirmación.';
          });
        } else {
          // No hay usuario, el usuario necesita verificar primero
          setState(() {
            _isVerified = false;
            _isVerifying = false;
            _errorMessage =
                'No se encontró un usuario. Por favor, verifica tu correo electrónico haciendo clic en el enlace que te enviamos.';
          });
        }
      } catch (e) {
        print('Error al consultar estado del usuario: $e');
        setState(() {
          _isVerified = false;
          _isVerifying = false;
          _errorMessage =
              'Error al verificar el estado del correo. Por favor, intenta iniciar sesión.';
        });
      }
    } catch (e) {
      print('Error general al verificar: $e');
      setState(() {
        _isVerified = false;
        _isVerifying = false;
        _errorMessage = 'Error al verificar: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isVerifying) ...[
                const CircularProgressIndicator(),
                const SizedBox(height: 32),
                const Text(
                  'Verificando tu correo...',
                  style: TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
              ] else if (_isVerified) ...[
                const Icon(
                  Icons.check_circle_outline,
                  color: Colors.green,
                  size: 100,
                ),
                const SizedBox(height: 32),
                const Text(
                  '¡Cuenta Autenticada!',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Tu correo ha sido verificado exitosamente. Ya puedes iniciar sesión.',
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                ElevatedButton(
                  onPressed: () {
                    // Cerrar sesión para que el usuario pueda iniciar sesión con sus credenciales
                    Supabase.instance.client.auth.signOut();
                    // Navegar a la pantalla de login
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      '/login',
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Ir a Iniciar Sesión',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ] else ...[
                const Icon(
                  Icons.error_outline,
                  color: Colors.orange,
                  size: 100,
                ),
                const SizedBox(height: 32),
                const Text(
                  'Verificación Pendiente',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  _errorMessage ??
                      'No se pudo verificar tu correo. Por favor, revisa tu correo electrónico y haz clic en el enlace de confirmación.',
                  style: const TextStyle(fontSize: 16, color: Colors.black54),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      '/login',
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Ir a Iniciar Sesión',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
