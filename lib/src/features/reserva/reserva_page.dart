import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ReservaPage extends StatefulWidget {
  const ReservaPage({super.key});

  @override
  State<ReservaPage> createState() => _ReservaPageState();
}

class _ReservaPageState extends State<ReservaPage> {
  // Clave global para el Formulario para validación
  final _formKey = GlobalKey<FormState>();

  // Controladores para los campos de texto
  final _nombreController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _fechaController = TextEditingController();
  final _horaController = TextEditingController();

  // Nodos de foco para controlar el flujo de navegación
  final _nombreFocusNode = FocusNode();
  final _telefonoFocusNode = FocusNode();
  final _personasFocusNode = FocusNode();
  final _fechaFocusNode = FocusNode();
  final _horaFocusNode = FocusNode();

  // Estado del formulario
  int _personas = 1;
  String? _zonaSeleccionada = 'Terraza';
  bool _isFormComplete = false;

  // Paleta de colores
  final Color primary = const Color.fromARGB(255, 138, 158, 141);
  final Color primaryDisabled = const Color.fromARGB(255, 105, 121, 108);
  final Color backgroundLight = const Color(0xFFF8F8F8);
  final Color surfaceLight = const Color(0xFFFFFFFF);
  final Color borderLight = const Color(0xFFDDDDDD);
  final Color textLight = const Color(0xFF333333);
  final Color mutedLight = const Color(0xFF666666);

  @override
  void initState() {
    super.initState();
    // Añadir listeners para comprobar el estado del formulario en tiempo real
    _nombreController.addListener(_updateFormState);
    _telefonoController.addListener(_updateFormState);
    _fechaController.addListener(_updateFormState);
    _horaController.addListener(_updateFormState);
  }

  @override
  void dispose() {
    // Liberar recursos para evitar fugas de memoria
    _nombreController.dispose();
    _telefonoController.dispose();
    _fechaController.dispose();
    _horaController.dispose();

    _nombreFocusNode.dispose();
    _telefonoFocusNode.dispose();
    _personasFocusNode.dispose();
    _fechaFocusNode.dispose();
    _horaFocusNode.dispose();
    super.dispose();
  }

  // Actualiza el estado del botón de confirmación
  void _updateFormState() {
    final isComplete = _nombreController.text.isNotEmpty &&
        _telefonoController.text.isNotEmpty &&
        _fechaController.text.isNotEmpty &&
        _horaController.text.isNotEmpty &&
        _zonaSeleccionada != null;

    if (_isFormComplete != isComplete) {
      setState(() {
        _isFormComplete = isComplete;
      });
    }
  }

