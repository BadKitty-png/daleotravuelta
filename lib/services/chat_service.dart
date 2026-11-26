import 'package:sqflite/sqflite.dart';

import '../database/base_datos.dart';
import '../models/sesion.dart';

class ChatService {
  ChatService._();

  static final ChatService instance = ChatService._();

  int get _miUsuarioId {
    final id = Sesion.usuarioId;

    if (id == null) {
      throw Exception('Debes iniciar sesión para usar el chat.');
    }

    return id;
  }

  Future<String> obtenerNombreUsuario(int usuarioId) async {
    final db = await BaseDatos.instance.database;

    final resultado = await db.query(
      'usuarios',
      columns: ['nombre'],
      where: 'id = ?',
      whereArgs: [usuarioId],
      limit: 1,
    );

    if (resultado.isEmpty) {
      return 'Usuario';
    }

    return resultado.first['nombre'] as String? ?? 'Usuario';
  }

  Future<int> crearORecuperarConversacion({
    required int publicacionId,
    required int vendedorId,
  }) async {
    final compradorId = _miUsuarioId;

    if (compradorId == vendedorId) {
      throw Exception('No puedes iniciar un chat contigo mismo.');
    }

    final db = await BaseDatos.instance.database;

    final existentes = await db.query(
      'conversaciones',
      columns: ['id'],
      where: '''
        publicacion_id = ?
        AND comprador_id = ?
        AND vendedor_id = ?
      ''',
      whereArgs: [publicacionId, compradorId, vendedorId],
      limit: 1,
    );

    if (existentes.isNotEmpty) {
      return (existentes.first['id'] as num).toInt();
    }

    final ahora = DateTime.now().toIso8601String();

    return db.insert('conversaciones', {
      'publicacion_id': publicacionId,
      'comprador_id': compradorId,
      'vendedor_id': vendedorId,
      'fecha_creacion': ahora,
      'ultima_actividad': ahora,
    }, conflictAlgorithm: ConflictAlgorithm.abort);
  }

  Future<List<Map<String, dynamic>>> obtenerConversaciones() async {
    final db = await BaseDatos.instance.database;
    final usuarioId = _miUsuarioId;

    return db.rawQuery(
      '''
      SELECT
        c.id,
        c.publicacion_id,
        c.comprador_id,
        c.vendedor_id,
        c.ultima_actividad,
        p.titulo AS publicacion_titulo,

        CASE
          WHEN c.comprador_id = ? THEN vendedor.nombre
          ELSE comprador.nombre
        END AS otro_nombre,

        CASE
          WHEN c.comprador_id = ? THEN c.vendedor_id
          ELSE c.comprador_id
        END AS otro_usuario_id,

        (
          SELECT m.texto
          FROM mensajes m
          WHERE m.conversacion_id = c.id
          ORDER BY m.fecha_envio DESC
          LIMIT 1
        ) AS ultimo_mensaje,

        (
          SELECT COUNT(*)
          FROM mensajes m
          WHERE m.conversacion_id = c.id
            AND m.autor_id != ?
            AND m.leido = 0
        ) AS no_leidos

      FROM conversaciones c

      INNER JOIN usuarios comprador
        ON comprador.id = c.comprador_id

      INNER JOIN usuarios vendedor
        ON vendedor.id = c.vendedor_id

      LEFT JOIN publicaciones p
        ON p.id = c.publicacion_id

      WHERE c.comprador_id = ?
         OR c.vendedor_id = ?

      ORDER BY c.ultima_actividad DESC
      ''',
      [usuarioId, usuarioId, usuarioId, usuarioId, usuarioId],
    );
  }

  Future<List<Map<String, dynamic>>> obtenerMensajes(int conversacionId) async {
    await _comprobarParticipante(conversacionId);

    final db = await BaseDatos.instance.database;

    return db.rawQuery(
      '''
      SELECT
        m.id,
        m.conversacion_id,
        m.autor_id,
        m.texto,
        m.fecha_envio,
        m.leido,
        u.nombre AS autor_nombre
      FROM mensajes m
      INNER JOIN usuarios u ON u.id = m.autor_id
      WHERE m.conversacion_id = ?
      ORDER BY m.fecha_envio ASC
      ''',
      [conversacionId],
    );
  }

  Future<void> enviarMensaje({
    required int conversacionId,
    required String texto,
  }) async {
    final contenido = texto.trim();

    if (contenido.isEmpty) return;

    if (contenido.length > 2000) {
      throw Exception('El mensaje no puede superar 2000 caracteres.');
    }

    await _comprobarParticipante(conversacionId);

    final db = await BaseDatos.instance.database;
    final ahora = DateTime.now().toIso8601String();

    await db.transaction((txn) async {
      await txn.insert('mensajes', {
        'conversacion_id': conversacionId,
        'autor_id': _miUsuarioId,
        'texto': contenido,
        'fecha_envio': ahora,
        'leido': 0,
      });

      await txn.update(
        'conversaciones',
        {'ultima_actividad': ahora},
        where: 'id = ?',
        whereArgs: [conversacionId],
      );
    });
  }

  Future<void> marcarComoLeidos(int conversacionId) async {
    await _comprobarParticipante(conversacionId);

    final db = await BaseDatos.instance.database;

    await db.update(
      'mensajes',
      {'leido': 1},
      where: '''
        conversacion_id = ?
        AND autor_id != ?
        AND leido = 0
      ''',
      whereArgs: [conversacionId, _miUsuarioId],
    );
  }

  Future<void> _comprobarParticipante(int conversacionId) async {
    final db = await BaseDatos.instance.database;

    final resultado = await db.query(
      'conversaciones',
      columns: ['id'],
      where: '''
        id = ?
        AND (comprador_id = ? OR vendedor_id = ?)
      ''',
      whereArgs: [conversacionId, _miUsuarioId, _miUsuarioId],
      limit: 1,
    );

    if (resultado.isEmpty) {
      throw Exception('No tienes acceso a esta conversación.');
    }
  }
}
