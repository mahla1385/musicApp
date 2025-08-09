import 'dart:io';
import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';

import '../utils/user_session.dart';
import 'page-song-detail.dart';
import 'free-song-download-page.dart';

class DownloadedSongsManager {
  static final DownloadedSongsManager _instance = DownloadedSongsManager._internal();
  factory DownloadedSongsManager() => _instance;
  DownloadedSongsManager._internal();

  final List<Map<String, dynamic>> downloadedSongs = [];

  void addSong(Map<String, dynamic> song) {
    if (!downloadedSongs.any((s) => s['filePath'] == song['filePath'])) {
      downloadedSongs.add(song);
    }
  }
}

class HomePage extends StatefulWidget {
  final List<Map<String, dynamic>> favorites;
  final Function(Map<String, dynamic>) onLike;

  const HomePage({
    Key? key,
    required this.favorites,
    required this.onLike,
  }) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final OnAudioQuery _audioQuery = OnAudioQuery();
  List<SongModel> _songs = [];
  bool _loading = true;
  String? _error;
  int _sortTypeIndex = 0;
  int _navIndex = 0;
  String _searchQuery = "";
  final TextEditingController _searchController = TextEditingController();

  final List<SongSortType> _sortTypes = [
    SongSortType.TITLE,
    SongSortType.ARTIST,
    SongSortType.ALBUM,
    SongSortType.DURATION,
  ];
  final List<String> _sortNames = ['Title', 'Artist', 'Album', 'Duration'];

