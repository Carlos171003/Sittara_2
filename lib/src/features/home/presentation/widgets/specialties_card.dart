import 'package:flutter/material.dart';
import 'specialty_text.dart';

// Widget para mostrar la tarjeta de especialidades
class SpecialtiesCard extends StatelessWidget {
  final List<String> specialties;

  const SpecialtiesCard({super.key, required this.specialties}); // Constructor

  @override
  Widget build(BuildContext context) {
    return Card(
      // Tarjeta con elevación
      elevation: 6,
      shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.all(Radius.circular(12))), // Bordes redondeados
      child: Padding(
        padding: const EdgeInsets.all(20.0), // Padding interno
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start, // Alinea los hijos a la izquierda
          children: [
            const Text('Especialidades',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700)), // Título de especialidades
            const SizedBox(height: 12), // Espacio vertical
            // Mapea cada especialidad a una fila con un icono y texto
            ...specialties.map((s) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle,
                          color: Colors.green, size: 20), // Icono de check
                      const SizedBox(width: 10), // Espacio horizontal
                      Expanded(
                          child: SpecialtyText(
                              text: s,
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight
                                      .w600))), // Texto de la especialidad
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
