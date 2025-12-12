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
          backgroundColor: Colors.grey.shade900,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(
                genre == null ? Icons.add_circle : Icons.edit,
                color: Colors.orange.shade700,
              ),
              const SizedBox(width: 12),
              Text(
                genre == null ? 'Criar Gênero' : 'Editar Gênero',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: nameController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Nome do Gênero',
                labelStyle: TextStyle(color: Colors.white70),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white30),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white30),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.orange.shade700, width: 2),
                ),
                prefixIcon: Icon(Icons.style, color: Colors.orange.shade700),
              ),
              validator: (value) => (value == null || value.isEmpty) ? 'Preencha o nome' : null,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancelar', style: TextStyle(color: Colors.white70)),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.orange.shade700,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
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

  Widget _buildGenreCard(Genre genre) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _openForm(genre: genre),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.orange.shade700, Colors.orange.shade900],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Icon(
                  Icons.style,
                  color: Colors.white,
                  size: 32,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    genre.name ?? 'Sem nome',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red.shade300),
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: Colors.grey.shade900,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        title: Text(
                          'Excluir Gênero',
                          style: TextStyle(color: Colors.white),
                        ),
                        content: Text(
                          'Deseja realmente excluir "${genre.name}"?',
                          style: TextStyle(color: Colors.white70),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: Text('Cancelar', style: TextStyle(color: Colors.white70)),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: Text('Excluir', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      _deleteGenre(genre.id!);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.purple.shade900,
              Colors.black,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.white, size: 28),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Gêneros',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Gerenciar gêneros de jogos',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                    FloatingActionButton(
                      onPressed: () => _openForm(),
                      backgroundColor: Colors.amber.shade600,
                      child: const Icon(Icons.add, size: 28),
                    ),
                  ],
                ),
              ),
              
              // Content
              Expanded(
                child: _isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                          color: Colors.amber.shade600,
                        ),
                      )
                    : _genres.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.style_outlined,
                                  size: 80,
                                  color: Colors.white30,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Nenhum gênero cadastrado',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white70,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextButton.icon(
                                  onPressed: () => _openForm(),
                                  icon: Icon(Icons.add),
                                  label: Text('Adicionar primeiro gênero'),
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.amber.shade600,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadGenres,
                            color: Colors.amber.shade600,
                            child: ListView.separated(
                              padding: const EdgeInsets.all(24),
                              itemCount: _genres.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 16),
                              itemBuilder: (context, index) {
                                return _buildGenreCard(_genres[index]);
                              },
                            ),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
