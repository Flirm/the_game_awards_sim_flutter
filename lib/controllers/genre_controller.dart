import '../database/database_helper.dart';
import '../models/genre.dart';

class GenreController {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<int> insert(Genre genre) async {
    final db = await _dbHelper.database;
    return await db.insert('genre', genre.toMap());
  }

  Future<List<Genre>> getAll() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('genre');
    return List.generate(maps.length, (i) => Genre.fromMap(maps[i]));
  }

  Future<Genre?> getById(int id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'genre',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return Genre.fromMap(maps.first);
  }

  Future<int> update(Genre genre) async {
    final db = await _dbHelper.database;
    return await db.update(
      'genre',
      genre.toMap(),
      where: 'id = ?',
      whereArgs: [genre.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'genre',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
