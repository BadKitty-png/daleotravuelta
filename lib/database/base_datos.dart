import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class BaseDatos {
  BaseDatos._();

  static final BaseDatos instancia = BaseDatos._();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _inicializarBaseDatos();
    return _database!;
  }

  Future<Database> _inicializarBaseDatos() async {
    final ruta = join(await getDatabasesPath(), 'dale_la_vuelta.db');

    return await openDatabase(
      ruta,
      version: 1,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _crearTablas,
    );
  }

  Future<void> _crearTablas(Database db, int version) async {
    // TABLA DE USUARIOS
    await db.execute('''
      CREATE TABLE usuarios (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        correo TEXT NOT NULL UNIQUE,
        password_hash TEXT NOT NULL,
        municipio TEXT NOT NULL,
        rol TEXT NOT NULL DEFAULT 'usuario'
          CHECK (rol IN ('usuario', 'organizacion', 'administrador')),
        fecha_creacion TEXT NOT NULL
      )
    ''');

    // TABLA DE CATEGORÍAS
    await db.execute('''
      CREATE TABLE categorias (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL UNIQUE
      )
    ''');

    // TABLA DE PUBLICACIONES
    await db.execute('''
      CREATE TABLE publicaciones (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        usuario_id INTEGER NOT NULL,
        categoria TEXT NOT NULL,
        modalidad TEXT NOT NULL
          CHECK (modalidad IN ('Vender', 'Donar', 'Intercambiar', 'Subastar')),
        titulo TEXT NOT NULL,
        marca TEXT,
        modelo TEXT,
        anio INTEGER,
        talla TEXT,
        material TEXT,
        dimensiones TEXT,
        caracteristicas TEXT,
        estado TEXT NOT NULL,
        descripcion TEXT NOT NULL,
        numero_serie TEXT,
        precio REAL NOT NULL DEFAULT 0,
        colonia TEXT,
        latitud REAL,
        longitud REAL,
        estado_publicacion TEXT NOT NULL DEFAULT 'activa'
          CHECK (estado_publicacion IN ('activa', 'pausada', 'vendida', 'eliminada')),
        fecha_creacion TEXT NOT NULL,
        FOREIGN KEY (usuario_id) REFERENCES usuarios(id)
      )
    ''');

    // TABLA DE SESIÓN
    await db.execute('''
      CREATE TABLE sesion (
        id INTEGER PRIMARY KEY CHECK (id = 1),
        usuario_id INTEGER NOT NULL,
        FOREIGN KEY (usuario_id) REFERENCES usuarios(id)
          ON DELETE CASCADE
      )
    ''');

    // ÍNDICES PARA AGILIZAR LAS CONSULTAS
    await db.execute('''
      CREATE INDEX indice_publicaciones_usuario
      ON publicaciones(usuario_id)
    ''');

    await db.execute('''
      CREATE INDEX indice_publicaciones_categoria
      ON publicaciones(categoria)
    ''');

    await db.execute('''
      CREATE INDEX indice_publicaciones_estado
      ON publicaciones(estado_publicacion)
    ''');

    // CATEGORÍAS INICIALES
    final categorias = [
      'Bicicletas',
      'Electrónicas',
      'Muebles',
      'Ropa',
      'Otros productos',
    ];

    final batch = db.batch();

    for (final categoria in categorias) {
      batch.insert('categorias', {'nombre': categoria});
    }

    await batch.commit(noResult: true);
  }
}