  @override
  void initState() {
    super.initState();
    _fetchSongs();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchSongs() async {
    setState(() => _loading = true);
    var audioStatus = await Permission.audio.status;
    var storageStatus = await Permission.storage.status;

    if (!audioStatus.isGranted) await Permission.audio.request();
    if (!storageStatus.isGranted) await Permission.storage.request();

    if (!audioStatus.isGranted && !storageStatus.isGranted) {
      setState(() {
        _loading = false;
        _error = 'Permission denied!';
      });
      return;
    }

    try {
      final songs = await _audioQuery.querySongs(
        sortType: _sortTypes[_sortTypeIndex],
        orderType: OrderType.ASC_OR_SMALLER,
        uriType: UriType.EXTERNAL,
      );
      setState(() {
        _songs = songs;
        _loading = false;
        _error = null;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = 'Error reading songs: $e';
      });
    }
  }

  List<Map<String, dynamic>> get _downloadedSongs =>
      DownloadedSongsManager().downloadedSongs;

  List<SongModel> get _filteredSongs {
    List<SongModel> filtered = _searchQuery.isEmpty
        ? List.from(_songs)
        : _songs.where((song) => song.title.toLowerCase().contains(_searchQuery.toLowerCase())).toList();

    switch (_sortTypeIndex) {
      case 0:
        filtered.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
        break;
      case 1:
        filtered.sort((a, b) => (a.artist ?? '').toLowerCase().compareTo((b.artist ?? '').toLowerCase()));
        break;
      case 2:
        filtered.sort((a, b) => (a.album ?? '').toLowerCase().compareTo((b.album ?? '').toLowerCase()));
        break;
      case 3:
        filtered.sort((a, b) => (a.duration ?? 0).compareTo(b.duration ?? 0));
        break;
    }
    return filtered;
  }

  void _goToSongDetailFromDevice(SongModel song) {
    final songMap = {
      'title': song.title,
      'artist': song.artist ?? '',
      'file': song.data,
      'album': song.album ?? '',
      'duration': song.duration ?? 0,
      'id': song.id,
      'uri': song.uri,
    };
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SongDetailPage(
          song: songMap,
          favorites: widget.favorites,
          onLike: widget.onLike,
        ),
      ),
    );
  }

  void _goToSongDetailFromDownload(Map<String, dynamic> song) {
    final songMap = {
      'title': song['title'],
      'artist': song['artist'],
      'file': song['filePath'],
      'cover': song['cover'],
    };
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SongDetailPage(
          song: songMap,
          favorites: widget.favorites,
          onLike: widget.onLike,
        ),
      ),
    );
  }

  void _handleLike(Map<String, dynamic> song) {
    setState(() {
      if (widget.favorites.any((s) => s['title'] == song['title'])) {
        widget.favorites.removeWhere((s) => s['title'] == song['title']);
      } else {
        widget.favorites.add(song);
      }
    });
  }

  void _showLoginRequiredDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Login Required"),
        content: const Text("Please login to access this section."),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: const Text("Login"),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_error != null) {
      return Scaffold(
        body: Center(child: Text(_error!)),
        bottomNavigationBar: _buildBottomNavigationBar(),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Songs :)"),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            },
          ),
          PopupMenuButton<int>(
            icon: const Icon(Icons.sort),
            initialValue: _sortTypeIndex,
            onSelected: (index) async {
              setState(() => _sortTypeIndex = index);
              await _fetchSongs();
            },
            itemBuilder: (context) => List.generate(_sortTypes.length, (index) {
              return PopupMenuItem<int>(
                value: index,
                child: Text('Sort by ${_sortNames[index]}'),
              );
            }),
          ),
          IconButton(
            icon: const Icon(Icons.favorite, color: Colors.redAccent),
            onPressed: () {
              if (UserSession.userId == null) {
                Navigator.pushNamed(context, '/guestFavorites');
              } else {
                Navigator.pushNamed(context, '/favorites');
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by title...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                if (_downloadedSongs.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text('Downloaded Songs',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  ..._downloadedSongs.map((song) {
                    return ListTile(
                      leading: Image.asset(
                        song['cover'] ?? 'assets/images/Screenshot-2025-04-15-121400.jpg',
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                      ),
                      title: Text(song['title']),
                      subtitle: Text(song['artist']),
                      onTap: () => _goToSongDetailFromDownload(song),
                      trailing: IconButton(
                        icon: Icon(
                          widget.favorites.any((s) => s['title'] == song['title'])
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: widget.favorites.any((s) => s['title'] == song['title'])
                              ? Colors.red
                              : Colors.grey,
                        ),
                        onPressed: () => _handleLike(song),
                      ),
                    );
                  }).toList(),
                  const Divider(),
                ],
                if (_filteredSongs.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text("No results found."),
                    ),
                  )
                else
                  ..._filteredSongs.map((song) {
                    return ListTile(
                      leading: QueryArtworkWidget(
                        id: song.id,
                        type: ArtworkType.AUDIO,
                        nullArtworkWidget: Image.asset(
                          'assets/images/Screenshot-2025-04-15-121400.jpg',
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                        ),
                      ),
                      title: Text(song.title),
                      subtitle: Text(song.artist ?? "Unknown artist"),
                      onTap: () => _goToSongDetailFromDevice(song),
                      trailing: IconButton(
                        icon: Icon(
                          widget.favorites.any((s) => s['title'] == song.title)
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: widget.favorites.any((s) => s['title'] == song.title)
                              ? Colors.red
                              : Colors.grey,
                        ),
                        onPressed: () {
                          final songMap = {
                            'title': song.title,
                            'artist': song.artist ?? '',
                            'file': song.data,
                            'album': song.album ?? '',
                            'duration': song.duration ?? 0,
                            'id': song.id,
                            'uri': song.uri,
                          };
                          _handleLike(songMap);
                        },
                      ),
                    );
                  }).toList(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _navIndex,
      selectedItemColor: Colors.cyan[700],
      unselectedItemColor: Colors.grey[600],
      onTap: (index) {
        setState(() => _navIndex = index);

        if (index == 1) {
          if (UserSession.userId == null) {
            _showLoginRequiredDialog();
          } else {
            Navigator.pushReplacementNamed(context, '/musicshop');
          }
        } else if (index == 2) {
          if (UserSession.userId == null) {
            _showLoginRequiredDialog();
          } else {
            Navigator.pushReplacementNamed(context, '/account');
          }
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Shop'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Account'),
      ],
    );
  }
}