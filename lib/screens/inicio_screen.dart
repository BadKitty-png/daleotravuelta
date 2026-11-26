import 'package:flutter/material.dart';

import '../services/publicacion_service.dart';
import '../widgets/producto_card.dart';
import '../widgets/estilo_app.dart';

class InicioScreen extends StatefulWidget {
  const InicioScreen({super.key});

  @override
  State<InicioScreen> createState() => _InicioScreenState();
}

class _InicioScreenState extends State<InicioScreen> {
  late Future<List<Map<String, dynamic>>> _publicacionesFuture;

  @override
  void initState() {
    super.initState();
    _publicacionesFuture = PublicacionService.instance.obtenerPublicaciones();
  }

  Future<void> _recargarPublicaciones() async {
    final consulta = PublicacionService.instance.obtenerPublicaciones();

    setState(() {
      _publicacionesFuture = consulta;
    });

    await consulta;
  }

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
      body: RefreshIndicator(
        color: DaleColores.verdeBosque,
        onRefresh: _recargarPublicaciones,
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _publicacionesFuture,
          builder: (context, snapshot) {
            final publicaciones = snapshot.data ?? [];

            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
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
                      const Row(
                        children: [
                          Expanded(
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
                          SizedBox(width: 8),
                          LogoDaleVuelta(size: 70),
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

                // Cargando publicaciones
                if (snapshot.connectionState == ConnectionState.waiting)
                  const Padding(
                    padding: EdgeInsets.all(30),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: DaleColores.verdeBosque,
                      ),
                    ),
                  )
                // Error al consultar SQLite
                else if (snapshot.hasError)
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.error_outline_rounded,
                          size: 42,
                          color: Colors.redAccent,
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'No se pudieron cargar las publicaciones.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: DaleColores.carbon,
                            fontFamily: 'Roboto',
                          ),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: _recargarPublicaciones,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Reintentar'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: DaleColores.verdeBosque,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  )
                // No hay publicaciones
                else if (publicaciones.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: DaleColores.borde),
                    ),
                    child: const Column(
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 45,
                          color: DaleColores.verdeBosque,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Todavía no hay publicaciones',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: DaleColores.carbon,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            fontFamily: 'Roboto',
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Sé la primera persona en darle otra vuelta a un objeto.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: DaleColores.grisMusgo,
                            fontSize: 12,
                            fontFamily: 'Roboto',
                          ),
                        ),
                      ],
                    ),
                  )
                // Mostrar publicaciones de SQLite
                else
                  for (final registro in publicaciones)
                    ProductoCard(producto: Producto.desdeMapa(registro)),
              ],
            );
          },
        ),
      ),
    );
  }
}
