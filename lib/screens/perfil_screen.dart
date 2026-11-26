import 'package:flutter/material.dart';

import '../database/base_datos.dart';
import '../models/sesion.dart';
import '../widgets/estilo_app.dart';
import 'login_screen.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  List<Map<String, dynamic>> _publicaciones = [];

  int _totalPublicaciones = 0;
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarPerfil();
  }

  // Obtener información del usuario y sus publicaciones.
  Future<void> _cargarPerfil() async {
    try {
      final db = await BaseDatos.instance.database;
      final usuarioId = Sesion.usuarioId;

      if (usuarioId == null) {
        throw Exception('No hay un usuario activo.');
      }

      // Consultar información del usuario.
      final usuarios = await db.query(
        'usuarios',
        where: 'id = ?',
        whereArgs: [usuarioId],
        limit: 1,
      );

      if (usuarios.isEmpty) {
        throw Exception('No se encontró el usuario.');
      }

      final usuario = usuarios.first;

      // Consultar publicaciones del usuario.
      final publicaciones = await db.query(
        'publicaciones',
        where: 'usuario_id = ?',
        whereArgs: [usuarioId],
        orderBy: 'fecha_creacion DESC',
      );

      if (!mounted) return;

      setState(() {
        Sesion.nombre = usuario['nombre']?.toString() ?? '';
        Sesion.correo = usuario['correo']?.toString() ?? '';
        Sesion.municipio = usuario['municipio']?.toString() ?? '';

        final rol = usuario['rol']?.toString();

        Sesion.rol = RolUsuario.values.firstWhere(
          (r) => r.name == rol,
          orElse: () => RolUsuario.usuario,
        );

        _publicaciones = publicaciones;
        _totalPublicaciones = publicaciones.length;
        _cargando = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => _cargando = false);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al cargar el perfil: $e')));
    }
  }

  // Mostrar publicaciones del usuario.
  void _mostrarPublicaciones() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: DaleColores.crema,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.65,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Mis publicaciones',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: DaleColores.carbon,
                    ),
                  ),
                  const SizedBox(height: 15),

                  Expanded(
                    child: _publicaciones.isEmpty
                        ? const Center(
                            child: Text(
                              'Todavía no tienes publicaciones.',
                              style: TextStyle(color: DaleColores.grisMusgo),
                            ),
                          )
                        : ListView.builder(
                            itemCount: _publicaciones.length,
                            itemBuilder: (context, index) {
                              final p = _publicaciones[index];

                              final precio =
                                  (p['precio'] as num?)?.toDouble() ?? 0;

                              return Card(
                                color: Colors.white,
                                child: ListTile(
                                  leading: const CircleAvatar(
                                    backgroundColor: DaleColores.verdeLima,
                                    child: Icon(
                                      Icons.inventory_2_outlined,
                                      color: DaleColores.verdeBosque,
                                    ),
                                  ),
                                  title: Text(
                                    p['titulo']?.toString() ?? 'Sin título',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(
                                    '${p['categoria']} · ${p['municipio']}',
                                  ),
                                  trailing: Text(
                                    precio == 0
                                        ? 'Gratis'
                                        : '\$${precio.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      color: DaleColores.verdeBosque,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Cerrar sesión y eliminar el registro de SQLite.
  Future<void> _cerrarSesion() async {
    try {
      final db = await BaseDatos.instance.database;

      await db.delete('sesion', where: 'id = ?', whereArgs: [1]);

      Sesion.usuarioId = null;
      Sesion.nombre = 'Nombre de usuario';
      Sesion.correo = '';
      Sesion.municipio = 'Dolores Hidalgo';
      Sesion.rol = RolUsuario.usuario;

      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error al cerrar sesión: $e')));
    }
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
          'Mi perfil',
          style: TextStyle(
            color: DaleColores.carbon,
            fontWeight: FontWeight.bold,
            fontFamily: 'Roboto',
          ),
        ),
      ),
      body: _cargando
          ? const Center(
              child: CircularProgressIndicator(color: DaleColores.verdeBosque),
            )
          : RefreshIndicator(
              onRefresh: _cargarPerfil,
              color: DaleColores.verdeBosque,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                children: [
                  _construirTarjetaPerfil(),

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

                  _construirActividad(),

                  const SizedBox(height: 12),

                  _opcion(
                    icono: Icons.inventory_2_outlined,
                    titulo: 'Mis publicaciones',
                    subtitulo: 'Consulta los objetos que has publicado',
                    onTap: _mostrarPublicaciones,
                  ),

                  const SizedBox(height: 10),

                  _opcion(
                    icono: Icons.favorite_border_rounded,
                    titulo: 'Mis favoritos',
                    subtitulo: 'Objetos que te interesan',
                    onTap: () => _mensaje(
                      'La función de favoritos todavía no está disponible.',
                    ),
                  ),

                  const SizedBox(height: 10),

                  _opcion(
                    icono: Icons.volunteer_activism_outlined,
                    titulo: 'Mis donaciones',
                    subtitulo: 'Consulta tus aportaciones',
                    onTap: () => _mensaje(
                      'La función de donaciones todavía no está disponible.',
                    ),
                  ),

                  const SizedBox(height: 24),

                  OutlinedButton.icon(
                    onPressed: _cerrarSesion,
                    icon: const Icon(Icons.logout_rounded),
                    label: const Text('Cerrar sesión'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: BorderSide(color: Colors.red.shade200),
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // Tarjeta principal del perfil.
  Widget _construirTarjetaPerfil() {
    return Container(
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

              const CircleAvatar(
                radius: 42,
                backgroundColor: Colors.white,
                child: Icon(
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
                Sesion.correo,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
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
    );
  }

  // Actividad del usuario.
  Widget _construirActividad() {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: DaleColores.borde),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 23,
            backgroundColor: DaleColores.verdeLima,
            child: Icon(Icons.eco_rounded, color: DaleColores.verdeBosque),
          ),
          const SizedBox(width: 14),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mis publicaciones',
                  style: TextStyle(
                    color: DaleColores.carbon,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Objetos que has compartido.',
                  style: TextStyle(color: DaleColores.grisMusgo, fontSize: 11),
                ),
              ],
            ),
          ),

          Text(
            '$_totalPublicaciones',
            style: const TextStyle(
              color: DaleColores.verdeBosque,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _mensaje(String mensaje) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(mensaje)));
  }

  // Opciones del perfil.
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
