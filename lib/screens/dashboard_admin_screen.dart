import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import '../database/base_datos.dart';
import '../models/sesion.dart';
import '../services/usuario_service.dart';
import '../widgets/estilo_app.dart';
import 'login_screen.dart';

class DashboardAdminScreen extends StatefulWidget {
  const DashboardAdminScreen({super.key});

  @override
  State<DashboardAdminScreen> createState() => _DashboardAdminScreenState();
}

class _DashboardAdminScreenState extends State<DashboardAdminScreen> {
  int _seccion = 0;
  bool _cargando = true;

  int _totalUsuarios = 0;
  int _usuariosActivos = 0;
  int _totalPublicaciones = 0;
  int _publicacionesActivas = 0;
  int _totalCategorias = 0;

  List<Map<String, dynamic>> _usuarios = [];
  List<Map<String, dynamic>> _publicaciones = [];
  List<Map<String, dynamic>> _categorias = [];

  final TextEditingController _busqueda = TextEditingController();

  String _filtro = '';

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  @override
  void dispose() {
    _busqueda.dispose();
    super.dispose();
  }

  Future<Database> get _db async => BaseDatos.instance.database;

  Future<void> _cargarDatos() async {
    if (mounted) {
      setState(() => _cargando = true);
    }

    try {
      final db = await _db;

      final usuarios = await db.query('usuarios', orderBy: 'id DESC');

      final publicaciones = await db.query('publicaciones', orderBy: 'id DESC');

      final categorias = await db.query('categorias', orderBy: 'nombre ASC');

      final totalUsuarios = await db.rawQuery(
        'SELECT COUNT(*) AS total FROM usuarios',
      );

      final usuariosActivos = await db.rawQuery(
        'SELECT COUNT(*) AS total FROM usuarios WHERE activo = 1',
      );

      final totalPublicaciones = await db.rawQuery(
        'SELECT COUNT(*) AS total FROM publicaciones',
      );

      final publicacionesActivas = await db.rawQuery(
        "SELECT COUNT(*) AS total FROM publicaciones WHERE estado_publicacion = 'activa'",
      );

      if (!mounted) return;

      setState(() {
        _usuarios = usuarios;
        _publicaciones = publicaciones;
        _categorias = categorias;

        _totalUsuarios = (totalUsuarios.first['total'] as int?) ?? 0;

        _usuariosActivos = (usuariosActivos.first['total'] as int?) ?? 0;

        _totalPublicaciones = (totalPublicaciones.first['total'] as int?) ?? 0;

        _publicacionesActivas =
            (publicacionesActivas.first['total'] as int?) ?? 0;

        _totalCategorias = categorias.length;
        _cargando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _cargando = false);
      _mensaje('Error al cargar los datos: $e');
    }
  }

  Future<void> _cerrarSesion() async {
    final confirmar = await _confirmar(
      'Cerrar sesión',
      '¿Deseas salir del panel de administración?',
    );
    if (!confirmar) return;

    await UsuarioService.instance.cerrarSesion();
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
  }

  Future<void> _registrarAdministrador() async {
    final nombre = TextEditingController();
    final correo = TextEditingController();
    final municipio = TextEditingController();
    final password = TextEditingController();
    final confirmarPassword = TextEditingController();
    final formKey = GlobalKey<FormState>();
    var ocultarPassword = true;

    final guardar = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Registrar administrador'),
          content: SizedBox(
            width: 430,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _campoAdministrador(nombre, 'Nombre completo'),
                    _campoAdministrador(
                      correo,
                      'Correo electrónico',
                      tipo: TextInputType.emailAddress,
                    ),
                    _campoAdministrador(municipio, 'Municipio'),
                    _campoAdministrador(
                      password,
                      'Contraseña',
                      ocultar: ocultarPassword,
                      sufijo: IconButton(
                        onPressed: () => setDialogState(
                          () => ocultarPassword = !ocultarPassword,
                        ),
                        icon: Icon(
                          ocultarPassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                      ),
                    ),
                    _campoAdministrador(
                      confirmarPassword,
                      'Confirmar contraseña',
                      ocultar: ocultarPassword,
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: DaleColores.verdeBosque,
              ),
              onPressed: () {
                if (!formKey.currentState!.validate()) return;
                if (password.text != confirmarPassword.text) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Las contraseñas no coinciden.'),
                    ),
                  );
                  return;
                }
                Navigator.pop(context, true);
              },
              child: const Text('Registrar'),
            ),
          ],
        ),
      ),
    );

    if (guardar == true) {
      try {
        await UsuarioService.instance.registrarAdministrador(
          nombre: nombre.text,
          correo: correo.text,
          password: password.text,
          municipio: municipio.text,
        );
        if (mounted) _mensaje('Administrador registrado correctamente.');
        await _cargarDatos();
      } catch (e) {
        if (mounted) {
          _mensaje(e.toString().replaceFirst('Exception: ', ''));
        }
      }
    }

    nombre.dispose();
    correo.dispose();
    municipio.dispose();
    password.dispose();
    confirmarPassword.dispose();
  }

  Widget _campoAdministrador(
    TextEditingController controller,
    String etiqueta, {
    TextInputType tipo = TextInputType.text,
    bool ocultar = false,
    Widget? sufijo,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: tipo,
        obscureText: ocultar,
        validator: (valor) {
          if (valor == null || valor.trim().isEmpty) {
            return 'Este campo es obligatorio.';
          }
          if (ocultar && valor.length < 8) {
            return 'Usa por lo menos 8 caracteres.';
          }
          return null;
        },
        decoration: InputDecoration(
          labelText: etiqueta,
          suffixIcon: sufijo,
          filled: true,
          fillColor: DaleColores.crema,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  void _mensaje(String mensaje) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(mensaje)));
  }

  Future<bool> _confirmar(String titulo, String mensaje) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(titulo),
            content: Text(mensaje),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Confirmar'),
              ),
            ],
          ),
        ) ??
        false;
  }

  List<Map<String, dynamic>> get _usuariosFiltrados {
    return _usuarios.where((u) {
      final texto = _filtro.toLowerCase();
      return (u['nombre'] ?? '').toString().toLowerCase().contains(texto) ||
          (u['correo'] ?? '').toString().toLowerCase().contains(texto);
    }).toList();
  }

  List<Map<String, dynamic>> get _publicacionesFiltradas {
    return _publicaciones.where((p) {
      final texto = _filtro.toLowerCase();
      return (p['titulo'] ?? '').toString().toLowerCase().contains(texto) ||
          (p['categoria'] ?? '').toString().toLowerCase().contains(texto) ||
          (p['marca'] ?? '').toString().toLowerCase().contains(texto);
    }).toList();
  }

  List<Map<String, dynamic>> get _categoriasFiltradas {
    return _categorias.where((c) {
      return (c['nombre'] ?? '').toString().toLowerCase().contains(
        _filtro.toLowerCase(),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DaleColores.crema,
      appBar: AppBar(
        title: const Text(
          'Panel de administración',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: DaleColores.verdeBosque,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Registrar administrador',
            onPressed: _registrarAdministrador,
            icon: const Icon(Icons.person_add_alt_1_rounded),
          ),
          IconButton(
            tooltip: 'Actualizar',
            onPressed: _cargarDatos,
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            tooltip: 'Cerrar sesión',
            onPressed: _cerrarSesion,
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: _cargando
          ? const Center(
              child: CircularProgressIndicator(color: DaleColores.verdeBosque),
            )
          : RefreshIndicator(
              onRefresh: _cargarDatos,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _encabezado(),
                  const SizedBox(height: 20),
                  _resumen(),
                  const SizedBox(height: 24),
                  _navegacion(),
                  const SizedBox(height: 16),
                  if (_seccion != 0) _buscador(),
                  _contenidoSeccion(),
                ],
              ),
            ),
    );
  }

  Widget _encabezado() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [DaleColores.verdeBosque, DaleColores.verdeClaro],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Stack(
        children: [
          Positioned.fill(child: DecoracionOrganica()),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.admin_panel_settings, color: Colors.white, size: 36),
              SizedBox(height: 12),
              Text(
                'Bienvenido, administrador',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 5),
              Text(
                'Administra los usuarios, publicaciones y categorías de Dale la Vuelta.',
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _resumen() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Resumen general',
          style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.25,
          children: [
            _tarjetaResumen(
              'Usuarios',
              '$_totalUsuarios',
              Icons.people,
              DaleColores.verdeClaro,
            ),
            _tarjetaResumen(
              'Usuarios activos',
              '$_usuariosActivos',
              Icons.person,
              DaleColores.verdeBosque,
            ),
            _tarjetaResumen(
              'Publicaciones',
              '$_totalPublicaciones',
              Icons.inventory_2,
              DaleColores.ambar,
            ),
            _tarjetaResumen(
              'Publicaciones activas',
              '$_publicacionesActivas',
              Icons.check_circle,
              DaleColores.verdeClaro,
            ),
            _tarjetaResumen(
              'Categorías',
              '$_totalCategorias',
              Icons.category,
              DaleColores.verdeLima,
            ),
          ],
        ),
      ],
    );
  }

  Widget _tarjetaResumen(
    String titulo,
    String cantidad,
    IconData icono,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: DaleColores.blanco,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: DaleColores.borde),
        boxShadow: [
          BoxShadow(
            color: DaleColores.carbon.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icono, color: color, size: 25),
          const SizedBox(height: 8),
          Text(
            cantidad,
            style: const TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
          ),
          Text(
            titulo,
            style: const TextStyle(fontSize: 12, color: DaleColores.grisMusgo),
          ),
        ],
      ),
    );
  }

  Widget _navegacion() {
    final opciones = [
      ('Resumen', Icons.dashboard),
      ('Usuarios', Icons.people),
      ('Publicaciones', Icons.inventory_2),
      ('Categorías', Icons.category),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(opciones.length, (i) {
        return ChoiceChip(
          selected: _seccion == i,
          selectedColor: DaleColores.verdeBosque,
          backgroundColor: DaleColores.blanco,
          side: BorderSide(
            color: _seccion == i ? DaleColores.verdeBosque : DaleColores.borde,
          ),
          labelStyle: TextStyle(
            color: _seccion == i ? Colors.white : DaleColores.carbon,
            fontWeight: FontWeight.w600,
          ),
          checkmarkColor: Colors.white,
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(opciones[i].$2, size: 17),
              const SizedBox(width: 5),
              Text(opciones[i].$1),
            ],
          ),
          onSelected: (_) {
            setState(() {
              _seccion = i;
              _filtro = '';
              _busqueda.clear();
            });
          },
        );
      }),
    );
  }

  Widget _buscador() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: _busqueda,
        onChanged: (valor) => setState(() => _filtro = valor),
        decoration: InputDecoration(
          hintText: 'Buscar...',
          prefixIcon: const Icon(Icons.search, color: DaleColores.verdeBosque),
          filled: true,
          fillColor: DaleColores.blanco,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: DaleColores.borde),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: DaleColores.borde),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: DaleColores.verdeBosque,
              width: 1.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _contenidoSeccion() {
    switch (_seccion) {
      case 1:
        return _listaUsuarios();
      case 2:
        return _listaPublicaciones();
      case 3:
        return _listaCategorias();
      default:
        return _actividadResumen();
    }
  }

  Widget _actividadResumen() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: DaleColores.blanco,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: DaleColores.borde),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Administración del sistema',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text('Selecciona una sección para administrar sus registros.'),
          SizedBox(height: 12),
          Text('• Usuarios: editar, activar, desactivar y eliminar.'),
          Text('• Publicaciones: editar y eliminar.'),
          Text('• Categorías: agregar, editar, activar y eliminar.'),
        ],
      ),
    );
  }

  Widget _listaUsuarios() {
    if (_usuariosFiltrados.isEmpty) {
      return _vacio('No se encontraron usuarios.');
    }

    return Column(
      children: _usuariosFiltrados.map((usuario) {
        final activo = usuario['activo'] == 1;
        final esActual = usuario['id'] == Sesion.usuarioId;

        return _tarjetaRegistro(
          titulo: usuario['nombre']?.toString() ?? '',
          subtitulo:
              '${usuario['correo']}\n${usuario['municipio']} · ${usuario['rol']}',
          icono: Icons.person,
          estado: activo ? 'Activo' : 'Inactivo',
          colorEstado: activo ? DaleColores.verdeBosque : Colors.red,
          acciones: [
            IconButton(
              tooltip: 'Editar',
              onPressed: () => _editarUsuario(usuario),
              icon: const Icon(Icons.edit, color: DaleColores.verdeBosque),
            ),
            IconButton(
              tooltip: activo ? 'Desactivar' : 'Activar',
              onPressed: esActual ? null : () => _cambiarEstadoUsuario(usuario),
              icon: Icon(
                activo ? Icons.block : Icons.check_circle,
                color: activo ? DaleColores.ambar : DaleColores.verdeBosque,
              ),
            ),
            IconButton(
              tooltip: 'Eliminar',
              onPressed: esActual ? null : () => _eliminarUsuario(usuario),
              icon: const Icon(Icons.delete, color: Colors.red),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _listaPublicaciones() {
    if (_publicacionesFiltradas.isEmpty) {
      return _vacio('No se encontraron publicaciones.');
    }

    return Column(
      children: _publicacionesFiltradas.map((publicacion) {
        return _tarjetaRegistro(
          titulo: publicacion['titulo']?.toString() ?? 'Sin título',
          subtitulo:
              '${publicacion['categoria']} · \$${publicacion['precio']}\n${publicacion['municipio']}',
          icono: Icons.inventory_2,
          estado: publicacion['estado_publicacion']?.toString() ?? '',
          colorEstado: DaleColores.verdeClaro,
          acciones: [
            IconButton(
              tooltip: 'Editar',
              onPressed: () => _editarPublicacion(publicacion),
              icon: const Icon(Icons.edit, color: DaleColores.verdeBosque),
            ),
            IconButton(
              tooltip: 'Eliminar',
              onPressed: () => _eliminarPublicacion(publicacion),
              icon: const Icon(Icons.delete, color: Colors.red),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _listaCategorias() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _agregarCategoria,
            icon: const Icon(Icons.add),
            style: FilledButton.styleFrom(
              backgroundColor: DaleColores.verdeBosque,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(48),
            ),
            label: const Text('Agregar categoría'),
          ),
        ),
        const SizedBox(height: 12),
        if (_categoriasFiltradas.isEmpty)
          _vacio('No se encontraron categorías.')
        else
          ..._categoriasFiltradas.map((categoria) {
            final activa = categoria['activa'] == 1;

            return _tarjetaRegistro(
              titulo: categoria['nombre'].toString(),
              subtitulo: 'ID: ${categoria['id']}',
              icono: Icons.category,
              estado: activa ? 'Activa' : 'Inactiva',
              colorEstado: activa ? DaleColores.verdeBosque : Colors.red,
              acciones: [
                IconButton(
                  tooltip: 'Editar',
                  onPressed: () => _editarCategoria(categoria),
                  icon: const Icon(Icons.edit, color: DaleColores.verdeBosque),
                ),
                IconButton(
                  tooltip: activa ? 'Desactivar' : 'Activar',
                  onPressed: () => _cambiarEstadoCategoria(categoria),
                  icon: Icon(
                    activa ? Icons.visibility_off : Icons.visibility,
                    color: DaleColores.ambar,
                  ),
                ),
                IconButton(
                  tooltip: 'Eliminar',
                  onPressed: () => _eliminarCategoria(categoria),
                  icon: const Icon(Icons.delete, color: Colors.red),
                ),
              ],
            );
          }),
      ],
    );
  }

  Widget _tarjetaRegistro({
    required String titulo,
    required String subtitulo,
    required IconData icono,
    required String estado,
    required Color colorEstado,
    required List<Widget> acciones,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: DaleColores.blanco,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: DaleColores.borde),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: DaleColores.verdeLima.withValues(alpha: 0.35),
              child: Icon(icono, color: DaleColores.verdeBosque),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitulo,
                    style: const TextStyle(
                      fontSize: 12,
                      color: DaleColores.grisMusgo,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    estado,
                    style: TextStyle(
                      fontSize: 12,
                      color: colorEstado,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Wrap(spacing: 0, children: acciones),
          ],
        ),
      ),
    );
  }

  Widget _vacio(String mensaje) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: DaleColores.blanco,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: DaleColores.borde),
      ),
      child: Column(
        children: [
          const Icon(Icons.search_off, size: 38, color: DaleColores.grisMusgo),
          const SizedBox(height: 10),
          Text(mensaje, textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Future<void> _editarUsuario(Map<String, dynamic> usuario) async {
    final nombre = TextEditingController(text: usuario['nombre']?.toString());
    final correo = TextEditingController(text: usuario['correo']?.toString());
    final municipio = TextEditingController(
      text: usuario['municipio']?.toString(),
    );

    String rol = usuario['rol']?.toString() ?? 'usuario';

    final resultado = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Editar usuario'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _campo(nombre, 'Nombre'),
                _campo(correo, 'Correo electrónico'),
                _campo(municipio, 'Municipio'),
                DropdownButtonFormField<String>(
                  initialValue: rol,
                  decoration: const InputDecoration(labelText: 'Rol'),
                  items: const [
                    DropdownMenuItem(value: 'usuario', child: Text('Usuario')),
                    DropdownMenuItem(
                      value: 'organizacion',
                      child: Text('Organización'),
                    ),
                    DropdownMenuItem(
                      value: 'administrador',
                      child: Text('Administrador'),
                    ),
                  ],
                  onChanged: (valor) {
                    if (valor != null) {
                      setDialogState(() => rol = valor);
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );

    if (resultado == true) {
      try {
        final db = await _db;
        final correoLimpio = correo.text.trim().toLowerCase();

        final duplicado = await db.query(
          'usuarios',
          where: 'correo = ? AND id != ?',
          whereArgs: [correoLimpio, usuario['id']],
          limit: 1,
        );

        if (duplicado.isNotEmpty) {
          _mensaje('Ese correo ya pertenece a otro usuario.');
        } else {
          await db.update(
            'usuarios',
            {
              'nombre': nombre.text.trim(),
              'correo': correoLimpio,
              'municipio': municipio.text.trim(),
              'rol': rol,
            },
            where: 'id = ?',
            whereArgs: [usuario['id']],
          );

          _mensaje('Usuario actualizado correctamente.');
        }
      } catch (e) {
        _mensaje('No se pudo actualizar el usuario: $e');
      }

      await _cargarDatos();
    }

    nombre.dispose();
    correo.dispose();
    municipio.dispose();
  }

  Future<void> _cambiarEstadoUsuario(Map<String, dynamic> usuario) async {
    final activo = usuario['activo'] == 1;

    final confirmar = await _confirmar(
      activo ? 'Desactivar usuario' : 'Activar usuario',
      activo
          ? '¿Deseas desactivar esta cuenta?'
          : '¿Deseas activar esta cuenta?',
    );

    if (!confirmar) return;

    try {
      final db = await _db;
      await db.update(
        'usuarios',
        {'activo': activo ? 0 : 1},
        where: 'id = ?',
        whereArgs: [usuario['id']],
      );

      if (activo) {
        await db.delete(
          'sesion',
          where: 'usuario_id = ?',
          whereArgs: [usuario['id']],
        );
      }

      _mensaje('Estado del usuario actualizado.');
      await _cargarDatos();
    } catch (e) {
      _mensaje('Error al cambiar el estado: $e');
    }
  }

  Future<void> _eliminarUsuario(Map<String, dynamic> usuario) async {
    final confirmar = await _confirmar(
      'Eliminar usuario',
      'Se eliminará la cuenta de ${usuario['nombre']} y sus datos relacionados. ¿Continuar?',
    );

    if (!confirmar) return;

    try {
      final db = await _db;
      await db.delete('usuarios', where: 'id = ?', whereArgs: [usuario['id']]);

      _mensaje('Usuario eliminado correctamente.');
      await _cargarDatos();
    } catch (e) {
      _mensaje('No se pudo eliminar el usuario: $e');
    }
  }

  Future<void> _editarPublicacion(Map<String, dynamic> publicacion) async {
    final campos = <String, TextEditingController>{
      'titulo': TextEditingController(
        text: publicacion['titulo']?.toString() ?? '',
      ),
      'marca': TextEditingController(
        text: publicacion['marca']?.toString() ?? '',
      ),
      'modelo': TextEditingController(
        text: publicacion['modelo']?.toString() ?? '',
      ),
      'anio': TextEditingController(
        text: publicacion['anio']?.toString() ?? '',
      ),
      'talla': TextEditingController(
        text: publicacion['talla']?.toString() ?? '',
      ),
      'estado_producto': TextEditingController(
        text: publicacion['estado_producto']?.toString() ?? '',
      ),
      'descripcion': TextEditingController(
        text: publicacion['descripcion']?.toString() ?? '',
      ),
      'numero_serie': TextEditingController(
        text: publicacion['numero_serie']?.toString() ?? '',
      ),
      'caracteristicas': TextEditingController(
        text: publicacion['caracteristicas']?.toString() ?? '',
      ),
      'precio': TextEditingController(
        text: publicacion['precio']?.toString() ?? '',
      ),
      'colonia': TextEditingController(
        text: publicacion['colonia']?.toString() ?? '',
      ),
      'municipio': TextEditingController(
        text: publicacion['municipio']?.toString() ?? '',
      ),
    };

    String categoria = publicacion['categoria']?.toString() ?? '';
    String modalidad = publicacion['modalidad']?.toString() ?? '';
    String estadoPublicacion =
        publicacion['estado_publicacion']?.toString() ?? 'activa';
    bool aceptaOfertas = publicacion['acepta_ofertas'] == 1;

    final db = await _db;
    final categorias = await db.query(
      'categorias',
      where: 'activa = 1',
      orderBy: 'nombre ASC',
    );

    if (!mounted) return;

    if (categorias.isNotEmpty &&
        !categorias.any((c) => c['nombre'] == categoria)) {
      categoria = categorias.first['nombre'].toString();
    }

    final resultado = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Editar publicación'),
          content: SizedBox(
            width: 450,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ...campos.entries.map((entry) {
                    return _campo(
                      entry.value,
                      _etiqueta(entry.key),
                      multiline:
                          entry.key == 'descripcion' ||
                          entry.key == 'caracteristicas',
                      numero: entry.key == 'precio' || entry.key == 'anio',
                    );
                  }),
                  DropdownButtonFormField<String>(
                    initialValue:
                        categorias.any((c) => c['nombre'] == categoria)
                        ? categoria
                        : null,
                    decoration: const InputDecoration(labelText: 'Categoría'),
                    items: categorias.map((c) {
                      final nombre = c['nombre'].toString();
                      return DropdownMenuItem(
                        value: nombre,
                        child: Text(nombre),
                      );
                    }).toList(),
                    onChanged: (v) {
                      if (v != null) {
                        setDialogState(() => categoria = v);
                      }
                    },
                  ),
                  _campoSimpleDropdown('Modalidad', modalidad, [
                    'venta',
                    'intercambio',
                    'donacion',
                  ], (v) => setDialogState(() => modalidad = v)),
                  _campoSimpleDropdown(
                    'Estado de publicación',
                    estadoPublicacion,
                    ['activa', 'pausada', 'vendida'],
                    (v) => setDialogState(() => estadoPublicacion = v),
                  ),
                  SwitchListTile(
                    title: const Text('Acepta ofertas'),
                    value: aceptaOfertas,
                    onChanged: (v) => setDialogState(() => aceptaOfertas = v),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );

    if (resultado == true) {
      try {
        final precio = double.tryParse(campos['precio']!.text.trim());
        final anioTexto = campos['anio']!.text.trim();
        final anio = anioTexto.isEmpty ? null : int.tryParse(anioTexto);

        if (precio == null || precio < 0) {
          _mensaje('Ingresa un precio válido.');
        } else if (anioTexto.isNotEmpty && anio == null) {
          _mensaje('Ingresa un año válido.');
        } else if (categoria.isEmpty) {
          _mensaje('Selecciona una categoría.');
        } else {
          final datos = <String, Object?>{
            for (final entry in campos.entries)
              if (entry.key != 'precio' && entry.key != 'anio')
                entry.key: entry.value.text.trim(),
            'precio': precio,
            'anio': anio,
            'categoria': categoria,
            'modalidad': modalidad,
            'estado_publicacion': estadoPublicacion,
            'acepta_ofertas': aceptaOfertas ? 1 : 0,
          };

          await db.update(
            'publicaciones',
            datos,
            where: 'id = ?',
            whereArgs: [publicacion['id']],
          );

          _mensaje('Publicación actualizada correctamente.');
        }
      } catch (e) {
        _mensaje('No se pudo actualizar la publicación: $e');
      }

      await _cargarDatos();
    }

    for (final controller in campos.values) {
      controller.dispose();
    }
  }

  String _etiqueta(String campo) {
    const etiquetas = {
      'titulo': 'Título',
      'marca': 'Marca',
      'modelo': 'Modelo',
      'anio': 'Año',
      'talla': 'Talla',
      'estado_producto': 'Estado del producto',
      'descripcion': 'Descripción',
      'numero_serie': 'Número de serie',
      'caracteristicas': 'Características',
      'precio': 'Precio',
      'colonia': 'Colonia',
      'municipio': 'Municipio',
    };

    return etiquetas[campo] ?? campo;
  }

  Future<void> _eliminarPublicacion(Map<String, dynamic> publicacion) async {
    final confirmar = await _confirmar(
      'Eliminar publicación',
      '¿Deseas eliminar "${publicacion['titulo']}"? También se eliminarán los datos relacionados por las reglas de la base de datos.',
    );

    if (!confirmar) return;

    try {
      final db = await _db;
      await db.delete(
        'publicaciones',
        where: 'id = ?',
        whereArgs: [publicacion['id']],
      );

      _mensaje('Publicación eliminada.');
      await _cargarDatos();
    } catch (e) {
      _mensaje('No se pudo eliminar la publicación: $e');
    }
  }

  Future<void> _agregarCategoria() async {
    final controller = TextEditingController();

    final resultado = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nueva categoría'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Nombre de la categoría',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Agregar'),
          ),
        ],
      ),
    );

    controller.dispose();

    if (resultado == null || resultado.isEmpty) return;

    try {
      final db = await _db;
      await db.insert('categorias', {
        'nombre': resultado,
        'activa': 1,
      }, conflictAlgorithm: ConflictAlgorithm.abort);

      _mensaje('Categoría agregada.');
      await _cargarDatos();
    } catch (e) {
      _mensaje('No se pudo agregar. Comprueba que no exista otra igual.');
    }
  }

  Future<void> _editarCategoria(Map<String, dynamic> categoria) async {
    final controller = TextEditingController(
      text: categoria['nombre'].toString(),
    );

    final resultado = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar categoría'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Nombre'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );

    controller.dispose();

    if (resultado == null || resultado.isEmpty) return;

    try {
      final db = await _db;

      await db.transaction((txn) async {
        await txn.update(
          'categorias',
          {'nombre': resultado},
          where: 'id = ?',
          whereArgs: [categoria['id']],
        );

        await txn.update(
          'publicaciones',
          {'categoria': resultado},
          where: 'categoria = ?',
          whereArgs: [categoria['nombre']],
        );
      });

      _mensaje('Categoría actualizada.');
      await _cargarDatos();
    } catch (e) {
      _mensaje('No se pudo actualizar la categoría: $e');
    }
  }

  Future<void> _cambiarEstadoCategoria(Map<String, dynamic> categoria) async {
    final activa = categoria['activa'] == 1;

    final confirmar = await _confirmar(
      activa ? 'Desactivar categoría' : 'Activar categoría',
      '¿Deseas cambiar el estado de esta categoría?',
    );

    if (!confirmar) return;

    try {
      final db = await _db;
      await db.update(
        'categorias',
        {'activa': activa ? 0 : 1},
        where: 'id = ?',
        whereArgs: [categoria['id']],
      );

      _mensaje('Estado de categoría actualizado.');
      await _cargarDatos();
    } catch (e) {
      _mensaje('No se pudo cambiar el estado: $e');
    }
  }

  Future<void> _eliminarCategoria(Map<String, dynamic> categoria) async {
    final db = await _db;

    final publicaciones = await db.query(
      'publicaciones',
      where: 'categoria = ?',
      whereArgs: [categoria['nombre']],
      limit: 1,
    );

    if (publicaciones.isNotEmpty) {
      _mensaje(
        'No puedes eliminar esta categoría porque tiene publicaciones asociadas. Desactívala en su lugar.',
      );
      return;
    }

    final confirmar = await _confirmar(
      'Eliminar categoría',
      '¿Deseas eliminar "${categoria['nombre']}"?',
    );

    if (!confirmar) return;

    try {
      await db.delete(
        'categorias',
        where: 'id = ?',
        whereArgs: [categoria['id']],
      );

      _mensaje('Categoría eliminada.');
      await _cargarDatos();
    } catch (e) {
      _mensaje('No se pudo eliminar la categoría: $e');
    }
  }

  Widget _campo(
    TextEditingController controller,
    String etiqueta, {
    bool multiline = false,
    bool numero = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        maxLines: multiline ? 3 : 1,
        keyboardType: numero
            ? const TextInputType.numberWithOptions(decimal: true)
            : TextInputType.text,
        decoration: InputDecoration(
          labelText: etiqueta,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _campoSimpleDropdown(
    String etiqueta,
    String valor,
    List<String> opciones,
    ValueChanged<String> onChanged,
  ) {
    final valorActual = opciones.contains(valor) ? valor : opciones.first;

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: DropdownButtonFormField<String>(
        initialValue: valorActual,
        decoration: InputDecoration(labelText: etiqueta),
        items: opciones.map((opcion) {
          return DropdownMenuItem(value: opcion, child: Text(opcion));
        }).toList(),
        onChanged: (v) {
          if (v != null) onChanged(v);
        },
      ),
    );
  }
}
