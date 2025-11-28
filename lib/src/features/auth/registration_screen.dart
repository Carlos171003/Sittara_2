import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'presentation/screens/verify_email_screen.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formSignupKey = GlobalKey<FormState>();
  bool agreePersonalData = true;

  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.fromLTRB(
              25.0, 20.0, 25.0, 20.0), // Adjusted top padding
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(40.0),
              topRight: Radius.circular(40.0),
            ),
          ),
          child: Form(
            key: _formSignupKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(
                    height: 30.0), // Added SizedBox for initial spacing
                // get started text
                Text(
                  'Empezar',
                  style: TextStyle(
                    fontSize: 30.0,
                    fontWeight: FontWeight.w900,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(
                  height: 40.0,
                ),
                // full name
                TextFormField(
                  controller: _fullNameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, ingrese su nombre completo';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    label: const Text('Nombre completo'),
                    hintText: 'Ingrese su nombre completo',
                    hintStyle: const TextStyle(
                      color: Colors.black26,
                    ),
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.black12, // Default border color
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.black12, // Default border color
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 25.0,
                ),
                // email
                TextFormField(
                  controller: _emailController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, ingrese su correo electrónico';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    label: const Text('Correo electrónico'),
                    hintText: 'Ingrese su correo electrónico',
                    hintStyle: const TextStyle(
                      color: Colors.black26,
                    ),
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.black12, // Default border color
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.black12, // Default border color
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 25.0,
                ),
                // password
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  obscuringCharacter: '*',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, ingrese su contraseña';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    label: const Text('Contraseña'),
                    hintText: 'Ingrese su contraseña',
                    hintStyle: const TextStyle(
                      color: Colors.black26,
                    ),
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.black12, // Default border color
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.black12, // Default border color
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 25.0,
                ),
                // i agree to the processing
                Row(
                  children: [
                    Checkbox(
                      value: agreePersonalData,
                      onChanged: (bool? value) {
                        setState(() {
                          agreePersonalData = value!;
                        });
                      },
                      activeColor: Theme.of(context).colorScheme.primary,
                    ),
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          text: 'Acepto el procesamiento de ',
                          style: const TextStyle(
                            color: Colors.black45,
                          ),
                          children: [
                            TextSpan(
                              text: 'Datos personales',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 25.0,
                ),
                // signup button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (!_formSignupKey.currentState!.validate()) {
                        return;
                      }
                      if (!agreePersonalData) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  'Por favor, acepte el procesamiento de datos personales')),
                        );
                        return;
                      }

                      // Show loading indicator
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) =>
                            const Center(child: CircularProgressIndicator()),
                      );

                      try {
                        final supabase = Supabase.instance.client;

                        // Obtener la URL de Supabase desde las variables de entorno
                        final supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
                        // Construir la URL de redirección usando la URL de Supabase
                        // Esto redirigirá a la app después de verificar el correo
                        final redirectUrl = supabaseUrl.isNotEmpty
                            ? '$supabaseUrl/auth/v1/callback'
                            : 'io.supabase.flutterquickstart://login-callback';

                        final authResponse = await supabase.auth.signUp(
                          email: _emailController.text.trim(),
                          password: _passwordController.text.trim(),
                          emailRedirectTo: redirectUrl,
                          data: {
                            'full_name': _fullNameController.text.trim(),
                          },
                        );

                        if (!context.mounted) return;

                        if (authResponse.user != null) {
                          // Insert full name into profiles table

                          await supabase.from('profiles').insert({
                            'id': authResponse.user!.id,
                            'full_name': _fullNameController.text.trim(),
                          });

                          if (!context.mounted) return;

                          // Hide loading indicator

                          Navigator.of(context).pop();

                          // Show success message

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'Registro exitoso. Por favor, revise su correo para la confirmación.'),
                                backgroundColor: Colors.green),
                          );

                          // Navigate to verify email screen
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => const VerifyEmailScreen(),
                            ),
                          );
                        }
                      } on AuthRetryableFetchException {
                        if (!context.mounted) return;
                        Navigator.of(context).pop(); // Hide loading indicator
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0)),
                            title: const Text('Error de Conexión',
                                textAlign: TextAlign.center),
                            content: Column(
                              // Changed to Column to allow error message
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.wifi_off,
                                    color: Colors.orangeAccent, size: 50),
                                const SizedBox(height: 20),
                                const Text(
                                  'No se pudo conectar al servidor. Por favor, revise su conexión a internet e inténtelo de nuevo.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.black54),
                                ),
                              ],
                            ),
                            actionsAlignment: MainAxisAlignment.center,
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('Aceptar'),
                              ),
                            ],
                          ),
                        );
                      } catch (e) {
                        if (!context.mounted) return;

                        // Hide loading indicator

                        Navigator.of(context).pop();

                        // Show error message

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('Error en el registro: $e'),
                              backgroundColor: Colors.red),
                        );
                      }
                    },
                    child: const Text('Registrarse'),
                  ),
                ),
                const SizedBox(
                  height: 30.0,
                ),
                // sign up divider
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Divider(
                        thickness: 0.7,
                        color: Colors.grey.withAlpha(128),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 0,
                        horizontal: 10,
                      ),
                      child: Text(
                        'Registrarse con',
                        style: TextStyle(
                          color: Colors.black45,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        thickness: 0.7,
                        color: Colors.grey.withAlpha(128),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 30.0,
                ),
                // sign up social media logo
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Icon(Bootstrap.facebook),
                    Icon(Bootstrap.twitter),
                    Icon(Bootstrap.google),
                    Icon(Bootstrap.apple),
                  ],
                ),
                const SizedBox(
                  height: 25.0,
                ),
                // already have an account
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      '¿Ya tienes una cuenta? ',
                      style: TextStyle(
                        color: Colors.black45,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/login');
                      },
                      child: Text(
                        'Iniciar sesión',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20.0,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
