import 'package:flutter/material.dart';
import '../controllers/game_controller.dart';
import '../controllers/genre_controller.dart';
import '../controllers/game_genre_controller.dart';
import '../models/game.dart';
import '../models/genre.dart';
import '../models/game_genre.dart';

class TelaAdminGames extends StatefulWidget {
  const TelaAdminGames({super.key});

  @override
  State<TelaAdminGames> createState() => _TelaAdminGamesState();
}

class _TelaAdminGamesState extends State<TelaAdminGames> {
  final GameController _controller = GameController();
  final GenreController _genreController = GenreController();
  final GameGenreController _gameGenreController = GameGenreController();
  List<Game> _games = [];
  List<Genre> _genres = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final games = await _controller.getAll();
    final genres = await _genreController.getAll();
    setState(() {
      _games = games;
      _genres = genres;
      _isLoading = false;
    });
  }

  Future<void> _openForm({Game? game}) async {
    final nameController = TextEditingController(text: game?.name ?? '');
    final descriptionController = TextEditingController(text: game?.description ?? '');
    final releaseDateController = TextEditingController(text: game?.releaseDate ?? '');
    final formKey = GlobalKey<FormState>();

    // Carregar gêneros já vinculados ao game (se estiver editando)
    Set<int> selectedGenreIds = {};
    if (game?.id != null) {
      final gameGenres = await _gameGenreController.getByGameId(game!.id!);
      selectedGenreIds = gameGenres.map((gg) => gg.genreId!).toSet();
    }

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(game == null ? 'Criar Game' : 'Editar Game'),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(labelText: 'Nome'),
                        validator: (value) => (value == null || value.isEmpty) ? 'Preencha o nome' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: descriptionController,
                        decoration: const InputDecoration(labelText: 'Descrição'),
                        maxLines: 3,
                        validator: (value) => (value == null || value.isEmpty) ? 'Preencha a descrição' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: releaseDateController,
                        decoration: const InputDecoration(labelText: 'Data de Lançamento'),
                        validator: (value) => (value == null || value.isEmpty) ? 'Preencha a data' : null,
                      ),
                      const SizedBox(height: 20),
                      const Text('Gêneros:', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      if (_genres.isEmpty)
                        const Text('Nenhum gênero cadastrado.')
                      else
                        ..._genres.map((genre) {
                          return CheckboxListTile(
                            title: Text(genre.name ?? 'Sem nome'),
                            value: selectedGenreIds.contains(genre.id),
                            onChanged: (checked) {
                              setDialogState(() {
                                if (checked == true) {
                                  selectedGenreIds.add(genre.id!);
                                } else {
                                  selectedGenreIds.remove(genre.id);
                                }
                              });
                            },
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                          );
                        }).toList(),
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
      },
    );

    if (saved != true) return;

    final newGame = Game(
      id: game?.id,
      userId: 1, // TODO: pegar usuário logado
      name: nameController.text,
      description: descriptionController.text,
      releaseDate: releaseDateController.text,
    );

    int gameId;
    if (game == null) {
      gameId = await _controller.insert(newGame);
    } else {
      await _controller.update(newGame);
      gameId = game.id!;
      // Remover vínculos antigos
      await _gameGenreController.deleteByGameId(gameId);
    }

    // Criar novos vínculos game-genre
    for (final genreId in selectedGenreIds) {
      await _gameGenreController.insert(GameGenre(gameId, genreId));
    }

    _loadData();
    _loadData();
  }

  Future<void> _deleteGame(int id) async {
    await _gameGenreController.deleteByGameId(id);
    await _controller.delete(id);
    _loadData();
  }

  Future<String> _getGameGenres(int gameId) async {
    final gameGenres = await _gameGenreController.getByGameId(gameId);
    if (gameGenres.isEmpty) return 'Sem gêneros';
    
    final genreNames = gameGenres
        .map((gg) {
          final genre = _genres.firstWhere(
            (g) => g.id == gg.genreId,
            orElse: () => Genre(id: null, name: null),
          );
          return genre.name ?? 'Desconhecido';
        })
        .toList();
    
    return genreNames.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Games'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(),
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _games.isEmpty
              ? const Center(child: Text('Nenhum game cadastrado.'))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _games.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final game = _games[index];
                    return FutureBuilder<String>(
                      future: _getGameGenres(game.id!),
                      builder: (context, snapshot) {
                        final genres = snapshot.data ?? 'Carregando...';
                        return Dismissible(
                          key: Key('game_${game.id}'),
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
                              await _openForm(game: game);
                              return false;
                            }
                            if (direction == DismissDirection.endToStart) {
                              _deleteGame(game.id!);
                              return true;
                            }
                            return false;
                          },
                          child: ListTile(
                            tileColor: Colors.grey.shade100,
                            title: Text(game.name ?? 'Sem nome'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(game.description ?? ''),
                                const SizedBox(height: 4),
                                Text(
                                  'Gêneros: $genres',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade700,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                            trailing: Text(game.releaseDate ?? ''),
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }
}
