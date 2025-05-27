import 'package:flutter/material.dart';
import 'page-song-detail.dart';
import 'favorites-page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> localSongs = [
    {
      'title': 'Bad Az To',
      'artist': 'Mohsen Chavoshi',
      'cover': 'assets/images/photo_2025-05-14_20-51-35.jpg',
      'file': 'assets/music/Mohsen Chavoshi - Bad Az To (320).mp3',
    },
    {
      'title': 'ZendanBan',
      'artist': 'Mohsen Chavoshi',
      'cover': 'assets/images/Mohsen-Chavoshi-Collection.jpg',
      'file': 'assets/music/Mohsen Chavoshi - Zendan Ban (320).mp3',
    },
    {
      'title': 'Bekham Az To Begzaram Man',
      'artist': 'Mohsen Chavoshi',
      'cover': 'assets/images/Screenshot-2025-04-15-121400.jpg',
      'file': 'assets/music/Mohsen Chavoshi - Bekham Az To Begzaram Man (320).mp3',
    },
  ];

  List<Map<String, dynamic>> downloadedSongs = [
    {
      'title': 'Ocean Sounds',
      'artist': 'DJ Wave',
      'cover': 'assets/images/photo_2025-05-14_20-51-35.jpg',
      'file': 'assets/music/Mohsen Chavoshi - Bad Az To (320).mp3',
    },
    {
      'title': 'City Life',
      'artist': 'Lily Beats',
      'cover': 'assets/images/photo_2025-05-14_20-51-35.jpg',
      'file': 'assets/music/Mohsen Chavoshi - Bad Az To (320).mp3',
    },
    {
      'title': 'Calm Piano',
      'artist': 'RelaxMan',
      'cover': 'assets/images/photo_2025-05-14_20-51-35.jpg',
      'file': 'assets/music/Mohsen Chavoshi - Bad Az To (320).mp3',
    },
  ];

  List<Map<String, dynamic>> favoriteSongs = [];

  String searchQuery = '';
  int _navIndex = 0;
  bool _isSortedAZ = true;

  // اضافه: نگهداری اطلاعات کاربر
  String username = 'User';
  String email = 'No email';
  bool premium = false;

  @override
  void didChangeDependencies() {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      if (args['username'] != null && args['username'].toString().isNotEmpty) {
        username = args['username'];
      }
      if (args['email'] != null && args['email'].toString().isNotEmpty) {
        email = args['email'];
      }
      if (args['premium'] != null) {
        premium = args['premium'] == true;
      }
    }
    super.didChangeDependencies();
  }

  void _sortSongsAZ() {
    setState(() {
      _isSortedAZ = !_isSortedAZ;
      localSongs.sort((a, b) => _isSortedAZ
          ? a['title'].toLowerCase().compareTo(b['title'].toLowerCase())
          : b['title'].toLowerCase().compareTo(a['title'].toLowerCase()));
      downloadedSongs.sort((a, b) => _isSortedAZ
          ? a['title'].toLowerCase().compareTo(b['title'].toLowerCase())
          : b['title'].toLowerCase().compareTo(a['title'].toLowerCase()));
    });
  }

  @override
  void initState() {
    super.initState();
    localSongs.sort((a, b) => a['title'].toLowerCase().compareTo(b['title'].toLowerCase()));
    downloadedSongs.sort((a, b) => a['title'].toLowerCase().compareTo(b['title'].toLowerCase()));
  }

  void _handleLike(Map<String, dynamic> song) {
    setState(() {
      if (favoriteSongs.any((s) => s['title'] == song['title'])) {
        favoriteSongs.removeWhere((s) => s['title'] == song['title']);
      } else {
        favoriteSongs.add(song);
      }
    });
  }

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
            icon: Icon(
              _isSortedAZ ? Icons.sort_by_alpha : Icons.sort_by_alpha_outlined,
            ),
            onPressed: _sortSongsAZ,
            tooltip: _isSortedAZ ? 'مرتب‌سازی (الف-ی)' : 'مرتب‌سازی (ی-الف)',
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
          Text(
            'Welcome, $username!',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 18),
          const Text('Local Songs',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ...filteredLocal.map((song) => ListTile(
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
            leading: CircleAvatar(
              backgroundImage: AssetImage(song['cover']),
              radius: 22,
            ),
            title: Text(song['title']),
            subtitle: Text(song['artist']),
            trailing: IconButton(
              icon: Icon(
                favoriteSongs.any((s) => s['title'] == song['title'])
                    ? Icons.favorite
                    : Icons.favorite_border,
                color: favoriteSongs.any((s) => s['title'] == song['title'])
                    ? Colors.red
                    : Colors.grey,
              ),
              onPressed: () => _handleLike(song),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SongDetailPage(
                    song: song,
                    favorites: favoriteSongs,
                    onLike: _handleLike,
                  ),
                ),
              );
            },
          )),
          const SizedBox(height: 18),
          const Text('Downloaded Songs',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ...filteredDownloaded.map((song) => ListTile(
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
            leading: CircleAvatar(
              backgroundImage: AssetImage(song['cover']),
              radius: 22,
            ),
            title: Text(song['title']),
            subtitle: Text(song['artist']),
            trailing: IconButton(
              icon: const Icon(Icons.download, color: Colors.cyan),
              onPressed: () {
                // دانلود آهنگ
              },
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SongDetailPage(
                    song: song,
                    favorites: favoriteSongs,
                    onLike: _handleLike,
                  ),
                ),
              );
            },
          )),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _navIndex,
        selectedItemColor: Colors.cyan[700],
        unselectedItemColor: Colors.grey[600],
        backgroundColor: Colors.grey[100],
        onTap: (index) {
          setState(() {
            _navIndex = index;
          });
          if (index == 1) {
            Navigator.pushReplacementNamed(context, '/musicshop');
          } else if (index == 2) {
            Navigator.pushReplacementNamed(
              context,
              '/account',
              arguments: {
                'username': username,
                'email': email,
                'premium': premium,
              },
            );
          } else if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => FavoritesPage(
                  favorites: favoriteSongs,
                  onLike: _handleLike,
                ),
              ),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.store), label: 'Shop'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person), label: 'Account'),
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite), label: 'Favorites'),
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