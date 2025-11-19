import 'package:flutter/material.dart';

// Widget para mostrar la lista de información (dirección, horario, teléfono)
class InfoList extends StatelessWidget {
  final String address;
  final String hours;
  final String phone;

  const InfoList(
      {super.key,
      required this.address,
      required this.hours,
      required this.phone}); // Constructor

  // Crea una fila con un icono y contenido de texto
  Widget _row(IconData icon, Widget content) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Contenedor circular para el icono
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
                color: Color(0xFFE8F5E9), shape: BoxShape.circle),
            child: Icon(icon, color: Colors.green, size: 18), // Icono
          ),
          const SizedBox(width: 14), // Espacio horizontal
          Expanded(
              child: content), // Contenido de texto, ocupa el espacio restante
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start, // Alinea los hijos a la izquierda
      children: [
        _row(
            Icons.location_on,
            Text(address,
                style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF212121)))), // Fila de dirección
        _row(
            Icons.access_time,
            Text(hours,
                style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF212121)))), // Fila de horario
        _row(
            Icons.phone,
            Text(phone,
                style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF212121)))), // Fila de teléfono
      ],
    );
  }
}
