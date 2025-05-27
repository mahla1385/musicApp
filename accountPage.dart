import 'package:flutter/material.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final String username = (args?['username']?.toString().isNotEmpty ?? false)
        ? args!['username']
        : 'Unknown User';
    final String email = (args?['email']?.toString().isNotEmpty ?? false)
        ? args!['email']
        : 'Unknown Email';
    final bool premium = args?['premium'] == true;

    final Map<String, dynamic> user = {
      'username': username,
      'email': email,
      'avatar': 'assets/images/default_avatar.png',
      'premium': premium,
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Account'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundImage: AssetImage(user['avatar'] as String),
              radius: 48,
            ),
            const SizedBox(height: 16),
            Text(
              user['username'] as String,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              user['email'] as String,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 18),
            Chip(
              label: Text((user['premium'] as bool) ? 'Premium User' : 'Free User'),
              backgroundColor: (user['premium'] as bool) ? Colors.cyan : Colors.grey[400],
              labelStyle: const TextStyle(color: Colors.white),
              avatar: Icon(
                (user['premium'] as bool) ? Icons.star : Icons.person,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 30),
            ListTile(
              leading: const Icon(Icons.payment, color: Colors.cyan),
              title: const Text('Payment'),
              onTap: () => Navigator.pushNamed(context, '/payment'),
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text('Logout'),
              onTap: () => Navigator.pushReplacementNamed(context, '/login'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        selectedItemColor: Colors.cyan[700],
        unselectedItemColor: Colors.grey[600],
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/home',
                arguments: {
                  'username': username,
                  'email': email,
                  'premium': premium,
                });
          } else if (index == 1) {
            Navigator.pushReplacementNamed(context, '/musicshop');
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Shop'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Account'),
        ],
      ),
    );
  }
}