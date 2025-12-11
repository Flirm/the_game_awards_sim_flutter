import '../database/database_helper.dart';
import '../models/game_genre.dart';

class GameGenreController {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<int> insert(GameGenre gameGenre) async {
    final db = await _dbHelper.database;
    return await db.insert('game_genre', gameGenre.toMap());
  }

  Future<List<GameGenre>> getAll() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('game_genre');
    return List.generate(maps.length, (i) => GameGenre.fromMap(maps[i]));
  }

  Future<List<GameGenre>> getByGameId(int gameId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'game_genre',
      where: 'game_id = ?',
      whereArgs: [gameId],
    );
    return List.generate(maps.length, (i) => GameGenre.fromMap(maps[i]));
  }

  Future<List<GameGenre>> getByGenreId(int genreId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'game_genre',
      where: 'genre_id = ?',
      whereArgs: [genreId],
    );
    return List.generate(maps.length, (i) => GameGenre.fromMap(maps[i]));
  }

  Future<int> delete(int gameId, int genreId) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'game_genre',
      where: 'game_id = ? AND genre_id = ?',
      whereArgs: [gameId, genreId],
    );
  }

  Future<int> deleteByGameId(int gameId) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'game_genre',
      where: 'game_id = ?',
      whereArgs: [gameId],
    );
  }

  Future<int> deleteByGenreId(int genreId) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'game_genre',
      where: 'genre_id = ?',
      whereArgs: [genreId],
    );
  }
}
