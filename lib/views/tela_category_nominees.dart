import 'package:flutter/material.dart';
import '../controllers/category_game_controller.dart';
import '../controllers/game_controller.dart';
import '../models/category.dart';
import '../models/category_game.dart';
import '../models/game.dart';

class TelaCategoryNominees extends StatefulWidget {
  final Category category;

  const TelaCategoryNominees({super.key, required this.category});

  @override
  State<TelaCategoryNominees> createState() => _TelaCategoryNomineesState();
}

class _TelaCategoryNomineesState extends State<TelaCategoryNominees> {
  final CategoryGameController _controller = CategoryGameController();
  final GameController _gameController = GameController();
  
  List<CategoryGame> _nominees = [];
  List<Game> _games = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final nominees = await _controller.getByCategoryId(widget.category.id!);
    final games = await _gameController.getAll();
    setState(() {
      _nominees = nominees;
      _games = games;
      _isLoading = false;
    });
  }

  Future<void> _openForm({CategoryGame? nominee}) async {
    int? selectedGameId = nominee?.gameId;
    final formKey = GlobalKey<FormState>();

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(nominee == null ? 'Adicionar Indicado' : 'Editar Indicado'),
              content: Form(
                key: formKey,
                child: DropdownButtonFormField<int>(
                  value: selectedGameId,
                  decoration: const InputDecoration(labelText: 'Game'),
                  items: _games.map((game) {
                    return DropdownMenuItem(
                      value: game.id,
                      child: Text(game.name ?? 'Sem nome'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setDialogState(() => selectedGameId = value);
                  },
                  validator: (value) => value == null ? 'Selecione um game' : null,
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

    final newNominee = CategoryGame(
      nominee?.id,
      widget.category.id,
      selectedGameId,
    );

    if (nominee == null) {
      await _controller.insert(newNominee);
    } else {
      await _controller.update(newNominee);
    }

    _loadData();
  }

  Future<void> _deleteNominee(int id) async {
    await _controller.delete(id);
    _loadData();
  }

  String _getGameName(int? gameId) {
    if (gameId == null) return 'Game desconhecido';
    final game = _games.firstWhere((g) => g.id == gameId, orElse: () => Game());
    return game.name ?? 'Game desconhecido';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category.title ?? 'Indicados'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(),
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _nominees.isEmpty
              ? const Center(child: Text('Nenhum game indicado nesta categoria.'))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _nominees.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final nominee = _nominees[index];
                    return Dismissible(
                      key: Key('nominee_${nominee.id}'),
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
                          await _openForm(nominee: nominee);
                          return false;
                        }
                        if (direction == DismissDirection.endToStart) {
                          _deleteNominee(nominee.id!);
                          return true;
                        }
                        return false;
                      },
                      child: ListTile(
                        tileColor: Colors.grey.shade100,
                        leading: const Icon(Icons.videogame_asset),
                        title: Text(_getGameName(nominee.gameId)),
                      ),
                    );
                  },
                ),
    );
  }
}
