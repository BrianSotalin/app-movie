// lib/shared/widget/modal/modal_login.dart
import 'package:flutter/material.dart';

class LoginFormData {
  final String username;
  final String password;

  LoginFormData({required this.username, required this.password});
}

class ModalLogin extends StatefulWidget {
  const ModalLogin({super.key});

  @override
  State<ModalLogin> createState() => _ModalLoginState();
}

class _ModalLoginState extends State<ModalLogin> {
  final _formKey = GlobalKey<FormState>();
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _userCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Campo obligatorio' : null;

  InputDecoration _roundedInputDecoration(
    BuildContext context,
    String hint, {
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      isDense: true,
      suffixIcon: suffix,
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

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    Navigator.of(context).pop(
      LoginFormData(username: _userCtrl.text.trim(), password: _passCtrl.text),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bg = Theme.of(context).colorScheme.primary;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      backgroundColor: bg,
      // borde blanco del modal como en tus otros diálogos
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
                      'LOGIN',
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
                // separador bajo el título
                const SizedBox(height: 4),
                const Divider(height: 1, thickness: 1, color: Colors.white24),
                const SizedBox(height: 10),

                // USARIO (tal cual tu captura)
                TextFormField(
                  controller: _userCtrl,
                  validator: _required,
                  textInputAction: TextInputAction.next,
                  decoration: _roundedInputDecoration(context, 'USARIO'),
                ),
                const SizedBox(height: 10),

                // CONTRASEÑA (con toggle de visibilidad)
                TextFormField(
                  controller: _passCtrl,
                  validator: _required,
                  obscureText: _obscure,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submit(),
                  decoration: _roundedInputDecoration(
                    context,
                    'CONTRASEÑA',
                    suffix: IconButton(
                      tooltip: _obscure ? 'Mostrar' : 'Ocultar',
                      onPressed: () => setState(() => _obscure = !_obscure),
                      icon: Icon(
                        _obscure ? Icons.visibility : Icons.visibility_off,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Botón INICIAR SECCION (verde con borde blanco e ícono disquete)
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: FilledButton.icon(
                    onPressed: _submit,
                    icon: const Icon(Icons.save, color: Colors.white),
                    label: const Text(
                      'INICIAR SECCION',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFA2CA8E),
                      foregroundColor: Colors.white, // icono/ripple blancos
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
