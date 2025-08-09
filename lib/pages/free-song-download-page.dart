import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';
import '../utils/user_session.dart';

class FreeSongDownloadPage extends StatefulWidget {
  final Map<String, dynamic> song;

  const FreeSongDownloadPage({super.key, required this.song});

  @override
  State<FreeSongDownloadPage> createState() => _FreeSongDownloadPageState();
}

class _FreeSongDownloadPageState extends State<FreeSongDownloadPage> {
  bool _isDownloading = false;
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _localPath;
  bool _isPlaying = false;

  Future<void> handleDownload() async {
    final songId = widget.song['id'];
    final isFree = widget.song['price'] == 0;
    final isPurchased = UserSession.hasPurchased(songId);

    if (isFree || isPurchased) {
      downloadSong();
    } else {
      _showPurchaseDialog();
    }
  }

  Future<void> downloadSong() async {
    final url = widget.song['url'];
    final title = widget.song['title'] ?? 'song';

    if (url == null || url.toString().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Song URL not available')),
      );
      return;
    }

    setState(() => _isDownloading = true);

    try {
      final dir = await getApplicationDocumentsDirectory();
      final path = '${dir.path}/$title.mp3';

      await Dio().download(url, path);

      _localPath = path;

      setState(() => _isDownloading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Downloaded successfully: $title')),
      );

      await _audioPlayer.play(DeviceFileSource(path));
      setState(() => _isPlaying = true);
    } catch (e) {
      setState(() => _isDownloading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Download failed')),
      );
    }
  }

  void _showPurchaseDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Download Unavailable"),
        content: const Text("You must purchase this song before downloading."),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: const Text("Go to Payment"),
            onPressed: () async {
              Navigator.pop(context);

              final result = await Navigator.pushNamed(
                context,
                '/payment',
                arguments: {
                  'songId': widget.song['id'],
                  'price': widget.song['price'],
                },
              );

              if (result != null && result == widget.song['id']) {
                UserSession.addPurchase(widget.song['id']);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Payment successful! You can now download.")),
                );
                setState(() {});
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.song['title'] ?? 'Unknown Title';
    final artist = widget.song['artist'] ?? 'Unknown Artist';
    final cover = widget.song['cover'] ?? 'assets/images/Screenshot-2025-04-15-121400.jpg';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Download Song :)'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  cover,
                  width: 180,
                  height: 180,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 24),
              Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(artist, style: const TextStyle(fontSize: 18, color: Colors.grey)),
              const SizedBox(height: 32),
              _isDownloading
                  ? const CircularProgressIndicator()
                  : ElevatedButton.icon(
                icon: const Icon(Icons.download),
                label: const Text('Download song'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.cyan,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  textStyle: const TextStyle(fontSize: 16),
                ),
                onPressed: handleDownload,
              ),
            ],
          ),
        ),
      ),
    );
  }
}