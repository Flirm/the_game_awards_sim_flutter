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
      version: 1,
      onCreate: _onCreate,
    );
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
        date VARCHAR NOT NULL,
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
