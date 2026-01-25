import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import this
import 'routes.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  // 1. Initialize binding so we can read storage before app starts
  WidgetsFlutterBinding.ensureInitialized(); 
  
  // 2. Check for the token
  final prefs = await SharedPreferences.getInstance();
  final String? token = prefs.getString('auth_token');
  
  // 3. Decide the starting page
  // If token exists -> Go to Home. If not -> Go to Login.
  final String initialRoute = (token != null) ? AppRoutes.home : AppRoutes.login;

  runApp(MyApp(initialRoute: initialRoute));
}

class MyApp extends StatelessWidget {
  final String initialRoute; // Variable to hold our decision

  // Constructor now accepts the initialRoute
  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SeeMe',
      theme: AppTheme.lightTheme,
      initialRoute: initialRoute, // <--- Dynamic start page!
      routes: AppRoutes.routes,
    );
  }
}
