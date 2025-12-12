import 'package:flutter/material.dart';
import '../controllers/category_controller.dart';
import '../controllers/genre_controller.dart';
import '../controllers/game_controller.dart';
import '../models/user.dart';
import '../models/category.dart';
import '../models/genre.dart';
import '../models/game.dart';

class UserDashboardScreen extends StatefulWidget {
  final User? user; // Pode ser null se o usuário não estiver logado

  const UserDashboardScreen({super.key, this.user});

  @override
  State<UserDashboardScreen> createState() => _UserDashboardScreenState();
}

class _UserDashboardScreenState extends State<UserDashboardScreen> {
  final _categoryController = CategoryController();
  final _genreController = GenreController();
  final _gameController = GameController();
  List<Category> _categories = [];
  List<Genre> _genres = [];
  List<Game> _filteredGames = [];
  
  bool _isLoading = true;
  bool _showActiveOnly = true;
  
  // Filtros
  int? _selectedCategoryId;
  int? _selectedGenreId;
  int? _selectedPosition;

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
      List<Category> categories = _showActiveOnly
          ? await _categoryController.getActive()
          : await _categoryController.getAll();
      List<Genre> genres = await _genreController.getAll();

      setState(() {
        _categories = categories;
        _genres = genres;
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

  Future<void> _searchGames() async {
    setState(() {
      _isLoading = true;
    });

    try {
      List<Game> games = await _gameController.search(
        categoryId: _selectedCategoryId,
        genreId: _selectedGenreId,
        position: _selectedPosition,
      );

      setState(() {
        _filteredGames = games;
        _isLoading = false;
      });

      // Mostrar resultado da busca
      if (!mounted) return;
      if (games.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Nenhum jogo encontrado com os filtros selecionados'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao buscar jogos: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _clearFilters() {
    setState(() {
      _selectedCategoryId = null;
      _selectedGenreId = null;
      _selectedPosition = null;
      _filteredGames = [];
    });
  }

  void _logout() {
    Navigator.pushReplacementNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('The Game Awards'),
        backgroundColor: Colors.purple.shade900,
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.menu),
            onSelected: (value) {
              if (value == 'logout') {
                _logout();
              } else if (value == 'toggle_active') {
                setState(() {
                  _showActiveOnly = !_showActiveOnly;
                });
                _loadData();
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                value: 'toggle_active',
                child: Row(
                  children: [
                    Icon(
                      _showActiveOnly ? Icons.visibility : Icons.visibility_off,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(_showActiveOnly ? 'Mostrar todas' : 'Mostrar ativas'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 20),
                    SizedBox(width: 8),
                    Text('Sair'),
                  ],
                ),
              ),
            ],
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
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.amber))
            : Column(
                children: [
                  // Header com informações do usuário
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
                        if (widget.user != null) ...[
                          Text(
                            'Bem-vindo, ${widget.user!.name}!',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Vote nas suas categorias favoritas',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                        ] else ...[
                          const Text(
                            'Modo visitante',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Faça login para votar',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Filtros
                  Container(
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
                        const Text(
                          'Filtros de Pesquisa',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Dropdown Categoria
                        DropdownButtonFormField<int>(
                          value: _selectedCategoryId,
                          decoration: InputDecoration(
                            labelText: 'Categoria',
                            labelStyle: const TextStyle(color: Colors.white70),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.1),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          dropdownColor: Colors.grey.shade900,
                          style: const TextStyle(color: Colors.white),
                          items: _categories.map((category) {
                            return DropdownMenuItem<int>(
                              value: category.id,
                              child: Text(category.title ?? ''),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedCategoryId = value;
                            });
                          },
                        ),
                        const SizedBox(height: 12),

                        // Dropdown Gênero
                        DropdownButtonFormField<int>(
                          value: _selectedGenreId,
                          decoration: InputDecoration(
                            labelText: 'Gênero',
                            labelStyle: const TextStyle(color: Colors.white70),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.1),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          dropdownColor: Colors.grey.shade900,
                          style: const TextStyle(color: Colors.white),
                          items: _genres.map((genre) {
                            return DropdownMenuItem<int>(
                              value: genre.id,
                              child: Text(genre.name ?? ''),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedGenreId = value;
                            });
                          },
                        ),
                        const SizedBox(height: 12),

                        // Dropdown Posição
                        DropdownButtonFormField<int>(
                          value: _selectedPosition,
                          decoration: InputDecoration(
                            labelText: 'Posição',
                            labelStyle: const TextStyle(color: Colors.white70),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.1),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          dropdownColor: Colors.grey.shade900,
                          style: const TextStyle(color: Colors.white),
                          items: const [
                            DropdownMenuItem(value: 1, child: Text('1º Lugar')),
                            DropdownMenuItem(value: 2, child: Text('2º Lugar')),
                            DropdownMenuItem(value: 3, child: Text('3º Lugar')),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedPosition = value;
                            });
                          },
                        ),
                        const SizedBox(height: 16),

                        // Botões de ação
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _searchGames,
                                icon: const Icon(Icons.search),
                                label: const Text('Buscar'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.amber.shade600,
                                  foregroundColor: Colors.black,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: _clearFilters,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey.shade700,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                              child: const Icon(Icons.clear),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Lista de categorias ou resultados de busca
                  Expanded(
                    child: _filteredGames.isNotEmpty
                        ? _buildGameResults()
                        : _buildCategoryList(),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildCategoryList() {
    if (_categories.isEmpty) {
      return const Center(
        child: Text(
          'Nenhuma categoria disponível',
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _categories.length,
      itemBuilder: (context, index) {
        Category category = _categories[index];
        return Card(
          color: Colors.white.withOpacity(0.1),
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.amber.shade600.withOpacity(0.3)),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              backgroundColor: Colors.amber.shade600,
              child: const Icon(Icons.emoji_events, color: Colors.black),
            ),
            title: Text(
              category.title ?? '',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (category.description != null &&
                    category.description!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    category.description!,
                    style: const TextStyle(color: Colors.white70),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  'Data: ${category.date}',
                  style: TextStyle(
                    color: Colors.amber.shade400,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white70),
            onTap: () {
              Navigator.pushNamed(
                context,
                '/category_games',
                arguments: {
                  'category': category,
                  'user': widget.user,
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildGameResults() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredGames.length,
      itemBuilder: (context, index) {
        Game game = _filteredGames[index];
        return Card(
          color: Colors.white.withOpacity(0.1),
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              backgroundColor: Colors.purple.shade700,
              child: const Icon(Icons.videogame_asset, color: Colors.white),
            ),
            title: Text(
              game.name ?? '',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (game.description != null && game.description!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    game.description!,
                    style: const TextStyle(color: Colors.white70),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  'Lançamento: ${game.releaseDate}',
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
