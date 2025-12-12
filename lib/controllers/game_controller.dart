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

  Future<List<Game>> getByCategoryId(int categoryId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT g.* FROM game g
      INNER JOIN category_game cg ON g.id = cg.game_id
      WHERE cg.category_id = ?
    ''', [categoryId]);
    return List.generate(maps.length, (i) => Game.fromMap(maps[i]));
  }

  Future<List<Game>> search({int? categoryId, int? genreId, int? position}) async {
    final db = await _dbHelper.database;
    String query = 'SELECT DISTINCT g.* FROM game g ';
    List<String> joins = [];
    List<String> conditions = [];
    List<dynamic> args = [];

    if (categoryId != null) {
      joins.add('INNER JOIN category_game cg ON g.id = cg.game_id');
      conditions.add('cg.category_id = ?');
      args.add(categoryId);
      if (position != null) {
        conditions.add('cg.id = ?');
        args.add(position);
      }
    }

    if (genreId != null) {
      joins.add('INNER JOIN game_genre gg ON g.id = gg.game_id');
      conditions.add('gg.genre_id = ?');
      args.add(genreId);
    }

    if (joins.isNotEmpty) {
      query += joins.join(' ');
    }
    if (conditions.isNotEmpty) {
      query += ' WHERE ' + conditions.join(' AND ');
    }

    final List<Map<String, dynamic>> maps = await db.rawQuery(query, args);
    return List.generate(maps.length, (i) => Game.fromMap(maps[i]));
  }
}
