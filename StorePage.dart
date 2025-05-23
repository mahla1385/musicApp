import 'package:flutter/material.dart';

class StorePage extends StatelessWidget {
  final List<String> categories = [
    'Persian Song',
    'American Song',
    'Happy Song',
    'Sad Song'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Music Shop')),
      body: ListView.builder(
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(categories[index]),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SongListPage(category: categories[index]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class SongListPage extends StatelessWidget {
  final String category;

  SongListPage({required this.category});

  final List<Map<String, dynamic>> songs = [
    {
      'title': 'Song A',
      'artist': 'Artist A',
      'cover': 'assets/images/cover.png',
      'rating': 4.5,
      'price': 0,
      'downloads': 120,
    },
    {
      'title': 'Song B',
      'artist': 'Artist B',
      'cover': 'assets/images/cover.png',
      'rating': 3.8,
      'price': 2,
      'downloads': 98,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$category Songs'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {},
            itemBuilder: (context) => [
              PopupMenuItem(value: 'rating', child: Text('Sort by Rating')),
              PopupMenuItem(value: 'price', child: Text('Sort by Price')),
              PopupMenuItem(value: 'downloads', child: Text('Sort by Downloads')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(hintText: 'Search songs...'),
              onChanged: (value) {},
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: songs.length,
              itemBuilder: (context, index) {
                final song = songs[index];
                return ListTile(
                  leading: Image.asset(song['cover'], width: 50),
                  title: Text(song['title']),
                  subtitle: Text(song['artist']),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 16),
                      Text('${song['rating']}'),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SongDetailPage(song: song),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class SongDetailPage extends StatelessWidget {
  final Map<String, dynamic> song;

  SongDetailPage({required this.song});

  @override
  Widget build(BuildContext context) {
    final bool isFree = song['price'] == 0;
    final bool hasSubscription = true; // Mock value

    return Scaffold(
      appBar: AppBar(title: Text(song['title'])),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Image.asset(song['cover'], height: 150)),
            SizedBox(height: 16),
            Text(song['title'], style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text('By ${song['artist']}'),
            Row(
              children: [
                Icon(Icons.star, color: Colors.amber),
                Text('${song['rating']}'),
              ],
            ),
            SizedBox(height: 20),
            if (isFree || hasSubscription)
              ElevatedButton(onPressed: () {}, child: Text('Download'))
            else
              ElevatedButton(onPressed: () {}, child: Text('Buy for \$${song['price']}')),
            SizedBox(height: 20),
            Text('Leave a Comment:'),
            TextField(),
            SizedBox(height: 10),
            Text('User Comments (likes/dislikes)...'),
          ],
        ),
      ),
    );
  }
}