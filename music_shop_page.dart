import 'package:flutter/material.dart';
import 'page-song-detail.dart';

class MusicShopPage extends StatefulWidget {
  const MusicShopPage({super.key});

  @override
  State<MusicShopPage> createState() => _MusicShopPageState();
}

class _MusicShopPageState extends State<MusicShopPage> {
  final List<String> categories = ['Iranian', 'International', 'Local', 'Newest'];
  String selectedCategory = 'Iranian';

  final Map<String, List<Map<String, dynamic>>> songsByCategory = {
    'Iranian': [
      {'title': 'Persian Classic', 'artist': 'Singer A', 'price': 0, 'cover': 'assets/images/default_cover.png'},
      {'title': 'Love Melody', 'artist': 'Singer B', 'price': 5000, 'cover': 'assets/images/default_cover.png'},
    ],
    'International': [
      {'title': 'Global Vibe', 'artist': 'Artist X', 'price': 0, 'cover': 'assets/images/default_cover.png'},
    ],
    'Local': [
      {'title': 'Folk Tune', 'artist': 'Local Star', 'price': 3000, 'cover': 'assets/images/default_cover.png'},
    ],
    'Newest': [
      {'title': 'Brand New Hit', 'artist': 'Pop Icon', 'price': 10000, 'cover': 'assets/images/default_cover.png'},
    ]
  };

  int _navIndex = 1;

  @override
  Widget build(BuildContext context) {
    final songs = songsByCategory[selectedCategory] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Music Shop'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              children: categories.map((cat) {
                final isSelected = cat == selectedCategory;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    selectedColor: Colors.cyan[600],
                    onSelected: (_) {
                      setState(() {
                        selectedCategory = cat;
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: songs.length,
        itemBuilder: (context, index) {
          final song = songs[index];
          return Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
            child: ListTile(
              leading: Icon(Icons.music_video, color: Colors.cyan[600], size: 36),
              title: Text(song['title']),
              subtitle: Text(song['artist']),
              trailing: Text(
                song['price'] == 0 ? 'Free' : '${song['price']} Toman',
                style: TextStyle(
                  color: song['price'] == 0 ? Colors.cyan : Colors.grey[800],
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SongDetailPage(song: song),
                  ),
                );
              },
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _navIndex,
        selectedItemColor: Colors.cyan[700],
        unselectedItemColor: Colors.grey[600],
        backgroundColor: Colors.grey[100],
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/home');
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, '/account');
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Shop'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Account'),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.cyan,
        icon: const Icon(Icons.payment, color: Colors.white),
        label: const Text('Payment', style: TextStyle(color: Colors.white)),
        onPressed: () {
          Navigator.pushNamed(context, '/payment');
        },
      ),
    );
  }
}