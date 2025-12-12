import 'package:flutter/material.dart';
import '../controllers/game_controller.dart';
import '../controllers/user_vote_controller.dart';
import '../models/user.dart';
import '../models/category.dart';
import '../models/game.dart';
import '../models/user_vote.dart';

class CategoryGamesScreen extends StatefulWidget {
  final Category category;
  final User? user;

  const CategoryGamesScreen({
    super.key,
    required this.category,
    this.user,
  });

  @override
  State<CategoryGamesScreen> createState() => _CategoryGamesScreenState();
}

class _CategoryGamesScreenState extends State<CategoryGamesScreen> {
  final _gameController = GameController();
  final _voteController = UserVoteController();
  List<Game> _games = [];
  Map<int, int> _voteCounts = {};
  UserVote? _userVote;
  bool _isLoading = true;
  int? _selectedGameId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      List<Game> games = await _gameController.getByCategoryId(widget.category.id!);
      Map<int, int> voteCounts = await _voteController.getVoteCountsByCategory(widget.category.id!);
      
      UserVote? userVote;
      if (widget.user != null) {
        userVote = await _voteController.getUserVote(widget.user!.id!, widget.category.id!);
      }

      setState(() {
        _games = games;
        _voteCounts = voteCounts;
        _userVote = userVote;
        _selectedGameId = userVote?.voteGameId;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao carregar dados: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _vote(int gameId) async {
    if (widget.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Você precisa estar logado para votar'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (_userVote == null) {
        // Criar novo voto
        UserVote newVote = UserVote(
          null,
          widget.user!.id,
          widget.category.id,
          gameId,
        );
        await _voteController.insert(newVote);
        
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Voto registrado com sucesso!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        // Atualizar voto existente
        _userVote!.voteGameId = gameId;
        await _voteController.update(_userVote!);
        
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Voto atualizado com sucesso!'),
            backgroundColor: Colors.blue,
            duration: Duration(seconds: 2),
          ),
        );
      }

      // Recarregar dados
      await _loadData();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao votar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _removeVote() async {
    if (widget.user == null || _userVote == null) {
      return;
    }

    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey.shade900,
        title: const Text(
          'Remover voto',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Tem certeza que deseja remover seu voto?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remover'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _voteController.delete(_userVote!.id!);
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Voto removido com sucesso!'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );

      await _loadData();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao remover voto: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  int _getTotalVotes() {
    return _voteCounts.values.fold(0, (sum, count) => sum + count);
  }

  double _getVotePercentage(int gameId) {
    int totalVotes = _getTotalVotes();
    if (totalVotes == 0) return 0.0;
    int gameVotes = _voteCounts[gameId] ?? 0;
    return (gameVotes / totalVotes) * 100;
  }

  List<MapEntry<int, int>> _getSortedGames() {
    // Ordenar jogos por número de votos (ranking)
    return _voteCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
  }

  int _getGamePosition(int gameId) {
    List<MapEntry<int, int>> sortedGames = _getSortedGames();
    int position = sortedGames.indexWhere((entry) => entry.key == gameId);
    return position >= 0 ? position + 1 : 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category.title ?? 'Categoria'),
        backgroundColor: Colors.purple.shade900,
        foregroundColor: Colors.white,
        actions: [
          if (_userVote != null)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Remover voto',
              onPressed: _removeVote,
            ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.purple.shade900.withOpacity(0.3),
              Colors.black,
            ],
          ),
        ),
        child: Column(
          children: [
            // Header da categoria
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                border: Border(
                  bottom: BorderSide(color: Colors.white.withOpacity(0.1)),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.emoji_events,
                        color: Colors.amber.shade400,
                        size: 32,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.category.title ?? '',
                              style: const TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                              ),
                            ),
                            if (widget.category.description != null &&
                                widget.category.description!.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                widget.category.description!,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: Colors.amber.shade400,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Data: ${widget.category.date}',
                        style: TextStyle(
                          color: Colors.amber.shade400,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.how_to_vote,
                        size: 16,
                        color: Colors.amber.shade400,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Total de votos: ${_getTotalVotes()}',
                        style: TextStyle(
                          color: Colors.amber.shade400,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  if (widget.user == null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.orange, size: 20),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Faça login para votar',
                              style: TextStyle(color: Colors.orange, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Lista de jogos
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.amber),
                    )
                  : _games.isEmpty
                      ? const Center(
                          child: Text(
                            'Nenhum jogo cadastrado nesta categoria',
                            style: TextStyle(color: Colors.white70, fontSize: 16),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _games.length,
                          itemBuilder: (context, index) {
                            Game game = _games[index];
                            int gameVotes = _voteCounts[game.id] ?? 0;
                            double percentage = _getVotePercentage(game.id!);
                            bool isUserVote = _selectedGameId == game.id;
                            int position = _getGamePosition(game.id!);

                            return Card(
                              color: isUserVote
                                  ? Colors.amber.shade600.withOpacity(0.2)
                                  : Colors.white.withOpacity(0.1),
                              margin: const EdgeInsets.only(bottom: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color: isUserVote
                                      ? Colors.amber.shade600
                                      : Colors.white.withOpacity(0.2),
                                  width: isUserVote ? 2 : 1,
                                ),
                              ),
                              child: InkWell(
                                onTap: () => _vote(game.id!),
                                borderRadius: BorderRadius.circular(12),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          // Posição
                                          if (position > 0 && position <= 3)
                                            Container(
                                              width: 32,
                                              height: 32,
                                              decoration: BoxDecoration(
                                                color: position == 1
                                                    ? Colors.amber
                                                    : position == 2
                                                        ? Colors.grey.shade400
                                                        : Colors.brown.shade400,
                                                shape: BoxShape.circle,
                                              ),
                                              child: Center(
                                                child: Text(
                                                  '$position°',
                                                  style: const TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          if (position > 0 && position <= 3)
                                            const SizedBox(width: 12),

                                          // Ícone do jogo
                                          CircleAvatar(
                                            backgroundColor: Colors.purple.shade700,
                                            child: const Icon(
                                              Icons.videogame_asset,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(width: 12),

                                          // Nome do jogo
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  game.name ?? '',
                                                  style: const TextStyle(
                                                    fontSize: 18,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                Text(
                                                  'Lançamento: ${game.releaseDate}',
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.white60,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),

                                          // Indicador de voto do usuário
                                          if (isUserVote)
                                            Icon(
                                              Icons.check_circle,
                                              color: Colors.amber.shade400,
                                              size: 28,
                                            ),
                                        ],
                                      ),

                                      // Descrição
                                      if (game.description != null &&
                                          game.description!.isNotEmpty) ...[
                                        const SizedBox(height: 12),
                                        Text(
                                          game.description!,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.white70,
                                          ),
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],

                                      const SizedBox(height: 12),

                                      // Barra de progresso de votos
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                '$gameVotes votos',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.amber.shade400,
                                                ),
                                              ),
                                              Text(
                                                '${percentage.toStringAsFixed(1)}%',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.amber.shade400,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(4),
                                            child: LinearProgressIndicator(
                                              value: percentage / 100,
                                              backgroundColor: Colors.white.withOpacity(0.1),
                                              
                                              minHeight: 8,
                                            ),
                                          ),
                                        ],
                                      ),

                                      // Botão de voto
                                      if (widget.user != null) ...[
                                        const SizedBox(height: 12),
                                        SizedBox(
                                          width: double.infinity,
                                          child: ElevatedButton.icon(
                                            onPressed: () => _vote(game.id!),
                                            icon: Icon(
                                              isUserVote ? Icons.check : Icons.how_to_vote,
                                            ),
                                            label: Text(
                                              isUserVote ? 'Seu voto' : 'Votar',
                                            ),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: isUserVote
                                                  ? Colors.amber.shade600
                                                  : Colors.purple.shade700,
                                              foregroundColor:
                                                  isUserVote ? Colors.black : Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
