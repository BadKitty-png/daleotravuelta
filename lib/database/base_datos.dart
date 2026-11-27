import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class BaseDatos {
  static final BaseDatos instance = BaseDatos._init();

  static Database? _database;

  BaseDatos._init();

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDB('dale_la_vuelta.db');

    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final pathDB = join(dbPath, filePath);

    return openDatabase(
      pathDB,
      version: 7,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _crearTablas,
      onUpgrade: (db, oldVersion, newVersion) async {
        // Migración de versión 1 a versión 2.
        if (oldVersion < 2) {
          await db.execute(
            'ALTER TABLE publicaciones ADD COLUMN caracteristicas TEXT',
          );

          await db.execute(
            'ALTER TABLE publicaciones '
            'ADD COLUMN acepta_ofertas INTEGER NOT NULL DEFAULT 0',
          );
        }

        // Migración de versión 2 a versión 3.
        if (oldVersion < 3) {
          await _crearTablasChat(db);
        }

        // Migración de versión 3 a versión 4.
        if (oldVersion < 4) {
          await _crearTablaImagenes(db);
        }

        // Migración de versión 4 a versión 5.
        if (oldVersion < 5) {
          await _crearTablaFavoritos(db);
        }

        // Migración de versión 5 a versión 6.
        if (oldVersion < 6) {
          await db.execute('ALTER TABLE publicaciones ADD COLUMN latitud REAL');

          await db.execute(
            'ALTER TABLE publicaciones ADD COLUMN longitud REAL',
          );

          await db.execute(
            'ALTER TABLE publicaciones ADD COLUMN referencia TEXT',
          );
        }
      },
    );
  }

  Future<void> _crearTablas(Database db, int version) async {
    // Tabla de usuarios.
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

    // Tabla de publicaciones.
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
        latitud REAL,
        longitud REAL,
        referencia TEXT,
        estado_publicacion TEXT NOT NULL DEFAULT 'activa',
        fecha_creacion TEXT NOT NULL,

        FOREIGN KEY (usuario_id)
          REFERENCES usuarios(id)
          ON DELETE CASCADE
      )
    ''');

    // Tabla de categorías.
    await db.execute('''
      CREATE TABLE categorias (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL UNIQUE,
        activa INTEGER NOT NULL DEFAULT 1
      )
    ''');

    // Tabla de sesión.
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

    // Crear tablas complementarias en instalaciones nuevas.
    await _crearTablasChat(db);
    await _crearTablaImagenes(db);
    await _crearTablaFavoritos(db);
  }

  Future<void> _crearTablasChat(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS conversaciones (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        publicacion_id INTEGER NOT NULL,
        comprador_id INTEGER NOT NULL,
        vendedor_id INTEGER NOT NULL,
        fecha_creacion TEXT NOT NULL,
        ultima_actividad TEXT NOT NULL,

        FOREIGN KEY (publicacion_id)
          REFERENCES publicaciones(id)
          ON DELETE CASCADE,

        FOREIGN KEY (comprador_id)
          REFERENCES usuarios(id)
          ON DELETE CASCADE,

        FOREIGN KEY (vendedor_id)
          REFERENCES usuarios(id)
          ON DELETE CASCADE,

        CHECK (comprador_id != vendedor_id),

        UNIQUE (
          publicacion_id,
          comprador_id,
          vendedor_id
        )
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS mensajes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        conversacion_id INTEGER NOT NULL,
        autor_id INTEGER NOT NULL,
        texto TEXT NOT NULL,
        fecha_envio TEXT NOT NULL,
        leido INTEGER NOT NULL DEFAULT 0,

        FOREIGN KEY (conversacion_id)
          REFERENCES conversaciones(id)
          ON DELETE CASCADE,

        FOREIGN KEY (autor_id)
          REFERENCES usuarios(id)
          ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_conversaciones_comprador
      ON conversaciones(comprador_id)
    ''');

    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_conversaciones_vendedor
      ON conversaciones(vendedor_id)
    ''');

    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_conversaciones_publicacion
      ON conversaciones(publicacion_id)
    ''');

    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_mensajes_conversacion
      ON mensajes(conversacion_id, fecha_envio)
    ''');

    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_mensajes_autor
      ON mensajes(autor_id)
    ''');
  }

  Future<void> _crearTablaImagenes(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS publicacion_imagenes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        publicacion_id INTEGER NOT NULL,
        ruta TEXT NOT NULL,
        posicion INTEGER NOT NULL DEFAULT 0,

        FOREIGN KEY (publicacion_id)
          REFERENCES publicaciones(id)
          ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_imagenes_publicacion
      ON publicacion_imagenes(publicacion_id, posicion)
    ''');
  }

  Future<void> _crearTablaFavoritos(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS favoritos (
        usuario_id INTEGER NOT NULL,
        publicacion_id INTEGER NOT NULL,
        fecha_creacion TEXT NOT NULL,

        PRIMARY KEY (
          usuario_id,
          publicacion_id
        ),

        FOREIGN KEY (usuario_id)
          REFERENCES usuarios(id)
          ON DELETE CASCADE,

        FOREIGN KEY (publicacion_id)
          REFERENCES publicaciones(id)
          ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_favoritos_usuario
      ON favoritos(usuario_id, fecha_creacion)
    ''');

    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_favoritos_publicacion
      ON favoritos(publicacion_id)
    ''');
  }

  Future<void> cerrar() async {
    final db = await database;

    await db.close();

    _database = null;
  }
}
