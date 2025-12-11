import '../database/database_helper.dart';
import '../models/game.dart';

class GameController {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<int> insert(Game game) async {
    final db = await _dbHelper.database;
    return await db.insert('game', game.toMap());
  }

  Future<List<Game>> getAll() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('game');
    return List.generate(maps.length, (i) => Game.fromMap(maps[i]));
  }

  Future<Game?> getById(int id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'game',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return Game.fromMap(maps.first);
  }

  Future<int> update(Game game) async {
    final db = await _dbHelper.database;
    return await db.update(
      'game',
      game.toMap(),
      where: 'id = ?',
      whereArgs: [game.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'game',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
