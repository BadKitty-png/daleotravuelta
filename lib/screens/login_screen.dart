import 'package:flutter/material.dart';
import '../models/sesion.dart';
import 'dashboard_router.dart';
import 'registro_screen.dart';

const municipiosGto = [
  'Dolores Hidalgo',
  'San Miguel de Allende',
  'San Luis de la Paz',
  'San Diego de la Unión',
];

/// Pantalla 1 — Inicio de sesión (con validación)
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _correo = TextEditingController();
  final _password = TextEditingController();
  String? _municipio;
  bool _ocultar = true;

  @override
  void dispose() {
    _correo.dispose();
    _password.dispose();
    super.dispose();
  }

  void _entrar() {
    if (!_formKey.currentState!.validate()) return;
    Sesion.correo = _correo.text.trim();
    Sesion.municipio = _municipio!;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const DashboardRouter()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Icon(Icons.recycling,
                      size: 96, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(height: 8),
                  Text('Dale Otra Vuelta',
                      style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _correo,
                    keyboardType: TextInputType.emailAddress,
                    decoration:
                        const InputDecoration(labelText: 'Correo electrónico'),
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
                    obscureText: _ocultar,
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      suffixIcon: IconButton(
                        icon: Icon(_ocultar
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined),
                        onPressed: () => setState(() => _ocultar = !_ocultar),
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Escribe tu contraseña';
                      if (v.length < 6) return 'Mínimo 6 caracteres';
                      return null;
                    },
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
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _entrar,
                      child: const Text('Iniciar sesión'),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const RegistroScreen()),
                    ),
                    child: const Text('¿No tienes cuenta? Crear cuenta'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
