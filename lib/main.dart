import 'package:flutter/material.dart';
import 'pages/login_page.dart';
import 'pages/signup_page.dart';
import 'pages/home_page.dart';
import 'pages/music_shop_page.dart';
import 'pages/payment_page.dart';
import 'pages/accountPage.dart';
import 'pages/favorites-page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<Map<String, dynamic>> favorites = [];

  void handleLike(Map<String, dynamic> song) {
    setState(() {
      if (favorites.any((item) => item['id'] == song['id'])) {
        favorites.removeWhere((item) => item['id'] == song['id']);
      } else {
        favorites.add(song);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Music Player App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.cyan,
          primary: Colors.cyan,
          secondary: Colors.grey[800]!,
          surface: Colors.grey[100]!,
        ),
        appBarTheme: AppBarTheme(
          color: Colors.cyan[700],
          titleTextStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        scaffoldBackgroundColor: Colors.grey[50],
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.cyan,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[200],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        useMaterial3: true,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignUpPage(),
        '/home': (context) => HomePage(
          favorites: favorites,
          onLike: handleLike,
        ),
        '/musicshop': (context) => const MusicShopPage(),
        '/payment': (context) => const PaymentPage(),
        '/account': (context) => const AccountPage(),
        '/favorites': (context) => FavoritesPage(
          favorites: favorites,
          onLike: handleLike,
        ),
      },
    );
  }
}