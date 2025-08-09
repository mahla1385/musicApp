import 'package:flutter/material.dart';
import 'pages/SingletonWebsocket.dart';
import 'pages/login_page.dart';
import 'pages/signup_page.dart';
import 'pages/home_page.dart';
import 'pages/music_shop_page.dart';
import 'pages/payment_page.dart';
import 'pages/accountPage.dart';
import 'pages/favorites-page.dart';
import 'pages/welcomePage.dart';
import 'utils/user_session.dart';

void main() {
  final ws = MusicWebSocketClient();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<Map<String, dynamic>> userFavorites = [];
  List<Map<String, dynamic>> guestFavorites = [];

  void handleUserLike(Map<String, dynamic> song) {
    setState(() {
      if (userFavorites.any((item) => item['id'] == song['id'])) {
        userFavorites.removeWhere((item) => item['id'] == song['id']);
      } else {
        userFavorites.add(song);
      }
    });
  }

  void handleGuestLike(Map<String, dynamic> song) {
    setState(() {
      if (guestFavorites.any((item) => item['id'] == song['id'])) {
        guestFavorites.removeWhere((item) => item['id'] == song['id']);
      } else {
        guestFavorites.add(song);
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
      initialRoute: '/',
      routes: {
        '/': (context) => const WelcomePage(),
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignUpPage(),
        '/home': (context) => HomePage(
          favorites: userFavorites,
          onLike: handleUserLike,
        ),
        '/favorites': (context) => FavoritesPage(
          favorites: userFavorites,
          onLike: handleUserLike,
        ),
        '/guestHome': (context) => HomePage(
          favorites: guestFavorites,
          onLike: handleGuestLike,
        ),
        '/guestFavorites': (context) => FavoritesPage(
          favorites: guestFavorites,
          onLike: handleGuestLike,
        ),
        '/musicshop': (context) => UserSession.userId == null
            ? const WelcomePage()
            : const MusicShopPage(),
        '/account': (context) => UserSession.userId == null
            ? const WelcomePage()
            : const AccountPage(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/payment') {
          if (UserSession.userId == null) {
            return MaterialPageRoute(builder: (context) => const WelcomePage());
          }

          final args = settings.arguments as Map<String, dynamic>?;
          if (args == null || !args.containsKey('songId') || !args.containsKey('price')) {
            return MaterialPageRoute(
              builder: (context) => const Scaffold(
                body: Center(child: Text("Invalid payment arguments.")),
              ),
            );
          }

          return MaterialPageRoute(
            builder: (context) => PaymentPage(
              songId: args['songId'],
              price: args['price'],
            ),
          );
        }

        return null;
      },
    );
  }
}