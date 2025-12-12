import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'models/user.dart';
import 'models/category.dart';
import 'views/login_screen.dart';
import 'views/register_screen.dart';
import 'views/user_dashboard_screen.dart';
import 'views/category_games_screen.dart';
import 'tela_cruds_admin.dart';

void main() {
  // Inicializa o SQLite para desktop (Windows, Linux, macOS)
  if (!kIsWeb) {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
  }
  
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'The Game Awards',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        brightness: Brightness.dark,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (_) => const LoginScreen());
          case '/register':
            return MaterialPageRoute(builder: (_) => const RegisterScreen());
          case '/user_dashboard':
            final user = settings.arguments as User?;
            return MaterialPageRoute(builder: (_) => UserDashboardScreen(user: user));
          case '/category_games':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (_) => CategoryGamesScreen(
                category: args['category']! as Category,
                user: args['user'] as User?,
              ),
            );
          case '/admin':
            return MaterialPageRoute(builder: (_) => const TelaCrudsAdmin());
          default:
            return MaterialPageRoute(builder: (_) => const LoginScreen());
        }
      },
    );
  }
}
