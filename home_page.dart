import 'package:flutter/material.dart';
import 'page-song-detail.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> localSongs = [
    {'title': 'Desert Melody', 'artist': 'Ali Reza', 'cover': 'assets/images/default_cover.png'},
    {'title': 'Night Vibes', 'artist': 'Sara Nouri', 'cover': 'assets/images/default_cover.png'},
    {'title': 'Sunrise Tune', 'artist': 'Mehrdad', 'cover': 'assets/images/default_cover.png'},
  ];

  List<Map<String, dynamic>> downloadedSongs = [
    {'title': 'Ocean Sounds', 'artist': 'DJ Wave', 'cover': 'assets/images/default_cover.png'},
    {'title': 'City Life', 'artist': 'Lily Beats', 'cover': 'assets/images/default_cover.png'},
    {'title': 'Calm Piano', 'artist': 'RelaxMan', 'cover': 'assets/images/default_cover.png'},
  ];

  String searchQuery = '';
  int _navIndex = 0;

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredLocal = localSongs
        .where((song) =>
        song['title']!.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    List<Map<String, dynamic>> filteredDownloaded = downloadedSongs
        .where((song) =>
        song['title']!.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: () {
              // TODO: sort logic
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              onChanged: (val) {
                setState(() {
                  searchQuery = val;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search for a song...',
                prefixIcon: const Icon(Icons.search),
              ),
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Local Songs', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ...filteredLocal.map((song) => Card(
            elevation: 1,
            color: Colors.cyan.withOpacity(0.08),
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: ListTile(
              leading: const Icon(Icons.library_music, color: Colors.cyan),
              title: Text(song['title']),
              subtitle: Text(song['artist']),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SongDetailPage(song: song),
                  ),
                );
              },
            ),
          )),
          const SizedBox(height: 18),
          const Text('Downloaded Songs', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ...filteredDownloaded.map((song) => Card(
            elevation: 1,
            color: Colors.cyan.withOpacity(0.08),
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: ListTile(
              leading: const Icon(Icons.download, color: Colors.cyan),
              title: Text(song['title']),
              subtitle: Text(song['artist']),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SongDetailPage(song: song),
                  ),
                );
              },
            ),
          )),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _navIndex,
        selectedItemColor: Colors.cyan[700],
        unselectedItemColor: Colors.grey[600],
        backgroundColor: Colors.grey[100],
        onTap: (index) {
          if (index == 1) {
            Navigator.pushReplacementNamed(context, '/musicshop');
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