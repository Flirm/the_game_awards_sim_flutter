import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'the_game_awards.db');

    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Migração da versão 1 para 2: adicionar start_date e end_date
      await db.execute('''
        CREATE TABLE category_new(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER NOT NULL,
          title VARCHAR NOT NULL,
          description TEXT,  
          start_date VARCHAR NOT NULL,
          end_date VARCHAR NOT NULL,
          FOREIGN KEY(user_id) REFERENCES user(id)
        )
      ''');
      
      // Copiar dados existentes, usando date como start_date e end_date
      await db.execute('''
        INSERT INTO category_new (id, user_id, title, description, start_date, end_date)
        SELECT id, user_id, title, description, date, date
        FROM category
      ''');
      
      await db.execute('DROP TABLE category');
      await db.execute('ALTER TABLE category_new RENAME TO category');
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE user(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name VARCHAR NOT NULL,
        email VARCHAR NOT NULL,
        password VARCHAR NOT NULL,
        role INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE genre(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name VARCHAR NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE game(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        name VARCHAR NOT NULL UNIQUE,
        description TEXT NOT NULL,
        release_date VARCHAR NOT NULL,
        FOREIGN KEY(user_id) REFERENCES user(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE game_genre(
        game_id INTEGER NOT NULL,
        genre_id INTEGER NOT NULL,
        FOREIGN KEY(game_id) REFERENCES game(id),
        FOREIGN KEY(genre_id) REFERENCES genre(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE category(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        title VARCHAR NOT NULL,
        description TEXT,  
        start_date VARCHAR NOT NULL,
        end_date VARCHAR NOT NULL,
        FOREIGN KEY(user_id) REFERENCES user(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE category_game(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category_id INTEGER NOT NULL,
        game_id INTEGER NOT NULL,
        FOREIGN KEY(category_id) REFERENCES category(id),
        FOREIGN KEY(game_id) REFERENCES game(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE user_vote(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        category_id INTEGER NOT NULL,
        vote_game_id INTEGER NOT NULL,    
        FOREIGN KEY(user_id) REFERENCES user(id),
        FOREIGN KEY(category_id) REFERENCES category(id),
        FOREIGN KEY(vote_game_id) REFERENCES category_game(game_id)
      )
    ''');
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
