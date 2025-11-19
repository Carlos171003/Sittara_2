import 'package:flutter/material.dart';
import '../widgets/info_list.dart';
import '../widgets/specialties_card.dart';

// Pantalla de detalles para el restaurante Bistrola 57
class Bistrola57Screen extends StatelessWidget {
  const Bistrola57Screen({super.key});

  // Datos del restaurante
  final String name = 'Bistrola 57';
  final String tagline = 'Elegancia y Frescura';
  final String address =
      'C. 60 488 -x 57, Parque Santa Lucía, Centro, 97000 Mérida, Yuc.';
  final String hours = 'Lunes a Domingo: 7:00 AM - 11:00 PM';
  final String phone = '+52 999 123 4568';
  final List<String> specialties = const [
    'Cocina Bistró Francesa',
    'Opciones Vegetarianas',
    'Música en Vivo',
    'Ambiente Acogedor',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            name), // Título de la barra superior con el nombre del restaurante
      ),
      body: SafeArea(
        // Asegura que el contenido no se superponga con la barra de estado
        child: LayoutBuilder(
          // Permite construir la UI de forma responsiva
          builder: (context, constraints) {
            final bool isMobile =
                constraints.maxWidth < 820; // Determina si es una vista móvil

            return SingleChildScrollView(
              // Permite hacer scroll si el contenido es muy largo
              child: Column(
                crossAxisAlignment: CrossAxisAlignment
                    .stretch, // Estira los hijos horizontalmente
                children: [
                  // Sección: Encabezado del Restaurante (Imagen, Título y Eslogan)
                  AspectRatio(
                    // Mantiene la relación de aspecto de la imagen
                    aspectRatio: isMobile ? 16 / 9 : 3.5 / 1,
                    child: Stack(
                      // Permite apilar widgets uno encima del otro
                      fit: StackFit
                          .expand, // Expande los hijos para llenar el Stack
                      children: [
                        // Imagen del restaurante
                        Image.asset(
                          'assets/images/Bistrola 57.png', // Ruta de la imagen del restaurante
                          fit: BoxFit.cover, // Cubre el espacio disponible
                        ),
                        // Capa de degradado oscuro para mejorar el contraste del texto
                        Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors
                                    .black54, // Color oscuro con 54% de opacidad
                                Colors
                                    .black38, // Color oscuro con 38% de opacidad
                              ],
                            ),
                          ),
                        ),
                        // Título y subtítulo posicionados sobre la imagen
                        Positioned(
                          // Posiciona el widget en relación con el Stack
                          left:
                              isMobile ? 16 : 40, // Margen izquierdo responsivo
                          bottom:
                              isMobile ? 24 : 80, // Margen inferior responsivo
                          child: ConstrainedBox(
                            // Limita el ancho del texto
                            constraints: BoxConstraints(
                                maxWidth:
                                    isMobile ? constraints.maxWidth - 32 : 600),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment
                                  .start, // Alinea el texto a la izquierda
                              children: [
                                // Nombre del restaurante
                                Text(
                                  name,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: isMobile ? 28 : 48,
                                    fontWeight: FontWeight.w800,
                                    shadows: const [
                                      // Sombra para el texto
                                      Shadow(
                                          blurRadius: 8,
                                          offset: Offset(0, 2),
                                          color: Colors.black45),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 6), // Espacio vertical
                                // Eslogan del restaurante
                                Text(
                                  tagline,
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: isMobile ? 14 : 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24), // Espacio vertical

                  // Sección: Información de Contacto y Especialidades
                  Padding(
                    // Añade padding horizontal
                    padding:
                        EdgeInsets.symmetric(horizontal: isMobile ? 16 : 48),
                    child:
                        isMobile // Diseño responsivo: columna en móvil, fila en escritorio
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  InfoList(
                                      address: address,
                                      hours: hours,
                                      phone: phone), // Lista de información
                                  const SizedBox(
                                      height: 16), // Espacio vertical
                                  SpecialtiesCard(
                                      specialties:
                                          specialties), // Tarjeta de especialidades
                                  const SizedBox(
                                      height: 40), // Espacio vertical
                                ],
                              )
                            : Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Izquierda: lista de información, ocupa espacio flexible
                                  Expanded(
                                      flex: 3,
                                      child: InfoList(
                                          address: address,
                                          hours: hours,
                                          phone: phone)),

                                  const SizedBox(
                                      width: 32), // Espacio horizontal

                                  // Derecha: tarjeta de especialidades con ancho fijo
                                  ConstrainedBox(
                                    constraints:
                                        const BoxConstraints(maxWidth: 420),
                                    child: SpecialtiesCard(
                                        specialties: specialties),
                                  ),
                                ],
                              ),
                  ),

                  const SizedBox(height: 24), // Espacio vertical antes del menú
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
