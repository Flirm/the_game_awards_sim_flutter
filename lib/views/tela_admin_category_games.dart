import 'package:flutter/material.dart';
import '../controllers/category_controller.dart';
import '../models/category.dart';
import 'tela_category_nominees.dart';

class TelaAdminCategoryGames extends StatefulWidget {
  const TelaAdminCategoryGames({super.key});

  @override
  State<TelaAdminCategoryGames> createState() => _TelaAdminCategoryGamesState();
}

class _TelaAdminCategoryGamesState extends State<TelaAdminCategoryGames> {
  final CategoryController _categoryController = CategoryController();
  List<Category> _categories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final categories = await _categoryController.getAll();
    setState(() {
      _categories = categories;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Premiações - Categorias'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _categories.isEmpty
              ? const Center(child: Text('Nenhuma categoria cadastrada.'))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _categories.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    return Card(
                      child: ListTile(
                        tileColor: Colors.grey.shade100,
                        title: Text(category.title ?? 'Sem título'),
                        subtitle: Text(category.description ?? ''),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => TelaCategoryNominees(category: category),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}