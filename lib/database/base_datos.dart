import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class BaseDatos {
  // Instancia única de la base de datos
  static final BaseDatos instance = BaseDatos._init();

  static Database? _database;

  BaseDatos._init();

  // Obtener la base de datos
  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('dale_la_vuelta.db');
    return _database!;
  }

  // Crear o abrir la base de datos
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final pathDB = join(dbPath, filePath);

    return await openDatabase(
      pathDB,
      version: 2,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _crearTablas,
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
            'ALTER TABLE publicaciones ADD COLUMN caracteristicas TEXT',
          );

          await db.execute(
            'ALTER TABLE publicaciones ADD COLUMN acepta_ofertas INTEGER NOT NULL DEFAULT 0',
          );
        }
      },
    );
  }

  // Crear las tablas
  Future<void> _crearTablas(Database db, int version) async {
    // Tabla de usuarios
    await db.execute('''
      CREATE TABLE usuarios (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        correo TEXT NOT NULL UNIQUE,
        password_hash TEXT NOT NULL,
        municipio TEXT NOT NULL,
        rol TEXT NOT NULL DEFAULT 'usuario',
        fecha_creacion TEXT NOT NULL,
        activo INTEGER NOT NULL DEFAULT 1
      )
    ''');

    // Tabla de publicaciones
    await db.execute('''
      CREATE TABLE publicaciones (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        usuario_id INTEGER NOT NULL,
        categoria TEXT NOT NULL,
        modalidad TEXT NOT NULL,
        titulo TEXT NOT NULL,
        marca TEXT,
        modelo TEXT,
        anio INTEGER,
        talla TEXT,
        estado_producto TEXT NOT NULL,
        descripcion TEXT NOT NULL,
        numero_serie TEXT,
        caracteristicas TEXT,
        acepta_ofertas INTEGER NOT NULL DEFAULT 0,
        precio REAL NOT NULL DEFAULT 0,
        colonia TEXT,
        municipio TEXT NOT NULL,
        estado_publicacion TEXT NOT NULL DEFAULT 'activa',
        fecha_creacion TEXT NOT NULL,
        FOREIGN KEY (usuario_id)
          REFERENCES usuarios(id)
          ON DELETE CASCADE
      )
    ''');

    // Tabla de categorías
    await db.execute('''
      CREATE TABLE categorias (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL UNIQUE,
        activa INTEGER NOT NULL DEFAULT 1
      )
    ''');

    // Tabla de sesión
    await db.execute('''
      CREATE TABLE sesion (
        id INTEGER PRIMARY KEY CHECK (id = 1),
        usuario_id INTEGER NOT NULL,
        fecha_inicio TEXT NOT NULL,
        FOREIGN KEY (usuario_id)
          REFERENCES usuarios(id)
          ON DELETE CASCADE
      )
    ''');

    // Categorías iniciales
    final categorias = [
      'Bicicletas',
      'Electrónicas',
      'Muebles',
      'Ropa',
      'Otros productos',
    ];

    for (final categoria in categorias) {
      await db.insert('categorias', {'nombre': categoria});
    }

    // Índices para agilizar las consultas
    await db.execute('''
      CREATE INDEX idx_publicaciones_usuario
      ON publicaciones(usuario_id)
    ''');

    await db.execute('''
      CREATE INDEX idx_publicaciones_categoria
      ON publicaciones(categoria)
    ''');

    await db.execute('''
      CREATE INDEX idx_publicaciones_estado
      ON publicaciones(estado_publicacion)
    ''');
  }

  // Cerrar conexión
  Future<void> cerrar() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
