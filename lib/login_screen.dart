import 'package:flutter/material.dart';
import 'main_shell.dart';

/// Pantalla 1 — Inicio de sesión / creación de cuenta
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  void _entrar(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainShell()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Icon(Icons.recycling,
                    size: 96, color: Theme.of(context).colorScheme.primary),
                const SizedBox(height: 8),
                Text('Dale Otra Vuelta',
                    style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 32),
                const TextField(
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(labelText: 'Correo electrónico'),
                ),
                const SizedBox(height: 16),
                const TextField(
                  obscureText: true,
                  decoration: InputDecoration(labelText: 'Contraseña'),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Municipio'),
                  items: const [
                    'Dolores Hidalgo',
                    'San Miguel de Allende',
                    'San Luis de la Paz',
                    'San Diego de la Unión',
                  ].map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                  onChanged: (_) {},
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => _entrar(context),
                    child: const Text('Crear cuenta'),
                  ),
                ),
                TextButton(
                  onPressed: () => _entrar(context),
                  child: const Text('Ya tengo cuenta, iniciar sesión'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
