import 'package:flutter/material.dart';

import '../models/sesion.dart';
import '../widgets/estilo_app.dart';
import 'login_screen.dart';

class PerfilScreen extends StatelessWidget {
  const PerfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DaleColores.crema,
      appBar: AppBar(
        backgroundColor: DaleColores.crema,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Mi perfil',
          style: TextStyle(
            color: DaleColores.carbon,
            fontWeight: FontWeight.bold,
            fontFamily: 'Roboto',
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [DaleColores.verdeBosque, DaleColores.verdeClaro],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Stack(
              children: [
                const Positioned.fill(child: DecoracionOrganica()),
                Column(
                  children: [
                    const LogoDaleVuelta(size: 65),
                    const SizedBox(height: 12),

                    CircleAvatar(
                      radius: 42,
                      backgroundColor: Colors.white,
                      child: const Icon(
                        Icons.person_rounded,
                        size: 48,
                        color: DaleColores.verdeBosque,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      Sesion.nombre,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Roboto',
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      Sesion.municipio,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontFamily: 'Roboto',
                      ),
                    ),

                    const SizedBox(height: 12),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white30),
                      ),
                      child: Text(
                        Sesion.rol.nombre,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Roboto',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 22),

          const Text(
            'Mi actividad',
            style: TextStyle(
              color: DaleColores.carbon,
              fontSize: 19,
              fontWeight: FontWeight.bold,
              fontFamily: 'Roboto',
            ),
          ),

          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(17),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(17),
              border: Border.all(color: DaleColores.borde),
            ),
            child: const Row(
              children: [
                CircleAvatar(
                  radius: 23,
                  backgroundColor: DaleColores.verdeLima,
                  child: Icon(
                    Icons.eco_rounded,
                    color: DaleColores.verdeBosque,
                  ),
                ),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Eco-puntos',
                        style: TextStyle(
                          color: DaleColores.carbon,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Sigue reutilizando y compartiendo.',
                        style: TextStyle(
                          color: DaleColores.grisMusgo,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '0',
                  style: TextStyle(
                    color: DaleColores.verdeBosque,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          _opcion(
            icono: Icons.inventory_2_outlined,
            titulo: 'Mis publicaciones',
            subtitulo: 'Consulta los objetos que has publicado',
            onTap: () {},
          ),

          const SizedBox(height: 10),

          _opcion(
            icono: Icons.favorite_border_rounded,
            titulo: 'Mis favoritos',
            subtitulo: 'Objetos que te interesan',
            onTap: () {},
          ),

          const SizedBox(height: 10),

          _opcion(
            icono: Icons.volunteer_activism_outlined,
            titulo: 'Mis donaciones',
            subtitulo: 'Consulta tus aportaciones',
            onTap: () {},
          ),

          const SizedBox(height: 24),

          OutlinedButton.icon(
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (r) => false,
              );
            },
            icon: const Icon(Icons.logout_rounded),
            label: const Text('Cerrar sesión'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red.shade700,
              side: BorderSide(color: Colors.red.shade200),
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _opcion({
    required IconData icono,
    required String titulo,
    required String subtitulo,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: DaleColores.borde),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: DaleColores.verdeLima.withOpacity(0.35),
                child: Icon(icono, color: DaleColores.verdeBosque),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: const TextStyle(
                        color: DaleColores.carbon,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitulo,
                      style: const TextStyle(
                        color: DaleColores.grisMusgo,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: DaleColores.grisMusgo,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
