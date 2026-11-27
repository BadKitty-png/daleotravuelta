import 'package:flutter/material.dart';

import '../models/sesion.dart';
import '../services/publicacion_service.dart';
import '../widgets/dashboard_widgets.dart';
import 'main_shell.dart';
import 'publicar_tipo_screen.dart';
import 'chats_screen.dart';
import 'buscar_screen.dart';

/// Dashboard — Usuario conectado a SQLite.
class DashboardUsuarioScreen extends StatefulWidget {
  const DashboardUsuarioScreen({super.key});

  @override
  State<DashboardUsuarioScreen> createState() => _DashboardUsuarioScreenState();
}

class _DashboardUsuarioScreenState extends State<DashboardUsuarioScreen> {
  late Future<List<Map<String, dynamic>>> _publicacionesFuture;

  @override
  void initState() {
    super.initState();
    _cargarPublicaciones();
  }

  void _cargarPublicaciones() {
    final usuarioId = Sesion.usuarioId;

    if (usuarioId == null) {
      _publicacionesFuture = Future.value([]);
      return;
    }

    _publicacionesFuture = PublicacionService.instance.obtenerMisPublicaciones(
      usuarioId: usuarioId,
    );
  }

  Future<void> _actualizarPublicaciones() async {
    setState(() {
      _cargarPublicaciones();
    });

    await _publicacionesFuture;
  }

  // Abrir la pantalla de chats existente.
  void _abrirChats() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const ChatsScreen()));
  }

  // Explorar publicaciones para encontrar intercambios.
  void _abrirIntercambios() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const BuscarScreen()));
  }

  // Aviso de que los eco-puntos todavía no están disponibles.
  void _mostrarAvisoEcoPuntos() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(
          Icons.eco_outlined,
          size: 42,
          color: Color(0xFF3D7050),
        ),
        title: const Text('Eco-puntos'),
        content: const Text(
          'Esta función todavía está en desarrollo. '
          'Próximamente podrás acumular eco-puntos por tus '
          'acciones de reutilización, donación e intercambio.',
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DashboardScaffold(
      titulo: 'Mi panel',
      children: [
        FutureBuilder<List<Map<String, dynamic>>>(
          future: _publicacionesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (snapshot.hasError) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'No se pudieron cargar tus publicaciones: '
                  '${snapshot.error}',
                ),
              );
            }

            final publicaciones = snapshot.data ?? [];
            final totalPublicaciones = publicaciones.length;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ESTADÍSTICAS PRINCIPALES
                filaStats([
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: _mostrarAvisoEcoPuntos,
                    child: const StatCard(
                      icono: Icons.eco_outlined,
                      valor: '0',
                      etiqueta: 'Eco-puntos',
                    ),
                  ),
                  StatCard(
                    icono: Icons.inventory_2_outlined,
                    valor: '$totalPublicaciones',
                    etiqueta: 'Publicaciones',
                  ),
                ]),

                const SizedBox(height: 8),

                filaStats([
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: _abrirIntercambios,
                    child: const StatCard(
                      icono: Icons.swap_horiz,
                      valor: '0',
                      etiqueta: 'Intercambios',
                    ),
                  ),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: _abrirChats,
                    child: const StatCard(
                      icono: Icons.chat_bubble_outline,
                      valor: 'Ver',
                      etiqueta: 'Chats activos',
                    ),
                  ),
                ]),

                const SizedBox(height: 16),

                // EXPLORAR PRODUCTOS
                FilledButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const MainShell()),
                    );
                  },
                  icon: const Icon(Icons.explore_outlined),
                  label: const Text('Explorar productos'),
                ),

                const SizedBox(height: 8),

                // PUBLICAR PRODUCTO
                OutlinedButton.icon(
                  onPressed: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const PublicarTipoScreen(),
                      ),
                    );

                    if (mounted) {
                      await _actualizarPublicaciones();
                    }
                  },
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text('Publicar un producto'),
                ),

                const SizedBox(height: 24),

                Text(
                  'Mis publicaciones recientes',
                  style: Theme.of(context).textTheme.titleMedium,
                ),

                const SizedBox(height: 8),

                if (publicaciones.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(18),
                      child: Column(
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 40,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Todavía no tienes publicaciones.',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Cuando publiques un objeto, '
                            'aparecerá aquí.',
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  for (final publicacion in publicaciones.take(2))
                    _tarjetaPublicacion(publicacion),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _tarjetaPublicacion(Map<String, dynamic> publicacion) {
    final titulo = publicacion['titulo']?.toString() ?? 'Sin título';

    final categoria = publicacion['categoria']?.toString() ?? 'Sin categoría';

    final modalidad = publicacion['modalidad']?.toString() ?? 'Sin modalidad';

    final municipio = publicacion['municipio']?.toString() ?? '';

    final precio = (publicacion['precio'] as num?)?.toDouble() ?? 0;

    final precioTexto = modalidad == 'Vender'
        ? '\$${precio.toStringAsFixed(2)}'
        : modalidad;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.inventory_2_outlined)),
        title: Text(
          titulo,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('$categoria • $municipio'),
        trailing: Text(
          precioTexto,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
