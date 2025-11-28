import 'package:supabase_flutter/supabase_flutter.dart';

/// Servicio para enviar notificaciones por correo electrónico usando Supabase Edge Functions
class EmailService {
  final SupabaseClient _supabase;

  EmailService({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  /// Envía un correo de confirmación de registro al usuario
  ///
  /// [userEmail] - Correo electrónico del usuario
  /// [userName] - Nombre completo del usuario
  ///
  /// Retorna true si el correo se envió exitosamente, false en caso contrario
  Future<bool> sendConfirmationEmail({
    required String userEmail,
    required String userName,
  }) async {
    try {
      // Llamar a la Edge Function de Supabase
      final response = await _supabase.functions.invoke(
        'send-confirmation-email',
        body: {
          'email': userEmail,
          'name': userName,
          'type': 'registration_confirmation',
        },
      );

      // Verificar si la respuesta fue exitosa
      if (response.status == 200) {
        return true;
      } else {
        print('Error al enviar correo: ${response.status} - ${response.data}');
        return false;
      }
    } catch (e) {
      print('Error al llamar a la Edge Function: $e');
      return false;
    }
  }

  /// Envía un correo genérico con contenido personalizado
  ///
  /// [userEmail] - Correo electrónico del usuario
  /// [subject] - Asunto del correo
  /// [htmlContent] - Contenido HTML del correo
  /// [textContent] - Contenido de texto plano del correo (opcional)
  Future<bool> sendCustomEmail({
    required String userEmail,
    required String subject,
    required String htmlContent,
    String? textContent,
  }) async {
    try {
      final response = await _supabase.functions.invoke(
        'send-email',
        body: {
          'email': userEmail,
          'subject': subject,
          'html': htmlContent,
          'text': textContent ?? '',
        },
      );

      if (response.status == 200) {
        return true;
      } else {
        print('Error al enviar correo: ${response.status} - ${response.data}');
        return false;
      }
    } catch (e) {
      print('Error al llamar a la Edge Function: $e');
      return false;
    }
  }
}
