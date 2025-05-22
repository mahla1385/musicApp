import 'package:flutter/material.dart';

class SongDetailPage extends StatelessWidget {
  final Map<String, dynamic> song;
  const SongDetailPage({super.key, required this.song});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[900],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Song Details',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 26.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Album cover
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.cyanAccent.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.asset(
                    song['cover'] ?? 'assets/images/default_cover.png',
                    height: 220,
                    width: 220,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                song['title'] ?? '',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                song['artist'] ?? '',
                style: TextStyle(
                  color: Colors.cyan[200],
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              // Playback controls (visual only)
              Slider(
                value: 0.4,
                onChanged: (_) {},
                min: 0,
                max: 1,
                activeColor: Colors.cyan,
                inactiveColor: Colors.white24,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(icon: const Icon(Icons.shuffle), color: Colors.white38, onPressed: () {}),
                  IconButton(icon: const Icon(Icons.skip_previous), color: Colors.white, onPressed: () {}),
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.cyan,
                      boxShadow: [BoxShadow(color: Colors.cyanAccent.withOpacity(0.2), blurRadius: 20)],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.play_arrow),
                      color: Colors.white,
                      iconSize: 32,
                      onPressed: () {},
                    ),
                  ),
                  IconButton(icon: const Icon(Icons.skip_next), color: Colors.white, onPressed: () {}),
                  IconButton(icon: const Icon(Icons.repeat), color: Colors.white38, onPressed: () {}),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('2:01', style: TextStyle(color: Colors.white54)),
                  Text('-1:07', style: TextStyle(color: Colors.white54)),
                ],
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                icon: const Icon(Icons.favorite_border),
                label: const Text('Like'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.cyan,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(44),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}