import '../database/database_helper.dart';
import '../models/category.dart';

class CategoryController {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<int> insert(Category category) async {
    final db = await _dbHelper.database;
    return await db.insert('category', category.toMap());
  }

  Future<List<Category>> getAll() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('category');
    return List.generate(maps.length, (i) => Category.fromMap(maps[i]));
  }

  Future<Category?> getById(int id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'category',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return Category.fromMap(maps.first);
  }

  Future<int> update(Category category) async {
    final db = await _dbHelper.database;
    return await db.update(
      'category',
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'category',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
