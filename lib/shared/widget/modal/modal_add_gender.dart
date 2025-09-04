import 'package:flutter/material.dart';

class ModalAddGener extends StatefulWidget {
  const ModalAddGener({super.key});

  @override
  State<ModalAddGener> createState() => _ModalAddGenerState();
}

class _ModalAddGenerState extends State<ModalAddGener> {
  final _formKey = GlobalKey<FormState>();
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Campo obligatorio' : null;

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    Navigator.of(context).pop(_ctrl.text.trim());
  }

  // decoración reutilizable para input redondeado
  InputDecoration _roundedInputDecoration(BuildContext context, String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.white24),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.white24),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.secondary,
          width: 2,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bg = Theme.of(context).colorScheme.primary;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      backgroundColor: bg,
      // Borde blanco del modal
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Colors.white, width: 1),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header con título y X
                Row(
                  children: [
                    const Text(
                      'AÑADIR GENERO',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      tooltip: 'Cerrar',
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),

                // Línea separadora bajo el título
                const SizedBox(height: 4),
                const Divider(height: 1, thickness: 1, color: Colors.white24),
                const SizedBox(height: 10),

                // Input redondeado sin underline
                TextFormField(
                  controller: _ctrl,
                  validator: _required,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _save(),
                  decoration: _roundedInputDecoration(
                    context,
                    'TUTULO DE GENERO',
                  ),
                ),

                const SizedBox(height: 12),

                // Botón GUARDAR (verde con borde blanco)
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: FilledButton.icon(
                    onPressed: _save,
                    icon: const Icon(Icons.save, color: Colors.white),
                    label: const Text(
                      'GUARDAR',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFA2CA8E),
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(color: Colors.white, width: 1),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
