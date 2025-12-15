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

  Future<String?> _selectDate(BuildContext context, String? initialDate) async {
    DateTime? selectedDate;
    if (initialDate != null && initialDate.isNotEmpty) {
      selectedDate = DateTime.tryParse(initialDate);
    }
    selectedDate ??= DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(1980),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      return '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
    }
    return null;
  }

  Future<void> _openForm({Game? game}) async {
    final nameController = TextEditingController(text: game?.name ?? '');
    final descriptionController = TextEditingController(text: game?.description ?? '');
    final releaseDateController = TextEditingController(text: game?.releaseDate ?? '');
    final formKey = GlobalKey<FormState>();

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
              backgroundColor: Colors.grey.shade900,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Row(
                children: [
                  Icon(
                    game == null ? Icons.add_circle : Icons.edit,
                    color: Colors.blue.shade700,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    game == null ? 'Criar Game' : 'Editar Game',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: nameController,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Nome',
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
                            borderSide: BorderSide(color: Colors.blue.shade700, width: 2),
                          ),
                          prefixIcon: Icon(Icons.videogame_asset, color: Colors.blue.shade700),
                        ),
                        validator: (value) => (value == null || value.isEmpty) ? 'Preencha o nome' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: descriptionController,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Descrição',
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
                            borderSide: BorderSide(color: Colors.blue.shade700, width: 2),
                          ),
                          prefixIcon: Icon(Icons.description, color: Colors.blue.shade700),
                        ),
                        maxLines: 3,
                        validator: (value) => (value == null || value.isEmpty) ? 'Preencha a descrição' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: releaseDateController,
                        readOnly: true,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Data de Lançamento',
                          labelStyle: TextStyle(color: Colors.white70),
                          hintText: 'YYYY-MM-DD',
                          hintStyle: TextStyle(color: Colors.white30),
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
                            borderSide: BorderSide(color: Colors.blue.shade700, width: 2),
                          ),
                          prefixIcon: Icon(Icons.calendar_today, color: Colors.blue.shade700),
                          suffixIcon: IconButton(
                            icon: Icon(Icons.calendar_month, color: Colors.white70),
                            onPressed: () async {
                              final date = await _selectDate(context, releaseDateController.text);
                              if (date != null) {
                                releaseDateController.text = date;
                              }
                            },
                          ),
                        ),
                        onTap: () async {
                          final date = await _selectDate(context, releaseDateController.text);
                          if (date != null) {
                            releaseDateController.text = date;
                          }
                        },
                        validator: (value) => (value == null || value.isEmpty) ? 'Preencha a data' : null,
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Icon(Icons.style, size: 20, color: Colors.orange.shade600),
                          const SizedBox(width: 8),
                          Text(
                            'Gêneros:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        constraints: BoxConstraints(maxHeight: 200),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3),
                          border: Border.all(color: Colors.white30),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: _genres.isEmpty
                            ? Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Center(
                                  child: Text(
                                    'Nenhum gênero cadastrado.',
                                    style: TextStyle(color: Colors.white60),
                                  ),
                                ),
                              )
                            : ListView(
                                shrinkWrap: true,
                                children: _genres.map((genre) {
                                  final isSelected = selectedGenreIds.contains(genre.id);
                                  return Container(
                                    margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: isSelected 
                                          ? Colors.blue.shade700.withOpacity(0.3)
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: isSelected 
                                            ? Colors.blue.shade700 
                                            : Colors.white10,
                                        width: isSelected ? 2 : 1,
                                      ),
                                    ),
                                    child: CheckboxListTile(
                                      title: Text(
                                        genre.name ?? 'Sem nome',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                        ),
                                      ),
                                      value: isSelected,
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
                                      activeColor: Colors.blue.shade700,
                                      checkColor: Colors.white,
                                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                                    ),
                                  );
                                }).toList(),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text('Cancelar', style: TextStyle(color: Colors.white70)),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
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
      },
    );

    if (saved != true) return;

    final newGame = Game(
      id: game?.id,
      userId: 1,
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
      await _gameGenreController.deleteByGameId(gameId);
    }

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

  Future<List<String>> _getGameGenres(int gameId) async {
    final gameGenres = await _gameGenreController.getByGameId(gameId);
    if (gameGenres.isEmpty) return [];
    
    final genreNames = gameGenres
        .map((gg) {
          final genre = _genres.firstWhere(
            (g) => g.id == gg.genreId,
            orElse: () => Genre(id: null, name: null),
          );
          return genre.name ?? 'Desconhecido';
        })
        .toList();
    
    return genreNames;
  }

  Widget _buildGameCard(Game game) {
    return FutureBuilder<List<String>>(
      future: _getGameGenres(game.id!),
      builder: (context, snapshot) {
        final genres = snapshot.data ?? [];
        
        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _openForm(game: game),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.blue.shade700, Colors.blue.shade900],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.videogame_asset,
                          color: Colors.white,
                          size: 32,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            game.name ?? 'Sem nome',
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
                                  'Excluir Game',
                                  style: TextStyle(color: Colors.white),
                                ),
                                content: Text(
                                  'Deseja realmente excluir "${game.name}"?',
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
                              _deleteGame(game.id!);
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      game.description ?? 'Sem descrição',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                        height: 1.4,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(Icons.calendar_today, color: Colors.white70, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          game.releaseDate ?? 'Sem data',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        const SizedBox(width: 16),
                        Icon(Icons.style, color: Colors.white70, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            genres.isEmpty ? 'Sem gêneros' : genres.join(', '),
                            style: TextStyle(color: Colors.white70, fontSize: 14),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
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
                            'Games',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Gerenciar biblioteca de jogos',
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
              
              Expanded(
                child: _isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                          color: Colors.amber.shade600,
                        ),
                      )
                    : _games.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.videogame_asset_outlined,
                                  size: 80,
                                  color: Colors.white30,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Nenhum game cadastrado',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white70,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextButton.icon(
                                  onPressed: () => _openForm(),
                                  icon: Icon(Icons.add),
                                  label: Text('Adicionar primeiro game'),
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.amber.shade600,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadData,
                            color: Colors.amber.shade600,
                            child: ListView.separated(
                              padding: const EdgeInsets.all(24),
                              itemCount: _games.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 16),
                              itemBuilder: (context, index) {
                                return _buildGameCard(_games[index]);
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
