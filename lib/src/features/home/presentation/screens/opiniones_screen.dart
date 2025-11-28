import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OpinionesScreen extends StatefulWidget {
  const OpinionesScreen({super.key});

  @override
  State<OpinionesScreen> createState() => _OpinionesScreenState();
}

class _OpinionesScreenState extends State<OpinionesScreen> {
  final TextEditingController _opinionController = TextEditingController();
  final List<Map<String, dynamic>> _opiniones = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarOpiniones();
  }

  @override
  void dispose() {
    _opinionController.dispose();
    super.dispose();
  }

  Future<void> _cargarOpiniones() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;

      if (user != null) {
        // Cargar opiniones desde Supabase (asumiendo que existe una tabla 'opiniones')
        final response = await supabase
            .from('opiniones')
            .select('*, profiles(full_name)')
            .order('created_at', ascending: false)
            .limit(50);

        if (mounted) {
          setState(() {
            _opiniones.clear();
            _opiniones.addAll(List<Map<String, dynamic>>.from(response));
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      // Si la tabla no existe, usar datos de ejemplo
      if (mounted) {
        setState(() {
          _opiniones.clear();
          _opiniones.addAll([
            {
              'id': '1',
              'restaurant_name': 'Bistrola 57',
              'rating': 5,
              'comment': 'Excelente comida y servicio. Muy recomendado.',
              'user_name': 'Usuario Ejemplo',
              'created_at': DateTime.now()
                  .subtract(const Duration(days: 2))
                  .toIso8601String(),
            },
            {
              'id': '2',
              'restaurant_name': 'Teya Santa Lucía',
              'rating': 4,
              'comment':
                  'Buen ambiente y comida tradicional yucateca deliciosa.',
              'user_name': 'Otro Usuario',
              'created_at': DateTime.now()
                  .subtract(const Duration(days: 5))
                  .toIso8601String(),
            },
          ]);
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _enviarOpinion() async {
    if (_opinionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, escribe tu opinión'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;

      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Debes iniciar sesión para publicar una opinión'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Intentar guardar en Supabase
      try {
        await supabase.from('opiniones').insert({
          'user_id': user.id,
          'comment': _opinionController.text.trim(),
          'rating': 5, // Por defecto, se puede mejorar con un selector
          'created_at': DateTime.now().toIso8601String(),
        });

        _opinionController.clear();
        _cargarOpiniones();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Opinión publicada exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        // Si falla, agregar localmente
        setState(() {
          _opiniones.insert(0, {
            'id': DateTime.now().millisecondsSinceEpoch.toString(),
            'restaurant_name': 'Restaurante',
            'rating': 5,
            'comment': _opinionController.text.trim(),
            'user_name': 'Tú',
            'created_at': DateTime.now().toIso8601String(),
          });
        });

        _opinionController.clear();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Opinión agregada (modo local)'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al publicar opinión: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Opiniones'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Sección para escribir opinión
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Comparte tu experiencia',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _opinionController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Escribe tu opinión sobre el restaurante...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _enviarOpinion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Publicar Opinión',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          // Lista de opiniones
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _opiniones.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.chat_bubble_outline,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No hay opiniones aún',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Sé el primero en compartir tu experiencia',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _opiniones.length,
                        itemBuilder: (context, index) {
                          final opinion = _opiniones[index];
                          final userName = opinion['profiles'] != null
                              ? opinion['profiles']['full_name']
                              : opinion['user_name'] ?? 'Usuario';
                          final comment = opinion['comment'] ?? '';
                          final rating = opinion['rating'] ?? 5;
                          final createdAt = opinion['created_at'] != null
                              ? DateTime.tryParse(opinion['created_at'])
                              : null;

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          userName,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Row(
                                        children: List.generate(5, (i) {
                                          return Icon(
                                            i < rating
                                                ? Icons.star
                                                : Icons.star_border,
                                            color: Colors.amber,
                                            size: 18,
                                          );
                                        }),
                                      ),
                                    ],
                                  ),
                                  if (createdAt != null) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      _formatearFecha(createdAt),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 12),
                                  Text(
                                    comment,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  String _formatearFecha(DateTime fecha) {
    final ahora = DateTime.now();
    final diferencia = ahora.difference(fecha);

    if (diferencia.inDays == 0) {
      if (diferencia.inHours == 0) {
        return 'Hace ${diferencia.inMinutes} minutos';
      }
      return 'Hace ${diferencia.inHours} horas';
    } else if (diferencia.inDays == 1) {
      return 'Ayer';
    } else if (diferencia.inDays < 7) {
      return 'Hace ${diferencia.inDays} días';
    } else {
      return '${fecha.day}/${fecha.month}/${fecha.year}';
    }
  }
}
