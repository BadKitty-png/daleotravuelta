import 'package:flutter/material.dart';

import '../widgets/producto_card.dart';
import '../widgets/estilo_app.dart';

class InicioScreen extends StatelessWidget {
  const InicioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DaleColores.crema,
      appBar: AppBar(
        backgroundColor: DaleColores.crema,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Dale la Vuelta',
          style: TextStyle(
            color: DaleColores.carbon,
            fontWeight: FontWeight.bold,
            fontFamily: 'Roboto',
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: DaleColores.verdeLima.withOpacity(0.35),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.eco_rounded,
                color: DaleColores.verdeBosque,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
        children: [
          // Banner principal
          Container(
            padding: const EdgeInsets.all(20),
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
                Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '¡Hola! Dale otra vida a las cosas',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                              height: 1.25,
                              fontFamily: 'Roboto',
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Compra, vende o dona. Cada objeto merece una segunda oportunidad.',
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
                    const LogoDaleVuelta(size: 70),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Sección de productos
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Cerca de ti',
                style: TextStyle(
                  color: DaleColores.carbon,
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Roboto',
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: DaleColores.verdeLima.withOpacity(0.30),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 14,
                      color: DaleColores.verdeBosque,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Explorar',
                      style: TextStyle(
                        color: DaleColores.verdeBosque,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Roboto',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 5),
          const Text(
            'Objetos que buscan un nuevo hogar',
            style: TextStyle(
              color: DaleColores.grisMusgo,
              fontSize: 13,
              fontFamily: 'Roboto',
            ),
          ),

          const SizedBox(height: 14),

          for (final p in productosDemo) ProductoCard(producto: p),
        ],
      ),
    );
  }
}
