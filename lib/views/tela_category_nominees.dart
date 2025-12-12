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
              backgroundColor: Colors.grey.shade900,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Row(
                children: [
                  Icon(
                    nominee == null ? Icons.add_circle : Icons.edit,
                    color: Colors.amber.shade600,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    nominee == null ? 'Adicionar Indicado' : 'Editar Indicado',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
              content: Form(
                key: formKey,
                child: DropdownButtonFormField<int>(
                  value: selectedGameId,
                  dropdownColor: Colors.grey.shade800,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Game',
                    labelStyle: TextStyle(color: Colors.white70),
                    prefixIcon: Icon(Icons.videogame_asset, color: Colors.amber.shade600),
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
                      borderSide: BorderSide(color: Colors.amber.shade600, width: 2),
                    ),
                  ),
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
                  child: Text('Cancelar', style: TextStyle(color: Colors.white70)),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.amber.shade600,
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

  Widget _buildNomineeCard(CategoryGame nominee, int position) {
    final gameName = _getGameName(nominee.gameId);
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _openForm(nominee: nominee),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: position < 3
                  ? [Colors.amber.shade600, Colors.amber.shade800]
                  : [Colors.blue.shade700, Colors.blue.shade900],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Center(
                    child: Text(
                      '${position + 1}',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.videogame_asset,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              gameName,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (position < 3) ...[
                        const SizedBox(height: 4),
                        Text(
                          position == 0 ? '🏆 Destaque' : position == 1 ? '🥈 Indicado' : '🥉 Indicado',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ],
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
                          'Excluir Indicado',
                          style: TextStyle(color: Colors.white),
                        ),
                        content: Text(
                          'Deseja realmente excluir "$gameName" desta categoria?',
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
                      _deleteNominee(nominee.id!);
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
                            widget.category.title ?? 'Indicados',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Gerenciar indicados da categoria',
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
                    : _nominees.isEmpty
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
                                  'Nenhum game indicado',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white70,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextButton.icon(
                                  onPressed: () => _openForm(),
                                  icon: Icon(Icons.add),
                                  label: Text('Adicionar primeiro indicado'),
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
                              itemCount: _nominees.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 16),
                              itemBuilder: (context, index) {
                                return _buildNomineeCard(_nominees[index], index);
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
