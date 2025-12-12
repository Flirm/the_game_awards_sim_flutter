import '../database/database_helper.dart';
import '../models/user_vote.dart';

class UserVoteController {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<int> insert(UserVote userVote) async {
    final db = await _dbHelper.database;
    return await db.insert('user_vote', userVote.toMap());
  }

  Future<List<UserVote>> getAll() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('user_vote');
    return List.generate(maps.length, (i) => UserVote.fromMap(maps[i]));
  }

  Future<UserVote?> getById(int id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'user_vote',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return UserVote.fromMap(maps.first);
  }

  Future<List<UserVote>> getByUserId(int userId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'user_vote',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    return List.generate(maps.length, (i) => UserVote.fromMap(maps[i]));
  }

  Future<List<UserVote>> getByCategoryId(int categoryId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'user_vote',
      where: 'category_id = ?',
      whereArgs: [categoryId],
    );
    return List.generate(maps.length, (i) => UserVote.fromMap(maps[i]));
  }

  Future<List<UserVote>> getByVoteGameId(int voteGameId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'user_vote',
      where: 'vote_game_id = ?',
      whereArgs: [voteGameId],
    );
    return List.generate(maps.length, (i) => UserVote.fromMap(maps[i]));
  }

  Future<int> update(UserVote userVote) async {
    final db = await _dbHelper.database;
    return await db.update(
      'user_vote',
      userVote.toMap(),
      where: 'id = ?',
      whereArgs: [userVote.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'user_vote',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<UserVote?> getUserVote(int userId, int categoryId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'user_vote',
      where: 'user_id = ? AND category_id = ?',
      whereArgs: [userId, categoryId],
    );
    if (maps.isEmpty) return null;
    return UserVote.fromMap(maps.first);
  }

  Future<Map<int, int>> getVoteCountsByCategory(int categoryId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT vote_game_id, COUNT(*) as count
      FROM user_vote
      WHERE category_id = ?
      GROUP BY vote_game_id
    ''', [categoryId]);

    Map<int, int> voteCounts = {};
    for (var row in result) {
      voteCounts[row['vote_game_id'] as int] = row['count'] as int;
    }
    return voteCounts;
  }

  Future<int> deleteByUserAndCategory(int userId, int categoryId) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'user_vote',
      where: 'user_id = ? AND category_id = ?',
      whereArgs: [userId, categoryId],
    );
  }
}
