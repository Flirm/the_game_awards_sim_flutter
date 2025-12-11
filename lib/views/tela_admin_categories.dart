import 'package:flutter/material.dart';
import '../controllers/category_controller.dart';
import '../models/category.dart';

class TelaAdminCategories extends StatefulWidget {
  const TelaAdminCategories({super.key});

  @override
  State<TelaAdminCategories> createState() => _TelaAdminCategoriesState();
}

class _TelaAdminCategoriesState extends State<TelaAdminCategories> {
  final CategoryController _controller = CategoryController();
  List<Category> _categories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() => _isLoading = true);
    final categories = await _controller.getAll();
    setState(() {
      _categories = categories;
      _isLoading = false;
    });
  }

  Future<void> _openForm({Category? category}) async {
    final titleController = TextEditingController(text: category?.title ?? '');
    final descriptionController = TextEditingController(text: category?.description ?? '');
    final dateController = TextEditingController(text: category?.date ?? '');
    final formKey = GlobalKey<FormState>();

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(category == null ? 'Criar Categoria' : 'Editar Categoria'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: 'Título'),
                    validator: (value) => (value == null || value.isEmpty) ? 'Preencha o título' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: descriptionController,
                    decoration: const InputDecoration(labelText: 'Descrição'),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: dateController,
                    decoration: const InputDecoration(labelText: 'Data'),
                    validator: (value) => (value == null || value.isEmpty) ? 'Preencha a data' : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                if (formKey.currentState?.validate() ?? false) {
                  Navigator.of(context).pop(true);
                }
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );

    if (saved != true) return;

    final newCategory = Category(
      category?.id,
      1, // TODO: pegar usuário logado
      titleController.text,
      descriptionController.text,
      dateController.text,
    );

    if (category == null) {
      await _controller.insert(newCategory);
    } else {
      await _controller.update(newCategory);
    }

    _loadCategories();
  }

  Future<void> _deleteCategory(int id) async {
    await _controller.delete(id);
    _loadCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categorias'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(),
        child: const Icon(Icons.add),
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
                    return Dismissible(
                      key: Key('category_${category.id}'),
                      background: Container(
                        color: Colors.blue.shade100,
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: const Icon(Icons.edit, color: Colors.blue),
                      ),
                      secondaryBackground: Container(
                        color: Colors.red.shade100,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: const Icon(Icons.delete, color: Colors.red),
                      ),
                      confirmDismiss: (direction) async {
                        if (direction == DismissDirection.startToEnd) {
                          await _openForm(category: category);
                          return false;
                        }
                        if (direction == DismissDirection.endToStart) {
                          _deleteCategory(category.id!);
                          return true;
                        }
                        return false;
                      },
                      child: ListTile(
                        tileColor: Colors.grey.shade100,
                        title: Text(category.title ?? 'Sem título'),
                        subtitle: Text(category.description ?? ''),
                        trailing: Text(category.date ?? ''),
                      ),
                    );
                  },
                ),
    );
  }
}
