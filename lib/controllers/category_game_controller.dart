import '../database/database_helper.dart';
import '../models/category_game.dart';

class CategoryGameController {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<int> insert(CategoryGame categoryGame) async {
    final db = await _dbHelper.database;
    return await db.insert('category_game', categoryGame.toMap());
  }

  Future<List<CategoryGame>> getAll() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('category_game');
    return List.generate(maps.length, (i) => CategoryGame.fromMap(maps[i]));
  }

  Future<CategoryGame?> getById(int id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'category_game',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return CategoryGame.fromMap(maps.first);
  }

  Future<List<CategoryGame>> getByCategoryId(int categoryId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'category_game',
      where: 'category_id = ?',
      whereArgs: [categoryId],
    );
    return List.generate(maps.length, (i) => CategoryGame.fromMap(maps[i]));
  }

  Future<List<CategoryGame>> getByGameId(int gameId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'category_game',
      where: 'game_id = ?',
      whereArgs: [gameId],
    );
    return List.generate(maps.length, (i) => CategoryGame.fromMap(maps[i]));
  }

  Future<int> update(CategoryGame categoryGame) async {
    final db = await _dbHelper.database;
    return await db.update(
      'category_game',
      categoryGame.toMap(),
      where: 'id = ?',
      whereArgs: [categoryGame.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'category_game',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
