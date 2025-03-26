import 'package:flutter/material.dart';
import 'package:farmora/screens/login_screen.dart';
import 'package:farmora/screens/signup_screen.dart';
import 'package:farmora/screens/welcome_screen.dart';
import 'package:farmora/screens/dashboard_screen.dart';
import 'package:farmora/screens/calculator_screen.dart';
import 'package:farmora/screens/product_list_screen.dart';

void main() {
  runApp(FarmoraApp());
}

class FarmoraApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Farmora',
      theme: ThemeData(
        primaryColor: Color(0xFF1E886), // Light dark blue
        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: Color(0xFF1E88E5), // Light dark blue
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Color(0xFFE3F2FD), // Light blue background
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(10.0),
          ),
          hintStyle: TextStyle(color: Colors.grey),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => WelcomeScreen(),
        '/login': (context) => LoginScreen(),
        '/signup': (context) => SignupScreen(),
        '/dashboard': (context) => DashboardScreen(),
        '/calculator': (context) => CalculatorScreen(),
        '/products': (context) => ProductListScreen(),
      },
    );
  }
}
