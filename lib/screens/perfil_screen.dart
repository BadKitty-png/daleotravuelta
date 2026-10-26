import 'package:flutter/material.dart';
import '../models/sesion.dart';
import 'login_screen.dart';

class PerfilScreen extends StatelessWidget {
  const PerfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Center(child: CircleAvatar(radius: 44, child: Icon(Icons.person, size: 44))),
          const SizedBox(height: 12),
          Center(child: Text(Sesion.nombre, style: Theme.of(context).textTheme.titleLarge)),
          Center(child: Text(Sesion.municipio)),
          const SizedBox(height: 8),
          Center(child: Chip(label: Text(Sesion.rol.nombre))),
          const SizedBox(height: 16),
          const Card(
            child: ListTile(
              leading: Icon(Icons.eco_outlined),
              title: Text('Eco-puntos'),
              trailing: Text('0'),
            ),
          ),
          const Card(child: ListTile(leading: Icon(Icons.inventory_2_outlined), title: Text('Mis publicaciones'))),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () => Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const LoginScreen()),
              (r) => false,
            ),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
  }
}
