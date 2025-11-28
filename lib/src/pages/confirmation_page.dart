import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:math' hide log; // ocultamos log() de math
import 'dart:developer'; // usamos log() de developer
import '../features/email/email_service.dart';

class ConfirmationPage extends StatefulWidget {
  const ConfirmationPage({super.key});

  @override
  State<ConfirmationPage> createState() => _ConfirmationPageState();
}

class _ConfirmationPageState extends State<ConfirmationPage> {
  late ConfettiController _confettiController;
  final EmailService _emailService = EmailService();

  // Datos del usuario desde Supabase
  String _userName = 'Usuario';
  String _userEmail = '';
  bool _isLoading = true;
  DateTime? _createdAt;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 5));
    _confettiController.play();

    // Cargar datos del usuario desde Supabase
    _loadUserData();
    _sendConfirmationEmail();
  }

  /// Carga los datos del usuario desde Supabase
  Future<void> _loadUserData() async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;

      if (user != null) {
        setState(() {
          _userEmail = user.email ?? '';
          // Usar la fecha actual como predeterminada
          _createdAt = DateTime.now();
        });

        // Obtener el nombre del usuario desde el perfil
        try {
          final profileResponse = await supabase
              .from('profiles')
              .select('full_name, created_at')
              .eq('id', user.id)
              .single();

          if (mounted) {
            setState(() {
              if (profileResponse['full_name'] != null) {
                _userName = profileResponse['full_name'] as String;
              } else {
                _userName = _userEmail.split('@')[0];
              }

              // Intentar obtener la fecha del perfil si está disponible
              if (profileResponse['created_at'] != null) {
                try {
                  final profileDate = profileResponse['created_at'];
                  if (profileDate is String) {
                    _createdAt = DateTime.parse(profileDate);
                  } else if (profileDate is DateTime) {
                    _createdAt = profileDate;
                  }
                } catch (e) {
                  log('Error al parsear fecha del perfil: $e');
                }
              }

              _isLoading = false;
            });
          }
        } catch (e) {
          log('Error al obtener el perfil: $e');
          // Si no hay perfil, usar el email como nombre
          if (mounted) {
            setState(() {
              _userName = _userEmail.split('@')[0];
              _isLoading = false;
            });
          }
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      log('Error al cargar datos del usuario: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Envía el correo de confirmación al usuario
  Future<void> _sendConfirmationEmail() async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;

      if (user != null && user.email != null) {
        // Usar el nombre ya cargado o obtenerlo si no está disponible
        String userName = _userName;

        if (userName == 'Usuario') {
          try {
            final profileResponse = await supabase
                .from('profiles')
                .select('full_name')
                .eq('id', user.id)
                .single();

            if (profileResponse['full_name'] != null) {
              userName = profileResponse['full_name'] as String;
            } else {
              userName = user.email!.split('@')[0];
            }
          } catch (e) {
            log('Error al obtener el perfil: $e');
            userName = user.email!.split('@')[0];
          }
        }

        final success = await _emailService.sendConfirmationEmail(
          userEmail: user.email!,
          userName: userName,
        );

        if (success) {
          log('Correo de confirmación enviado exitosamente');
        } else {
          log('Error al enviar correo de confirmación');
        }
      }
    } catch (e) {
      log('Error al enviar correo de confirmación: $e');
    }
  }

  /// Formatea la fecha de creación del usuario
  String _formatDate(DateTime date) {
    final months = [
      'enero',
      'febrero',
      'marzo',
      'abril',
      'mayo',
      'junio',
      'julio',
      'agosto',
      'septiembre',
      'octubre',
      'noviembre',
      'diciembre'
    ];
    return '${date.day} de ${months[date.month - 1]} de ${date.year}';
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const pinkColor = Color(0xffff0080);
    const textShadow = [
      Shadow(
        blurRadius: 10.0,
        color: Colors.black,
        offset: Offset(2.0, 2.0),
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: pi / 2,
              minBlastForce: 20,
              maxBlastForce: 50,
              emissionFrequency: 0.05,
              numberOfParticles: 15,
              gravity: 0.1,
              colors: const [
                Colors.pink,
                Colors.white,
                Colors.pinkAccent,
              ],
            ),
          ),
          SafeArea(
            child: Center(
              child: _isLoading
                  ? const CircularProgressIndicator(
                      color: pinkColor,
                    )
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            '🎉 ¡Felicidades! 🎉',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: pinkColor,
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              shadows: textShadow,
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Mostrar nombre personalizado del usuario
                          Text(
                            '¡Hola, $_userName!',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: pinkColor,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              shadows: textShadow,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Te has registrado correctamente en Sittara 🥳🥳',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              shadows: textShadow,
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Mostrar información adicional del usuario
                          if (_userEmail.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: pinkColor.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.email_outlined,
                                    color: Colors.white70,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _userEmail,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (_createdAt != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Miembro desde ${_formatDate(_createdAt!)}',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 12,
                              ),
                            ),
                          ],
                          const SizedBox(height: 40),
                          FractionallySizedBox(
                            widthFactor: 0.6,
                            child: Image.asset(
                              'assets/images/Sittararemove.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(height: 50),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: pinkColor,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 50, vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                              elevation: 5,
                            ),
                            onPressed: () {
                              Navigator.pushNamed(context, '/login');
                            },
                            child: const Text(
                              'Ir al Login',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
