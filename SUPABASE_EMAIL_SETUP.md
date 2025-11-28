# Configuración de Notificaciones por Correo con Supabase

Esta guía te explica cómo configurar Supabase para enviar correos electrónicos cuando se muestra la página de confirmación.

## Opción 1: Usar Edge Functions con Resend (Recomendado)

### Paso 1: Crear una cuenta en Resend

1. Ve a [https://resend.com](https://resend.com)
2. Crea una cuenta gratuita (incluye 3,000 correos/mes)
3. Obtén tu API Key desde el dashboard

### Paso 2: Crear la Edge Function en Supabase

1. Instala la CLI de Supabase (si no la tienes):
```bash
npm install -g supabase
```

2. Inicia sesión en Supabase:
```bash
supabase login
```

3. Vincula tu proyecto:
```bash
supabase link --project-ref tu-project-ref
```

4. Crea una nueva Edge Function:
```bash
supabase functions new send-confirmation-email
```

5. Edita el archivo `supabase/functions/send-confirmation-email/index.ts`:

```typescript
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const RESEND_API_KEY = Deno.env.get('RESEND_API_KEY')

serve(async (req) => {
  try {
    // Verificar que se proporcionó la API key
    if (!RESEND_API_KEY) {
      throw new Error('RESEND_API_KEY no está configurada')
    }

    // Obtener los datos del request
    const { email, name, type } = await req.json()

    if (!email || !name) {
      return new Response(
        JSON.stringify({ error: 'Email y nombre son requeridos' }),
        { status: 400, headers: { 'Content-Type': 'application/json' } }
      )
    }

    // Crear el contenido HTML del correo
    const htmlContent = `
      <!DOCTYPE html>
      <html>
        <head>
          <meta charset="utf-8">
          <style>
            body {
              font-family: Arial, sans-serif;
              line-height: 1.6;
              color: #333;
              max-width: 600px;
              margin: 0 auto;
              padding: 20px;
            }
            .header {
              background: linear-gradient(135deg, #ff0080 0%, #ff6b9d 100%);
              color: white;
              padding: 30px;
              text-align: center;
              border-radius: 10px 10px 0 0;
            }
            .content {
              background: #f9f9f9;
              padding: 30px;
              border-radius: 0 0 10px 10px;
            }
            .button {
              display: inline-block;
              background-color: #ff0080;
              color: white;
              padding: 12px 30px;
              text-decoration: none;
              border-radius: 25px;
              margin-top: 20px;
            }
          </style>
        </head>
        <body>
          <div class="header">
            <h1>🎉 ¡Felicidades! 🎉</h1>
          </div>
          <div class="content">
            <h2>Hola ${name},</h2>
            <p>Te has registrado correctamente en <strong>Sittara</strong> 🥳🥳</p>
            <p>Estamos emocionados de tenerte como parte de nuestra comunidad.</p>
            <p>Ahora puedes comenzar a explorar todos los restaurantes disponibles y hacer tus reservas.</p>
            <a href="#" class="button">Ir a la App</a>
            <p style="margin-top: 30px; color: #666; font-size: 12px;">
              Si no creaste esta cuenta, por favor ignora este correo.
            </p>
          </div>
        </body>
      </html>
    `

    // Enviar el correo usando Resend
    const resendResponse = await fetch('https://api.resend.com/emails', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${RESEND_API_KEY}`,
      },
      body: JSON.stringify({
        from: 'Sittara <onboarding@resend.dev>', // Cambia esto por tu dominio verificado
        to: [email],
        subject: '🎉 ¡Bienvenido a Sittara!',
        html: htmlContent,
      }),
    })

    if (!resendResponse.ok) {
      const error = await resendResponse.text()
      throw new Error(`Error al enviar correo: ${error}`)
    }

    const result = await resendResponse.json()

    return new Response(
      JSON.stringify({ 
        success: true, 
        message: 'Correo enviado exitosamente',
        id: result.id 
      }),
      { 
        status: 200, 
        headers: { 'Content-Type': 'application/json' } 
      }
    )

  } catch (error) {
    return new Response(
      JSON.stringify({ 
        error: error.message 
      }),
      { 
        status: 500, 
        headers: { 'Content-Type': 'application/json' } 
      }
    )
  }
})
```

6. Despliega la función:
```bash
supabase functions deploy send-confirmation-email
```

7. Configura la variable de entorno en Supabase:
   - Ve al dashboard de Supabase
   - Proyecto → Settings → Edge Functions
   - Agrega la variable `RESEND_API_KEY` con tu API key de Resend

## Opción 2: Usar Supabase Auth Email Templates

Si solo quieres enviar correos de verificación de email (no personalizados), puedes usar las plantillas de Supabase Auth:

1. Ve a tu proyecto en Supabase Dashboard
2. Authentication → Email Templates
3. Personaliza la plantilla de "Confirm signup"
4. Los correos se enviarán automáticamente cuando uses `supabase.auth.signUp()`

## Opción 3: Usar Database Triggers con pg_net

Si prefieres usar triggers de base de datos:

1. Crea una función en PostgreSQL que llame a un webhook
2. Crea un trigger que se active cuando se inserta un nuevo usuario
3. El webhook puede ser una Edge Function o un servicio externo

## Verificación

Para verificar que todo funciona:

1. Registra un nuevo usuario en tu app
2. Cuando se muestre la página de confirmación, se enviará el correo automáticamente
3. Revisa la bandeja de entrada del correo registrado

## Notas Importantes

- **Dominio de correo**: Para producción, necesitas verificar tu dominio en Resend
- **Límites**: El plan gratuito de Resend incluye 3,000 correos/mes
- **Seguridad**: Nunca expongas tu API key en el código del cliente
- **Testing**: Puedes usar `onboarding@resend.dev` para pruebas (solo funciona en desarrollo)

## Solución de Problemas

### Error: "RESEND_API_KEY no está configurada"
- Asegúrate de haber configurado la variable de entorno en Supabase Dashboard

### Error: "Edge Function not found"
- Verifica que hayas desplegado la función correctamente
- Verifica que el nombre de la función coincida exactamente

### El correo no llega
- Revisa la carpeta de spam
- Verifica que el correo esté correctamente escrito
- Revisa los logs de la Edge Function en Supabase Dashboard

