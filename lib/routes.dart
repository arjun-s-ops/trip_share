import 'package:flutter/material.dart';
import 'auth/signup.dart';
import 'auth/login.dart';
import 'home/dashboard_screen.dart';

class AppRoutes {
  static const String signup = '/signup';
  static const String login = '/login';
  static const String home = '/home';

  static Map<String, WidgetBuilder> routes = {
    signup: (context) => const SignupPage(),
    login: (context) => const LoginPage(),
    home: (context) => const DashboardScreen(),
  };
}