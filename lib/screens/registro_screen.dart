import 'package:flutter/material.dart';
import '../models/sesion.dart';
import 'dashboard_router.dart';
import 'login_screen.dart' show municipiosGto;

/// Pantalla 1b — Registro con selección de rol
class RegistroScreen extends StatefulWidget {
  const RegistroScreen({super.key});

  @override
  State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombre = TextEditingController();
  final _correo = TextEditingController();
  final _password = TextEditingController();
  final _confirmar = TextEditingController();
  String? _municipio;
  RolUsuario _rol = RolUsuario.usuario;
  bool _terminos = false;
  bool _errorTerminos = false;

  @override
  void dispose() {
    _nombre.dispose();
    _correo.dispose();
    _password.dispose();
    _confirmar.dispose();
    super.dispose();
  }

  void _crear() {
    final ok = _formKey.currentState!.validate();
    setState(() => _errorTerminos = !_terminos);
    if (!ok || !_terminos) return;

    Sesion.nombre = _nombre.text.trim();
    Sesion.correo = _correo.text.trim();
    Sesion.municipio = _municipio!;
    Sesion.rol = _rol;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const DashboardRouter()),
      (r) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme.titleMedium;
    return Scaffold(
      appBar: AppBar(title: const Text('Crear cuenta')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nombre,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'Nombre completo'),
              validator: (v) =>
                  (v == null || v.trim().length < 3) ? 'Escribe tu nombre' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _correo,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Correo electrónico'),
              validator: (v) {
                final t = v?.trim() ?? '';
                if (t.isEmpty) return 'Escribe tu correo';
                final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(t);
                return ok ? null : 'Correo no válido';
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _password,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Contraseña'),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Escribe una contraseña';
                if (v.length < 6) return 'Mínimo 6 caracteres';
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _confirmar,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Confirmar contraseña'),
              validator: (v) =>
                  v != _password.text ? 'Las contraseñas no coinciden' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Municipio'),
              items: municipiosGto
                  .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                  .toList(),
              onChanged: (v) => setState(() => _municipio = v),
              validator: (v) => v == null ? 'Selecciona tu municipio' : null,
            ),
            const SizedBox(height: 24),
            Text('¿Cómo usarás la app?', style: t),
            const SizedBox(height: 8),
            RadioGroup<RolUsuario>(
              groupValue: _rol,
              onChanged: (v) => setState(() => _rol = v!),
              child: Column(
                children: [
                  for (final r in RolUsuario.values)
                    RadioListTile<RolUsuario>(
                      contentPadding: EdgeInsets.zero,
                      title: Text(r.nombre),
                      subtitle: Text(r.descripcion),
                      value: r,
                    ),
                ],
              ),
            ),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              value: _terminos,
              onChanged: (v) => setState(() {
                _terminos = v ?? false;
                _errorTerminos = false;
              }),
              title: const Text('Acepto los términos y condiciones'),
              subtitle: _errorTerminos
                  ? Text('Debes aceptar para continuar',
                      style: TextStyle(color: Theme.of(context).colorScheme.error))
                  : null,
            ),
            const SizedBox(height: 16),
            FilledButton(onPressed: _crear, child: const Text('Crear cuenta')),
          ],
        ),
      ),
    );
  }
}
