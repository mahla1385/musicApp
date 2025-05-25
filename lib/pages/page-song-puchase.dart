import 'package:flutter/material.dart';

class SongPurchasePage extends StatelessWidget {
  final Map<String, dynamic> song;

  const SongPurchasePage({super.key, required this.song});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(song['title']),
        backgroundColor: Colors.cyan[600],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(song['cover'], height: 200),
            const SizedBox(height: 20),
            Text(song['title'], style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text(song['artist'], style: const TextStyle(fontSize: 18, color: Colors.grey)),
            const SizedBox(height: 20),
            Text('Score: ★★★★☆', style: TextStyle(fontSize: 20, color: Colors.orange[800])),
            const SizedBox(height: 20),
            Text(
              song['price'] == 0 ? 'Free' : '${song['price']} Toman',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.cyan[700],
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/payment');
                  },
                  icon: const Icon(Icons.payment),
                  label: const Text('Go to Payment'),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[800],
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Download started (not yet implemented)")),
                    );
                  },
                  icon: const Icon(Icons.download),
                  label: const Text('Download'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}