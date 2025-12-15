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

  Widget _buildCategoryCard(Category category) {
    final startDate = category.startDate != null
        ? DateTime.tryParse(category.startDate!)
        : null;
    final endDate = category.endDate != null
        ? DateTime.tryParse(category.endDate!)
        : null;
    
    final now = DateTime.now();
    final isActive = startDate != null &&
        endDate != null &&
        now.isAfter(startDate) &&
        now.isBefore(endDate);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => TelaCategoryNominees(category: category),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isActive
                  ? [Colors.amber.shade700, Colors.orange.shade800]
                  : [Colors.grey.shade700, Colors.grey.shade900],
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
                      Icons.emoji_events,
                      color: Colors.white,
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        category.title ?? 'Sem título',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isActive
                            ? Colors.green.shade400
                            : Colors.red.shade400,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isActive ? 'ATIVA' : 'INATIVA',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                if (category.description != null &&
                    category.description!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    category.description!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(Icons.calendar_today, color: Colors.white70, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      startDate != null
                          ? '${startDate.day}/${startDate.month}/${startDate.year}'
                          : 'Sem data',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.event, color: Colors.white70, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      endDate != null
                          ? '${endDate.day}/${endDate.month}/${endDate.year}'
                          : 'Sem data',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white,
                      size: 20,
                    ),
                  ],
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
                            'Premiações',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Gerenciar categorias e indicados',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
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
                    : _categories.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.emoji_events_outlined,
                                  size: 80,
                                  color: Colors.white30,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Nenhuma categoria cadastrada',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white70,
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
                              itemCount: _categories.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 16),
                              itemBuilder: (context, index) {
                                return _buildCategoryCard(_categories[index]);
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