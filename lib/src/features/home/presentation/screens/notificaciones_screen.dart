import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificacionesScreen extends StatefulWidget {
  const NotificacionesScreen({super.key});

  @override
  State<NotificacionesScreen> createState() => _NotificacionesScreenState();
}

class _NotificacionesScreenState extends State<NotificacionesScreen> {
  final List<Map<String, dynamic>> _notificaciones = [];
  bool _isLoading = true;
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _cargarNotificaciones();
  }

  Future<void> _cargarNotificaciones() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;

      if (user != null) {
        // Intentar cargar notificaciones desde Supabase
        try {
          final response = await supabase
              .from('notificaciones')
              .select('*')
              .eq('user_id', user.id)
              .order('created_at', ascending: false)
              .limit(50);

          if (mounted) {
            setState(() {
              _notificaciones.clear();
              _notificaciones.addAll(List<Map<String, dynamic>>.from(response));
              _unreadCount =
                  _notificaciones.where((n) => n['leida'] == false).length;
              _isLoading = false;
            });
          }
        } catch (e) {
          // Si la tabla no existe, usar datos de ejemplo
          _cargarNotificacionesEjemplo();
        }
      } else {
        _cargarNotificacionesEjemplo();
      }
    } catch (e) {
      _cargarNotificacionesEjemplo();
    }
  }

  void _cargarNotificacionesEjemplo() {
    if (mounted) {
      setState(() {
        _notificaciones.clear();
        _notificaciones.addAll([
          {
            'id': '1',
            'titulo': 'Reserva Confirmada',
            'mensaje':
                'Tu reserva en Bistrola 57 para el 15 de diciembre a las 20:00 ha sido confirmada.',
            'tipo': 'reserva',
            'leida': false,
            'created_at': DateTime.now()
                .subtract(const Duration(hours: 2))
                .toIso8601String(),
          },
          {
            'id': '2',
            'titulo': 'Nuevo Restaurante',
            'mensaje':
                'Hemos agregado un nuevo restaurante cerca de ti: Pita Mediterránea.',
            'tipo': 'nuevo',
            'leida': false,
            'created_at': DateTime.now()
                .subtract(const Duration(days: 1))
                .toIso8601String(),
          },
          {
            'id': '3',
            'titulo': 'Recordatorio de Reserva',
            'mensaje':
                'Recuerda que tienes una reserva mañana en Teya Santa Lucía a las 19:00.',
            'tipo': 'recordatorio',
            'leida': true,
            'created_at': DateTime.now()
                .subtract(const Duration(days: 2))
                .toIso8601String(),
          },
          {
            'id': '4',
            'titulo': 'Oferta Especial',
            'mensaje':
                'Descuento del 20% en todos los platos principales este fin de semana.',
            'tipo': 'oferta',
            'leida': true,
            'created_at': DateTime.now()
                .subtract(const Duration(days: 3))
                .toIso8601String(),
          },
        ]);
        _unreadCount = _notificaciones.where((n) => n['leida'] == false).length;
        _isLoading = false;
      });
    }
  }

  Future<void> _marcarComoLeida(String id) async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;

      if (user != null) {
        try {
          await supabase
              .from('notificaciones')
              .update({'leida': true})
              .eq('id', id)
              .eq('user_id', user.id);
        } catch (e) {
          // Si falla, actualizar localmente
        }
      }

      setState(() {
        final index = _notificaciones.indexWhere((n) => n['id'] == id);
        if (index != -1) {
          _notificaciones[index]['leida'] = true;
          _unreadCount =
              _notificaciones.where((n) => n['leida'] == false).length;
        }
      });
    } catch (e) {
      // Manejar error
    }
  }

  Future<void> _marcarTodasComoLeidas() async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;

      if (user != null) {
        try {
          await supabase
              .from('notificaciones')
              .update({'leida': true})
              .eq('user_id', user.id)
              .eq('leida', false);
        } catch (e) {
          // Si falla, actualizar localmente
        }
      }

      setState(() {
        for (var notif in _notificaciones) {
          notif['leida'] = true;
        }
        _unreadCount = 0;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Todas las notificaciones marcadas como leídas'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  IconData _getIconForType(String tipo) {
    switch (tipo) {
      case 'reserva':
        return Icons.calendar_today;
      case 'nuevo':
        return Icons.restaurant;
      case 'recordatorio':
        return Icons.notifications;
      case 'oferta':
        return Icons.local_offer;
      default:
        return Icons.info;
    }
  }

  Color _getColorForType(String tipo) {
    switch (tipo) {
      case 'reserva':
        return Colors.blue;
      case 'nuevo':
        return Colors.green;
      case 'recordatorio':
        return Colors.orange;
      case 'oferta':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificaciones'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          if (_unreadCount > 0)
            TextButton(
              onPressed: _marcarTodasComoLeidas,
              child: const Text(
                'Marcar todas como leídas',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notificaciones.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.notifications_none,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No hay notificaciones',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Te notificaremos cuando haya novedades',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    if (_unreadCount > 0)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.1),
                        child: Text(
                          '$_unreadCount notificación${_unreadCount > 1 ? 'es' : ''} sin leer',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _notificaciones.length,
                        itemBuilder: (context, index) {
                          final notif = _notificaciones[index];
                          final titulo = notif['titulo'] ?? 'Notificación';
                          final mensaje = notif['mensaje'] ?? '';
                          final tipo = notif['tipo'] ?? 'info';
                          final leida = notif['leida'] ?? false;
                          final createdAt = notif['created_at'] != null
                              ? DateTime.tryParse(notif['created_at'])
                              : null;

                          return Dismissible(
                            key: Key(notif['id'].toString()),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                            ),
                            onDismissed: (direction) {
                              setState(() {
                                _notificaciones.removeAt(index);
                                if (!leida) {
                                  _unreadCount--;
                                }
                              });
                            },
                            child: Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              elevation: leida ? 1 : 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: leida
                                    ? BorderSide.none
                                    : BorderSide(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        width: 2,
                                      ),
                              ),
                              child: InkWell(
                                onTap: () {
                                  if (!leida) {
                                    _marcarComoLeida(notif['id'].toString());
                                  }
                                },
                                borderRadius: BorderRadius.circular(12),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: _getColorForType(tipo)
                                              .withOpacity(0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          _getIconForType(tipo),
                                          color: _getColorForType(tipo),
                                          size: 24,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    titulo,
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight: leida
                                                          ? FontWeight.normal
                                                          : FontWeight.bold,
                                                      color: leida
                                                          ? Colors.grey[700]
                                                          : Colors.black,
                                                    ),
                                                  ),
                                                ),
                                                if (!leida)
                                                  Container(
                                                    width: 10,
                                                    height: 10,
                                                    decoration:
                                                        const BoxDecoration(
                                                      color: Colors.blue,
                                                      shape: BoxShape.circle,
                                                    ),
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
                                            const SizedBox(height: 8),
                                            Text(
                                              mensaje,
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: leida
                                                    ? Colors.grey[600]
                                                    : Colors.black87,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
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
