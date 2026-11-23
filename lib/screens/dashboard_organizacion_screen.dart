import 'package:flutter/material.dart';

import '../widgets/dashboard_widgets.dart';
import '../widgets/estilo_app.dart';
import 'main_shell.dart';

/// Dashboard — Organización (recibe donaciones).
class DashboardOrganizacionScreen extends StatelessWidget {
  const DashboardOrganizacionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DashboardScaffold(
      titulo: 'Panel de organización',
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [DaleColores.verdeBosque, DaleColores.verdeClaro],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Stack(
            children: [
              const Positioned.fill(child: DecoracionOrganica()),
              Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Juntos generamos cambios',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Roboto',
                          ),
                        ),
                        SizedBox(height: 7),
                        Text(
                          'Ayuda a que más objetos encuentren un nuevo hogar.',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            height: 1.4,
                            fontFamily: 'Roboto',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const LogoDaleVuelta(size: 58),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 22),

        const Text(
          'Resumen de actividad',
          style: TextStyle(
            color: DaleColores.carbon,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: 'Roboto',
          ),
        ),

        const SizedBox(height: 12),

        filaStats(const [
          StatCard(
            icono: Icons.volunteer_activism_outlined,
            valor: '14',
            etiqueta: 'Donaciones recibidas',
          ),
          StatCard(
            icono: Icons.pending_actions_outlined,
            valor: '3',
            etiqueta: 'Solicitudes pendientes',
          ),
        ]),

        const SizedBox(height: 8),

        filaStats(const [
          StatCard(
            icono: Icons.people_outline,
            valor: '27',
            etiqueta: 'Donantes',
          ),
          StatCard(
            icono: Icons.eco_outlined,
            valor: '85 kg',
            etiqueta: 'Material reutilizado',
          ),
        ]),

        const SizedBox(height: 20),

        Container(
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(17),
            border: Border.all(color: DaleColores.borde),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.volunteer_activism_outlined,
                    color: DaleColores.verdeBosque,
                    size: 23,
                  ),
                  SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      'Encuentra nuevas donaciones',
                      style: TextStyle(
                        color: DaleColores.carbon,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Roboto',
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 7),

              const Text(
                'Explora los objetos disponibles y encuentra aquellos que puedan ayudar a tu organización.',
                style: TextStyle(
                  color: DaleColores.grisMusgo,
                  fontSize: 12,
                  height: 1.4,
                  fontFamily: 'Roboto',
                ),
              ),

              const SizedBox(height: 15),

              SizedBox(
                width: double.infinity,
                height: 47,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const MainShell()),
                    );
                  },
                  icon: const Icon(Icons.search_rounded),
                  label: const Text(
                    'Buscar donaciones disponibles',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Roboto',
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DaleColores.verdeBosque,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        const Text(
          'Solicitudes pendientes',
          style: TextStyle(
            color: DaleColores.carbon,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: 'Roboto',
          ),
        ),

        const SizedBox(height: 5),

        const Text(
          'Donaciones que pueden interesarle a tu organización.',
          style: TextStyle(
            color: DaleColores.grisMusgo,
            fontSize: 12,
            fontFamily: 'Roboto',
          ),
        ),

        const SizedBox(height: 13),

        _solicitud(
          icono: Icons.chair_outlined,
          titulo: 'Silla de madera',
          donante: 'María López',
        ),

        const SizedBox(height: 10),

        _solicitud(
          icono: Icons.checkroom_outlined,
          titulo: 'Uniforme escolar talla M',
          donante: 'Carlos Ramírez',
        ),

        const SizedBox(height: 16),
      ],
    );
  }

  Widget _solicitud({
    required IconData icono,
    required String titulo,
    required String donante,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: DaleColores.borde),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.025),
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        leading: CircleAvatar(
          backgroundColor: DaleColores.verdeLima.withOpacity(0.4),
          child: Icon(icono, color: DaleColores.verdeBosque),
        ),
        title: Text(
          titulo,
          style: const TextStyle(
            color: DaleColores.carbon,
            fontWeight: FontWeight.bold,
            fontSize: 13,
            fontFamily: 'Roboto',
          ),
        ),
        subtitle: Text(
          'Donante: $donante',
          style: const TextStyle(
            color: DaleColores.grisMusgo,
            fontSize: 11,
            fontFamily: 'Roboto',
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right_rounded,
          color: DaleColores.verdeBosque,
        ),
      ),
    );
  }
}
