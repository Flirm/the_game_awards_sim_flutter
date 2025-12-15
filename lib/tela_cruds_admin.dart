import 'package:flutter/material.dart';
import 'views/tela_admin_games.dart';
import 'views/tela_admin_categories.dart';
import 'views/tela_admin_genres.dart';
import 'views/tela_admin_category_games.dart';

class TelaCrudsAdmin extends StatelessWidget {
  const TelaCrudsAdmin({super.key});

  Widget _buildActionCard({
    required BuildContext context,
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 140,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color, color.withOpacity(0.7)],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: Colors.white),
              const SizedBox(height: 12),
              Text(
                label,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Painel Admin',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Gerenciar sistema',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: Icon(Icons.logout, color: Colors.white, size: 28),
                      tooltip: 'Sair',
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('Sair'),
                            content: Text('Deseja realmente sair do painel admin?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text('Cancelar'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context); 
                                  Navigator.pushNamedAndRemoveUntil(
                                    context,
                                    '/',
                                    (route) => false,
                                  );
                                },
                                child: Text('Sair', style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    children: [
                      _buildActionCard(
                        context: context,
                        label: 'Games',
                        icon: Icons.videogame_asset,
                        color: Colors.blue.shade700,
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const TelaAdminGames()),
                        ),
                      ),
                      _buildActionCard(
                        context: context,
                        label: 'Categorias',
                        icon: Icons.category,
                        color: Colors.purple.shade700,
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const TelaAdminCategories()),
                        ),
                      ),
                      _buildActionCard(
                        context: context,
                        label: 'Gêneros',
                        icon: Icons.style,
                        color: Colors.orange.shade700,
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const TelaAdminGenres()),
                        ),
                      ),
                      _buildActionCard(
                        context: context,
                        label: 'Premiações',
                        icon: Icons.emoji_events,
                        color: Colors.amber.shade700,
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const TelaAdminCategoryGames()),
                        ),
                      ),
                    ],
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