  // Procesa el envío del formulario
  // Procesa el envío del formulario
  Future<void> _submitForm() async {
    // Primero, valida que todos los campos del formulario cumplan las reglas
    if (!_formKey.currentState!.validate()) {
      return; // Si el formulario no es válido, no hace nada.
    }

    // Muestra un indicador de carga
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final supabase = Supabase.instance.client;
      await supabase.from('reservations').insert({
        'name': _nombreController.text,
        'phone': _telefonoController.text,
        'reservation_date': _fechaController
            .text, // Se guarda como texto, asegúrate que la columna en Supabase sea de tipo 'text' o 'varchar'
        'time': _horaController.text, // Lo mismo para la hora
        'people': _personas,
        'zone': _zonaSeleccionada,
      });

      // Cierra el indicador de carga
      // ignore: use_build_context_synchronously
      Navigator.of(context).pop();

      // Muestra un mensaje de éxito
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Reserva confirmada. ¡Gracias!'),
            backgroundColor: Colors.green),
      );
    } catch (error) {
      // Cierra el indicador de carga
      // ignore: use_build_context_synchronously
      Navigator.of(context).pop();

      // Muestra un mensaje de error
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Error al guardar la reserva: $error'),
            backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundLight,
      appBar: AppBar(
        backgroundColor: backgroundLight,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textLight),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Haz tu Reserva',
            style: TextStyle(color: textLight, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('Detalles de Contacto'),
                const SizedBox(height: 16),
                _buildNombreField(),
                const SizedBox(height: 16),
                _buildTelefonoField(),
                const SizedBox(height: 24),
                _buildSectionTitle('Detalles de la Reserva'),
                const SizedBox(height: 16),
                _buildPersonasField(),
                const SizedBox(height: 16),
                _buildFechaField(),
                const SizedBox(height: 16),
                _buildHoraField(),
                const SizedBox(height: 16),
                _buildZonaField(),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomButton(),
    );
  }

  // --- Widgets de construcción de UI ---

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
          fontSize: 18, fontWeight: FontWeight.bold, color: textLight),
    );
  }

  Widget _buildNombreField() {
    return TextFormField(
      controller: _nombreController,
      focusNode: _nombreFocusNode,
      textInputAction: TextInputAction.next,
      decoration: _inputDecoration('Ingresa tu nombre completo'),
      validator: (value) => value!.isEmpty ? 'El nombre es obligatorio' : null,
      onEditingComplete: () =>
          FocusScope.of(context).requestFocus(_telefonoFocusNode),
    );
  }

  Widget _buildTelefonoField() {
    return TextFormField(
      controller: _telefonoController,
      focusNode: _telefonoFocusNode,
      keyboardType: TextInputType.phone,
      textInputAction: TextInputAction.next,
      decoration: _inputDecoration('Ingresa tu número de teléfono'),
      validator: (value) =>
          value!.isEmpty ? 'El teléfono es obligatorio' : null,
      onEditingComplete: () =>
          FocusScope.of(context).requestFocus(_personasFocusNode),
    );
  }

  Widget _buildPersonasField() {
    return _buildCard(
      focusNode: _personasFocusNode,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Número de personas', style: TextStyle(color: textLight)),
          Row(
            children: [
              _circleButton(Icons.remove, () {
                if (_personas > 1) setState(() => _personas--);
              }),
              SizedBox(
                width: 40,
                child: Text(
                  '$_personas',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              _circleButton(Icons.add, () => setState(() => _personas++)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFechaField() {
    return TextFormField(
      controller: _fechaController,
      focusNode: _fechaFocusNode,
      readOnly: true,
      decoration: _inputDecoration('Seleccionar fecha',
          suffixIcon: Icon(Icons.calendar_today, color: mutedLight)),
      validator: (value) => value!.isEmpty ? 'La fecha es obligatoria' : null,
      onTap: () async {
        FocusScope.of(context).requestFocus(_fechaFocusNode);
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (pickedDate != null) {
          _fechaController.text =
              "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
          // ignore: use_build_context_synchronously
          FocusScope.of(context).requestFocus(_horaFocusNode);
        }
      },
    );
  }

  Widget _buildHoraField() {
    return TextFormField(
      controller: _horaController,
      focusNode: _horaFocusNode,
      readOnly: true,
      decoration: _inputDecoration('Seleccionar hora',
          suffixIcon: Icon(Icons.access_time, color: mutedLight)),
      validator: (value) => value!.isEmpty ? 'La hora es obligatoria' : null,
      onTap: () async {
        FocusScope.of(context).requestFocus(_horaFocusNode);
        TimeOfDay? pickedTime = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
        );
        if (pickedTime != null) {
          // ignore: use_build_context_synchronously
          _horaController.text = pickedTime.format(context);
          // ignore: use_build_context_synchronously
          FocusScope.of(context).unfocus(); // Cierra el teclado
        }
      },
    );
  }

  Widget _buildZonaField() {
    return DropdownButtonFormField<String>(
      initialValue: _zonaSeleccionada,
      decoration: _inputDecoration(''),
      items: ['Terraza', 'Interior', 'Balcón', 'VIP']
          .map((label) => DropdownMenuItem(
                value: label,
                child: Text(label),
              ))
          .toList(),
      onChanged: (value) {
        setState(() {
          _zonaSeleccionada = value;
        });
        _updateFormState();
      },
      validator: (value) => value == null ? 'Debes seleccionar una zona' : null,
    );
  }

  Widget _buildBottomButton() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: backgroundLight,
        border: Border(top: BorderSide(color: borderLight, width: 1.0)),
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: _isFormComplete ? primary : primaryDisabled,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: _isFormComplete ? _submitForm : null,
        child: const Text(
          'Confirmar Reserva',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // --- Widgets de utilidad ---

  Widget _circleButton(IconData icon, VoidCallback onPressed) {
    return Material(
      color: primary.withAlpha((255 * 0.1).round()),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onPressed,
        child: SizedBox(
          width: 32,
          height: 32,
          child: Icon(icon, color: primary, size: 18),
        ),
      ),
    );
  }

  Widget _buildCard({FocusNode? focusNode, required Widget child}) {
    return Material(
      color: surfaceLight,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          if (focusNode != null) {
            FocusScope.of(context).requestFocus(focusNode);
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderLight),
          ),
          child: child,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hintText, {Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hintText,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: surfaceLight,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: borderLight),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: borderLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: primary, width: 1.5),
      ),
    );
  }
}
