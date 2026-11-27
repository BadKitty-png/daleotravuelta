import 'package:flutter/material.dart';

import '../database/base_datos.dart';
import '../models/sesion.dart';
import '../widgets/estilo_app.dart';
import 'editar_publicacion_screen.dart';
import 'favoritos_screen.dart';
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

  Future<void> _cargarPerfil() async {
    try {
      final db = await BaseDatos.instance.database;
      final usuarioId = Sesion.usuarioId;

      if (usuarioId == null) {
        throw Exception('No hay un usuario activo.');
      }

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

  String get _iniciales {
    final partes = Sesion.nombre
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();

    if (partes.isEmpty) return 'U';

    if (partes.length == 1) {
      return partes.first.substring(0, 1).toUpperCase();
    }

    return '${partes.first[0]}${partes.last[0]}'.toUpperCase();
  }

  void _mostrarPublicaciones() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.72,
          decoration: const BoxDecoration(
            color: DaleColores.crema,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 42,
                  height: 5,
                  decoration: BoxDecoration(
                    color: DaleColores.borde,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 22, 22, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Mis publicaciones',
                              style: TextStyle(
                                color: DaleColores.carbon,
                                fontSize: 21,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$_totalPublicaciones objetos compartidos',
                              style: const TextStyle(
                                color: DaleColores.grisMusgo,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      CircleAvatar(
                        backgroundColor: DaleColores.verdeLima.withOpacity(.35),
                        child: const Icon(
                          Icons.inventory_2_outlined,
                          color: DaleColores.verdeBosque,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _publicaciones.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.inventory_2_outlined,
                                size: 55,
                                color: DaleColores.verdeClaro,
                              ),
                              SizedBox(height: 12),
                              Text(
                                'Todavía no tienes publicaciones',
                                style: TextStyle(
                                  color: DaleColores.carbon,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                'Cuando compartas un objeto aparecerá aquí.',
                                style: TextStyle(
                                  color: DaleColores.grisMusgo,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(18, 4, 18, 24),
                          itemCount: _publicaciones.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final p = _publicaciones[index];
                            final precio =
                                (p['precio'] as num?)?.toDouble() ?? 0;

                            return Container(
                              padding: const EdgeInsets.all(13),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(17),
                                border: Border.all(color: DaleColores.borde),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 54,
                                    height: 54,
                                    decoration: BoxDecoration(
                                      color: DaleColores.verdeLima.withOpacity(
                                        .3,
                                      ),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: const Icon(
                                      Icons.recycling_rounded,
                                      color: DaleColores.verdeBosque,
                                      size: 27,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          p['titulo']?.toString() ??
                                              'Sin título',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: DaleColores.carbon,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          '${p['categoria'] ?? 'Sin categoría'} · ${p['municipio'] ?? ''}',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: DaleColores.grisMusgo,
                                            fontSize: 11,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          precio == 0
                                              ? 'Gratis'
                                              : '\$${precio.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                            color: DaleColores.verdeBosque,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    tooltip: 'Editar publicación',
                                    onPressed: () => _editarPublicacion(p),
                                    icon: const Icon(
                                      Icons.edit_outlined,
                                      color: DaleColores.verdeBosque,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _editarPublicacion(Map<String, dynamic> publicacion) async {
    Navigator.of(context).pop();

    final actualizada = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => EditarPublicacionScreen(publicacion: publicacion),
      ),
    );

    if (actualizada == true) {
      await _cargarPerfil();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Publicación actualizada correctamente.')),
      );
    }
  }

  Future<void> _cerrarSesion() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Cerrar sesión'),
        content: const Text('¿Estás seguro de que deseas salir de tu cuenta?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: DaleColores.grisMusgo),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade50,
              foregroundColor: Colors.red.shade700,
              elevation: 0,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

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
      body: _cargando
          ? const Center(
              child: CircularProgressIndicator(color: DaleColores.verdeBosque),
            )
          : RefreshIndicator(
              onRefresh: _cargarPerfil,
              color: DaleColores.verdeBosque,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(child: _construirCabecera()),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(18, 22, 18, 30),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        const Text(
                          'Mi actividad',
                          style: TextStyle(
                            color: DaleColores.carbon,
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 13),
                        _construirEstadistica(),
                        const SizedBox(height: 25),
                        const Text(
                          'Mi cuenta',
                          style: TextStyle(
                            color: DaleColores.carbon,
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 13),
                        _opcion(
                          icono: Icons.inventory_2_outlined,
                          titulo: 'Mis publicaciones',
                          subtitulo: 'Consulta los objetos que compartes',
                          onTap: _mostrarPublicaciones,
                        ),
                        const SizedBox(height: 10),
                        _opcion(
                          icono: Icons.eco_outlined,
                          titulo: 'Mis favoritos',
                          subtitulo: 'Objetos que te interesan',
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const FavoritosScreen(),
                              ),
                            );
                          },
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
                        const SizedBox(height: 25),
                        _construirCerrarSesion(),
                        const SizedBox(height: 15),
                        const Center(
                          child: Text(
                            'Dale la Vuelta · Todo merece otra oportunidad',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: DaleColores.grisMusgo,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _construirCabecera() {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 55, 22, 30),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [DaleColores.verdeBosque, DaleColores.verdeClaro],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Stack(
        children: [
          const Positioned.fill(child: DecoracionOrganica()),
          Column(
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Mi perfil',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _cargarPerfil,
                    icon: const Icon(
                      Icons.refresh_rounded,
                      color: Colors.white,
                    ),
                    tooltip: 'Actualizar perfil',
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: DaleColores.verdeLima, width: 2),
                ),
                child: CircleAvatar(
                  radius: 43,
                  backgroundColor: Colors.white,
                  child: Text(
                    _iniciales,
                    style: const TextStyle(
                      color: DaleColores.verdeBosque,
                      fontSize: 27,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 13),
              Text(
                Sesion.nombre,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                Sesion.correo,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    color: DaleColores.verdeLima,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    Sesion.municipio,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.18),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.white30),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.verified_user_outlined,
                      size: 15,
                      color: DaleColores.verdeLima,
                    ),
                    const SizedBox(width: 7),
                    Text(
                      Sesion.rol.nombre,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _construirEstadistica() {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: DaleColores.borde),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: DaleColores.verdeLima.withOpacity(.35),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.recycling_rounded,
              color: DaleColores.verdeBosque,
              size: 25,
            ),
          ),
          const SizedBox(width: 13),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Objetos compartidos',
                  style: TextStyle(
                    color: DaleColores.carbon,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Cada objeto merece otra oportunidad.',
                  style: TextStyle(color: DaleColores.grisMusgo, fontSize: 11),
                ),
              ],
            ),
          ),
          Text(
            '$_totalPublicaciones',
            style: const TextStyle(
              color: DaleColores.verdeBosque,
              fontSize: 27,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirCerrarSesion() {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: _cerrarSesion,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.red.shade100),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.red.shade50,
                child: Icon(
                  Icons.logout_rounded,
                  color: Colors.red.shade600,
                  size: 20,
                ),
              ),
              const SizedBox(width: 13),
              const Expanded(
                child: Text(
                  'Cerrar sesión',
                  style: TextStyle(
                    color: DaleColores.carbon,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: Colors.red.shade400),
            ],
          ),
        ),
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
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: DaleColores.borde),
          ),
          child: Row(
            children: [
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: DaleColores.verdeLima.withOpacity(.32),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icono, color: DaleColores.verdeBosque, size: 22),
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
                        fontSize: 13,
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

  void _mensaje(String mensaje) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(mensaje)));
  }
}
