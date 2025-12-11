import 'package:flutter/material.dart';
import '../controllers/genre_controller.dart';
import '../models/genre.dart';

class TelaAdminGenres extends StatefulWidget {
  const TelaAdminGenres({super.key});

  @override
  State<TelaAdminGenres> createState() => _TelaAdminGenresState();
}

class _TelaAdminGenresState extends State<TelaAdminGenres> {
  final GenreController _controller = GenreController();
  List<Genre> _genres = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGenres();
  }

  Future<void> _loadGenres() async {
    setState(() => _isLoading = true);
    final genres = await _controller.getAll();
    setState(() {
      _genres = genres;
      _isLoading = false;
    });
  }

  Future<void> _openForm({Genre? genre}) async {
    final nameController = TextEditingController(text: genre?.name ?? '');
    final formKey = GlobalKey<FormState>();

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(genre == null ? 'Criar Gênero' : 'Editar Gênero'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nome'),
              validator: (value) => (value == null || value.isEmpty) ? 'Preencha o nome' : null,
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

    final newGenre = Genre(
      id: genre?.id,
      name: nameController.text,
    );

    if (genre == null) {
      await _controller.insert(newGenre);
    } else {
      await _controller.update(newGenre);
    }

    _loadGenres();
  }

  Future<void> _deleteGenre(int id) async {
    await _controller.delete(id);
    _loadGenres();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gêneros'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(),
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _genres.isEmpty
              ? const Center(child: Text('Nenhum gênero cadastrado.'))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _genres.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final genre = _genres[index];
                    return Dismissible(
                      key: Key('genre_${genre.id}'),
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
                          await _openForm(genre: genre);
                          return false;
                        }
                        if (direction == DismissDirection.endToStart) {
                          _deleteGenre(genre.id!);
                          return true;
                        }
                        return false;
                      },
                      child: ListTile(
                        tileColor: Colors.grey.shade100,
                        title: Text(genre.name ?? 'Sem nome'),
                      ),
                    );
                  },
                ),
    );
  }
}
