import 'dart:convert';
import 'dart:math';

import 'package:cryptography/cryptography.dart';
import 'package:sqflite/sqflite.dart';

import '../database/base_datos.dart';

class UsuarioService {
  static final UsuarioService instance = UsuarioService._init();

  UsuarioService._init();

  final _algoritmo = Pbkdf2(
    macAlgorithm: Hmac.sha256(),
    iterations: 100000,
    bits: 256,
  );

  // Generar sal aleatoria
  List<int> _generarSal() {
    final random = Random.secure();
    return List<int>.generate(16, (_) => random.nextInt(256));
  }

  // Crear hash de contraseña
  Future<String> _crearHash(String password, List<int> sal) async {
    final key = await _algoritmo.deriveKey(
      secretKey: SecretKey(utf8.encode(password)),
      nonce: sal,
    );

    final bytes = await key.extractBytes();

    return '${base64Encode(sal)}:${base64Encode(bytes)}';
  }

  // Verificar contraseña
  Future<bool> _verificarPassword(String password, String hashGuardado) async {
    try {
      final partes = hashGuardado.split(':');

      if (partes.length != 2) return false;

      final sal = base64Decode(partes[0]);
      final hashOriginal = base64Decode(partes[1]);

      final hashNuevo = await _algoritmo.deriveKey(
        secretKey: SecretKey(utf8.encode(password)),
        nonce: sal,
      );

      final bytes = await hashNuevo.extractBytes();

      return _compararBytes(bytes, hashOriginal);
    } catch (_) {
      return false;
    }
  }

  bool _compararBytes(List<int> a, List<int> b) {
    if (a.length != b.length) return false;

    int diferencia = 0;

    for (int i = 0; i < a.length; i++) {
      diferencia |= a[i] ^ b[i];
    }

    return diferencia == 0;
  }

  // Registrar usuario
  Future<int> registrarUsuario({
    required String nombre,
    required String correo,
    required String password,
    required String municipio,
    required String rol,
  }) async {
    final db = await BaseDatos.instance.database;

    final correoLimpio = correo.trim().toLowerCase();

    if (password.length < 8) {
      throw Exception('La contraseña debe tener al menos 8 caracteres.');
    }

    if (rol != 'usuario' && rol != 'organizacion') {
      throw Exception('El rol seleccionado no está permitido.');
    }

    final existente = await db.query(
      'usuarios',
      where: 'correo = ?',
      whereArgs: [correoLimpio],
      limit: 1,
    );

    if (existente.isNotEmpty) {
      throw Exception('Este correo ya está registrado.');
    }

    final sal = _generarSal();
    final hash = await _crearHash(password, sal);

    final id = await db.insert('usuarios', {
      'nombre': nombre.trim(),
      'correo': correoLimpio,
      'password_hash': hash,
      'municipio': municipio,
      'rol': rol,
      'fecha_creacion': DateTime.now().toIso8601String(),
      'activo': 1,
    }, conflictAlgorithm: ConflictAlgorithm.abort);

    return id;
  }

  // Iniciar sesión
  Future<Map<String, dynamic>> iniciarSesion({
    required String correo,
    required String password,
  }) async {
    final db = await BaseDatos.instance.database;

    final resultado = await db.query(
      'usuarios',
      where: 'correo = ? AND activo = 1',
      whereArgs: [correo.trim().toLowerCase()],
      limit: 1,
    );

    if (resultado.isEmpty) {
      throw Exception('Correo o contraseña incorrectos.');
    }

    final usuario = resultado.first;

    final valido = await _verificarPassword(
      password,
      usuario['password_hash'] as String,
    );

    if (!valido) {
      throw Exception('Correo o contraseña incorrectos.');
    }

    await db.insert('sesion', {
      'id': 1,
      'usuario_id': usuario['id'],
      'fecha_inicio': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);

    return usuario;
  }

  // Recuperar sesión guardada
  Future<Map<String, dynamic>?> obtenerSesion() async {
    final db = await BaseDatos.instance.database;

    final resultado = await db.rawQuery('''
      SELECT usuarios.*
      FROM sesion
      INNER JOIN usuarios
      ON sesion.usuario_id = usuarios.id
      WHERE sesion.id = 1 AND usuarios.activo = 1
      LIMIT 1
    ''');

    if (resultado.isEmpty) {
      return null;
    }

    return resultado.first;
  }

  // Cerrar sesión
  Future<void> cerrarSesion() async {
    final db = await BaseDatos.instance.database;

    await db.delete('sesion', where: 'id = ?', whereArgs: [1]);
  }
}
