import 'package:flutter/material.dart';
import 'page-song-detail.dart';

class FavoritesPage extends StatelessWidget {
  final List<Map<String, dynamic>> favorites;
  final Function(Map<String, dynamic>) onLike;

  const FavoritesPage({Key? key, required this.favorites, required this.onLike}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite Songs'),
      ),
      body: favorites.isEmpty
          ? const Center(child: Text('No favorite songs yet!'))
          : ListView.builder(
        itemCount: favorites.length,
        itemBuilder: (context, index) {
          final song = favorites[index];
          return Card(
            child: ListTile(
              leading: const Icon(Icons.favorite, color: Colors.red),
              title: Text(song['title']),
              subtitle: Text(song['artist']),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SongDetailPage(
                      song: song,
                      favorites: favorites,
                      onLike: onLike,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}