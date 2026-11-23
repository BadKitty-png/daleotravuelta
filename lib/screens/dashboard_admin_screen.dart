import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import '../database/base_datos.dart';
import '../models/sesion.dart';
import '../widgets/dashboard_widgets.dart';

class DashboardAdminScreen extends StatefulWidget {
  const DashboardAdminScreen({super.key});

  @override
  State<DashboardAdminScreen> createState() => _DashboardAdminScreenState();
}

class _DashboardAdminScreenState extends State<DashboardAdminScreen> {
  List<Map<String, dynamic>> _categorias = [];
  List<Map<String, dynamic>> _publicaciones = [];
  List<Map<String, dynamic>> _usuarios = [];

  bool _cargando = true;

  static const Color verde = Color(0xFF3D7050);
  static const Color crema = Color(0xFFF7F8F5);

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  // Cargar información de SQLite
  Future<void> _cargarDatos({bool mostrarCarga = true}) async {
    if (mostrarCarga) {
      setState(() => _cargando = true);
    }

    try {
      final db = await BaseDatos.instance.database;

      final categorias = await db.query(
        'categorias',
        where: 'activa = ?',
        whereArgs: [1],
        orderBy: 'nombre ASC',
      );

      final publicaciones = await db.query(
        'publicaciones',
        orderBy: 'fecha_creacion DESC',
      );

      final usuarios = await db.query('usuarios', orderBy: 'nombre ASC');

      if (!mounted) return;

      setState(() {
        _categorias = categorias;
        _publicaciones = publicaciones;
        _usuarios = usuarios;
        _cargando = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => _cargando = false);
      _mensaje('Error al cargar los datos: $e', error: true);
    }
  }

  // Mostrar mensajes
  void _mensaje(String mensaje, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: error ? Colors.redAccent : verde,
      ),
    );
  }

  // Confirmar eliminación
  Future<bool> _confirmarEliminacion(String mensaje) async {
    final resultado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text(mensaje),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    return resultado ?? false;
  }

  // Agregar categoría
  Future<void> _agregarCategoria() async {
    String nombreCategoria = '';

    final nombre = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Nueva categoría'),
        content: TextField(
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          onChanged: (valor) {
            nombreCategoria = valor;
          },
          decoration: const InputDecoration(
            labelText: 'Nombre de la categoría',
            hintText: 'Ej. Herramientas',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
            },
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext, nombreCategoria.trim());
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );

    if (!mounted || nombre == null || nombre.isEmpty) return;

    try {
      final db = await BaseDatos.instance.database;

      await db.insert('categorias', {
        'nombre': nombre,
      }, conflictAlgorithm: ConflictAlgorithm.abort);

      // Actualiza únicamente los datos, sin reemplazar todo el panel.
      await _cargarDatos(mostrarCarga: false);

      if (!mounted) return;

      _mensaje('Categoría agregada correctamente.');
    } catch (e) {
      if (!mounted) return;

      _mensaje('No se pudo agregar la categoría: $e', error: true);
    }
  }

  // Eliminar publicación
  Future<void> _eliminarPublicacion(Map<String, dynamic> publicacion) async {
    final confirmar = await _confirmarEliminacion(
      '¿Deseas eliminar "${publicacion['titulo']}"? Esta acción no se puede deshacer.',
    );

    if (!confirmar) return;

    try {
      final db = await BaseDatos.instance.database;

      await db.delete(
        'publicaciones',
        where: 'id = ?',
        whereArgs: [publicacion['id']],
      );

      await _cargarDatos();

      if (mounted) _mensaje('Publicación eliminada correctamente.');
    } catch (e) {
      if (mounted)
        _mensaje('No se pudo eliminar la publicación: $e', error: true);
    }
  }

  // Eliminar usuario
  Future<void> _eliminarUsuario(Map<String, dynamic> usuario) async {
    final confirmar = await _confirmarEliminacion(
      '¿Deseas eliminar la cuenta de ${usuario['nombre']}? También se eliminarán sus publicaciones.',
    );

    if (!confirmar) return;

    try {
      final db = await BaseDatos.instance.database;

      await db.delete('usuarios', where: 'id = ?', whereArgs: [usuario['id']]);

      await _cargarDatos();

      if (mounted) _mensaje('Usuario y sus publicaciones eliminados.');
    } catch (e) {
      if (mounted) _mensaje('No se pudo eliminar el usuario: $e', error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DashboardScaffold(
      titulo: 'Panel de administración',
      children: [
        _construirBienvenida(),
        const SizedBox(height: 16),

        if (_cargando)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(30),
              child: CircularProgressIndicator(color: verde),
            ),
          )
        else ...[
          _construirResumen(),
          const SizedBox(height: 18),
          _construirCategorias(),
          const SizedBox(height: 12),
          _construirPublicaciones(),
          const SizedBox(height: 12),
          _construirUsuarios(),
        ],
      ],
    );
  }

  Widget _construirBienvenida() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [verde, Color(0xFF4F8A65)]),
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Row(
        children: [
          Icon(Icons.admin_panel_settings, color: Colors.white, size: 38),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Administración',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Gestiona las categorías, publicaciones y usuarios.',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirResumen() {
    return Row(
      children: [
        _tarjetaResumen(
          Icons.category_outlined,
          _categorias.length,
          'Categorías',
        ),
        const SizedBox(width: 8),
        _tarjetaResumen(
          Icons.inventory_2_outlined,
          _publicaciones.length,
          'Publicaciones',
        ),
        const SizedBox(width: 8),
        _tarjetaResumen(Icons.people_outline, _usuarios.length, 'Usuarios'),
      ],
    );
  }

  Widget _tarjetaResumen(IconData icono, int cantidad, String titulo) {
    return Expanded(
      child: Card(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 5),
          child: Column(
            children: [
              Icon(icono, color: verde, size: 23),
              const SizedBox(height: 7),
              Text(
                '$cantidad',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: verde,
                ),
              ),
              Text(
                titulo,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 10),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _construirCategorias() {
    return Card(
      color: Colors.white,
      child: ExpansionTile(
        initiallyExpanded: true,
        leading: const Icon(Icons.category_outlined, color: verde),
        title: const Text(
          'Categorías',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('${_categorias.length} registradas'),
        children: [
          ..._categorias.map((categoria) {
            return ListTile(
              leading: const Icon(Icons.label_outline, color: verde),
              title: Text(categoria['nombre'].toString()),
            );
          }),
          Padding(
            padding: const EdgeInsets.all(12),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _agregarCategoria,
                icon: const Icon(Icons.add),
                label: const Text('Agregar categoría'),
                style: FilledButton.styleFrom(backgroundColor: verde),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirPublicaciones() {
    return Card(
      color: Colors.white,
      child: ExpansionTile(
        leading: const Icon(Icons.inventory_2_outlined, color: verde),
        title: const Text(
          'Publicaciones',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('${_publicaciones.length} registradas'),
        children: [
          if (_publicaciones.isEmpty)
            const Padding(
              padding: EdgeInsets.all(18),
              child: Text('No hay publicaciones registradas.'),
            ),
          ..._publicaciones.map((publicacion) {
            return ListTile(
              leading: const Icon(Icons.sell_outlined, color: verde),
              title: Text(publicacion['titulo'].toString()),
              subtitle: Text(
                '${publicacion['categoria']} · ${publicacion['municipio']}',
              ),
              trailing: IconButton(
                tooltip: 'Eliminar publicación',
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                onPressed: () => _eliminarPublicacion(publicacion),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _construirUsuarios() {
    return Card(
      color: Colors.white,
      child: ExpansionTile(
        leading: const Icon(Icons.people_outline, color: verde),
        title: const Text(
          'Usuarios',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('${_usuarios.length} registrados'),
        children: [
          if (_usuarios.isEmpty)
            const Padding(
              padding: EdgeInsets.all(18),
              child: Text('No hay usuarios registrados.'),
            ),
          ..._usuarios.map((usuario) {
            return ListTile(
              leading: const CircleAvatar(
                backgroundColor: crema,
                child: Icon(Icons.person_outline, color: verde),
              ),
              title: Text(usuario['nombre'].toString()),
              subtitle: Text(
                '${usuario['correo']}\n${usuario['municipio']} · ${usuario['rol']}',
              ),
              isThreeLine: true,
              trailing: IconButton(
                tooltip: 'Eliminar usuario',
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                onPressed: () => _eliminarUsuario(usuario),
              ),
            );
          }),
        ],
      ),
    );
  }
}
