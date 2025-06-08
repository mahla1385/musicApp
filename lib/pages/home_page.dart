import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';
import 'page-song-detail.dart';

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

  String _username = "Unknown User";
  String _email = "Unknown Email";
  bool _premium = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      if (args['username'] != null && args['username'].toString().isNotEmpty) {
        _username = args['username'];
      }
      if (args['email'] != null && args['email'].toString().isNotEmpty) {
        _email = args['email'];
      }
      if (args['premium'] != null) {
        _premium = args['premium'] == true;
      }
    }
  }

  final List<SongSortType> _sortTypes = [
    SongSortType.TITLE,
    SongSortType.ARTIST,
    SongSortType.ALBUM,
    SongSortType.DURATION,
  ];
  final List<String> _sortNames = [
    'Title', 'Artist', 'Album', 'Duration'
  ];

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

  void _handleLike(Map<String, dynamic> song) {
    setState(() {
      if (widget.favorites.any((s) => s['title'] == song['title'])) {
        widget.favorites.removeWhere((s) => s['title'] == song['title']);
      } else {
        widget.favorites.add(song);
      }
    });
  }

  Future<void> _fetchSongs() async {
    setState(() {
      _loading = true;
    });

    var audioStatus = await Permission.audio.status;
    var storageStatus = await Permission.storage.status;

    if (!audioStatus.isGranted) await Permission.audio.request();
    if (!storageStatus.isGranted) await Permission.storage.request();

    audioStatus = await Permission.audio.status;
    storageStatus = await Permission.storage.status;

    if (!audioStatus.isGranted && !storageStatus.isGranted) {
      setState(() {
        _loading = false;
        _error = 'Permission denied!';
      });
      return;
    }

    try {
      List<SongModel> songs = await _audioQuery.querySongs(
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

  List<SongModel> get _filteredSongs {
    List<SongModel> filtered;
    if (_searchQuery.isEmpty) {
      filtered = List.from(_songs);
    } else {
      filtered = _songs
          .where((song) =>
          song.title.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    // مرتب سازی دستی
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

  void _goToSongDetail(SongModel song) {
    final songMap = {
      'title': song.title,
      'artist': song.artist ?? '',
      'file': song.data,
      'album': song.album ?? '',
      'duration': song.duration ?? 0,
      'id': song.id,
      'uri': song.uri
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

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
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
          PopupMenuButton<int>(
            icon: const Icon(Icons.sort),
            initialValue: _sortTypeIndex,
            onSelected: (index) async {
              setState(() {
                _sortTypeIndex = index;
              });
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
              Navigator.pushNamed(context, '/favorites');
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
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
          ),
          Expanded(
            child: _filteredSongs.isEmpty
                ? const Center(child: Text("No results found."))
                : ListView.builder(
              itemCount: _filteredSongs.length,
              itemBuilder: (context, index) {
                final song = _filteredSongs[index];
                return ListTile(
                  leading: QueryArtworkWidget(
                    id: song.id,
                    type: ArtworkType.AUDIO,
                  ),
                  title: Text(song.title),
                  subtitle: Text(song.artist ?? "Unknown artist"),
                  onTap: () => _goToSongDetail(song),
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
                        'uri': song.uri
                      };
                      _handleLike(songMap);
                    },
                  ),
                );
              },
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
        if (index == 1) {
          Navigator.pushReplacementNamed(context, '/musicshop');
        } else if (index == 2) {
          Navigator.pushReplacementNamed(
            context,
            '/account',
            arguments: {
              'username': _username,
              'email': _email,
              'premium': _premium,
            },
          );
        }
        setState(() {
          _navIndex = index;
        });
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Shop'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Account'),
      ],
    );
  }
}