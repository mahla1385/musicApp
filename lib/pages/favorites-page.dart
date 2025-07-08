import 'package:flutter/material.dart';
import 'page-song-detail.dart';

class FavoritesPage extends StatelessWidget {
  final List<Map<String, dynamic>> favorites;
  final Function(Map<String, dynamic>) onLike;

  const FavoritesPage({
    Key? key,
    required this.favorites,
    required this.onLike,
  }) : super(key: key);

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
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.grey),
                onPressed: () {
                  _confirmDelete(context, song);
                },
              ),
            ),
          );
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, Map<String, dynamic> song) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove Favorite'),
        content: const Text('Are you sure you want to remove this song from your favorites?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              onLike(song);
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Removed from favorites')),
              );
            },
            child: const Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}