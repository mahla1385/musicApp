import 'package:flutter/material.dart';
import 'free-song-download-page.dart';
import 'page-song-puchase.dart';
import '../utils/user_session.dart';

class MusicShopPage extends StatefulWidget {
  const MusicShopPage({super.key});

  @override
  State<MusicShopPage> createState() => _MusicShopPageState();
}

class _MusicShopPageState extends State<MusicShopPage> {
  final List<String> categories = ['Iranian', 'International', 'Local'];
  String selectedCategory = 'Iranian';

  final Map<String, List<Map<String, dynamic>>> songsByCategory = {
    'Iranian': [
      {
        'id': 1,
        'title': 'Persian Classic',
        'artist': 'Singer A',
        'price': 0,
        'cover': 'assets/images/Screenshot-2025-04-15-121400.jpg',
        'url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3',
      },
      {
        'id': 2,
        'title': 'Love Melody',
        'artist': 'Singer B',
        'price': 5000,
        'cover': 'assets/images/Screenshot-2025-04-15-121400.jpg',
      },
    ],
    'International': [
      {
        'id': 3,
        'title': 'Global Vibe',
        'artist': 'Artist X',
        'price': 0,
        'cover': 'assets/images/Screenshot-2025-04-15-121400.jpg',
        'url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
      },
    ],
    'Local': [
      {
        'id': 4,
        'title': 'Folk Tune',
        'artist': 'Local Star',
        'price': 3000,
        'cover': 'assets/images/Screenshot-2025-04-15-121400.jpg',
      },
    ],
  };

  int _navIndex = 1;

  Future<bool> hasPurchased(int userId, int songId) async {
    await Future.delayed(Duration(milliseconds: 500));
    return songId == 2 || songId == 4;
  }

  String getSongDownloadUrl(int songId) {
    return 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-$songId.mp3';
  }

  void handleSongTap(Map<String, dynamic> song) async {
    final int price = song['price'] ?? 0;
    final int songId = song['id'] ?? 0;
    final userId = UserSession.userId;

    if (price == 0) {
      if (song.containsKey('url')) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => FreeSongDownloadPage(song: song)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Download URL not found for free song.")),
        );
      }
    } else {
      bool alreadyPurchased = await hasPurchased(userId!, songId);

      if (alreadyPurchased) {
        song['url'] = getSongDownloadUrl(songId);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => FreeSongDownloadPage(song: song)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final songs = songsByCategory[selectedCategory] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Music Shop'),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            },
          ),
        ],
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
          final int price = song['price'] is int ? song['price'] : 0;

          return Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
            child: ListTile(
              leading: Image.asset(
                song['cover'] ?? 'assets/images/Screenshot-2025-04-15-121400.jpg',
                width: 40,
                height: 40,
                fit: BoxFit.cover,
              ),
              title: Text(song['title'] ?? 'Unknown'),
              subtitle: Text(song['artist'] ?? 'Unknown'),
              trailing: Text(
                price == 0 ? 'Free' : '$price Toman',
                style: TextStyle(
                  color: price == 0 ? Colors.cyan : Colors.grey[800],
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () => handleSongTap(song),
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