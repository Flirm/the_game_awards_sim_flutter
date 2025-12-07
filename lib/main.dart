import 'package:flutter/material.dart';
import 'screens/home.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/guest_screen.dart';
import 'screens/user_dashboard.dart';
import 'screens/admin_dashboard.dart';

void main() {
  runApp(const TheGameAwardsApp());
}

class TheGameAwardsApp extends StatelessWidget {
  const TheGameAwardsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'The Game Awards',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF00D9FF),
        scaffoldBackgroundColor: const Color(0xFF0A2540),
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFF00D9FF),
          secondary: const Color(0xFFFF9800),
          surface: const Color(0xFF0A2540),
        ),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/guest': (context) => const GuestScreen(),
        '/user-dashboard': (context) => const UserDashboard(),
        '/admin-dashboard': (context) => const AdminDashboard(),
      },
    );
  }
}
