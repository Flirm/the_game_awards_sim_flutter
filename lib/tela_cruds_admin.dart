import 'package:flutter/material.dart';
import 'views/tela_admin_games.dart';
import 'views/tela_admin_categories.dart';
import 'views/tela_admin_genres.dart';
import 'views/tela_admin_category_games.dart';

class TelaCrudsAdmin extends StatelessWidget {
  const TelaCrudsAdmin({super.key});

  Widget _buildActionButton({
    required BuildContext context,
    required String label,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: 260,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(56),
        ),
        onPressed: onPressed,
        child: Text(label),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin - CRUDs'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildActionButton(
                context: context,
                label: 'Games',
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const TelaAdminGames()),
                ),
              ),
              const SizedBox(height: 20),
              _buildActionButton(
                context: context,
                label: 'Categorias',
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const TelaAdminCategories()),
                ),
              ),
              const SizedBox(height: 20),
              _buildActionButton(
                context: context,
                label: 'Generos',
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const TelaAdminGenres()),
                ),
              ),
              const SizedBox(height: 20),
              _buildActionButton(
                context: context,
                label: 'Premiacoes',
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const TelaAdminCategoryGames()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
