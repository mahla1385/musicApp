import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';

class SongDetailPage extends StatefulWidget {
  final Map<String, dynamic> song;
  final List<Map<String, dynamic>> favorites;
  final Function(Map<String, dynamic>) onLike;

  const SongDetailPage({
    Key? key,
    required this.song,
    required this.favorites,
    required this.onLike,
  }) : super(key: key);

  @override
  State<SongDetailPage> createState() => _SongDetailPageState();
}

class _SongDetailPageState extends State<SongDetailPage> {
  late AudioPlayer _player;
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _init();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    try {
      await _player.setAsset(widget.song['file']!);
    } catch (e) {
      print("Error loading audio source: $e");
    }
  }

  bool get isLiked {
    return widget.favorites.any((song) => song['title'] == widget.song['title']);
  }

  void _togglePlayPause() {
    if (_player.playing) {
      _player.pause();
      setState(() => isPlaying = false);
    } else {
      _player.play();
      setState(() => isPlaying = true);
    }
  }

  void _toggleLike() {
    widget.onLike(widget.song);
    setState(() {}); // بروزرسانی UI
  }

  Stream<DurationState> get _durationStateStream =>
      Rx.combineLatest2<Duration, void, DurationState>(
        _player.positionStream,
        Stream.periodic(const Duration(milliseconds: 500)),
            (position, _) => DurationState(position, _player.duration ?? Duration.zero),
      );

  final Color backgroundColor = const Color(0xFF1E1E1E);
  final Color accentColor = const Color(0xFF00E5FF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        foregroundColor: accentColor,
        elevation: 0,
        title: Text(
          widget.song['title']!,
          style: TextStyle(color: accentColor, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isLiked ? Icons.favorite : Icons.favorite_border,
              color: isLiked ? Colors.red : Colors.white,
            ),
            tooltip: "Like",
            onPressed: _toggleLike,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(widget.song['cover']!, height: 250),
            ),
            const SizedBox(height: 20),
            Text(
              widget.song['artist']!,
              style: const TextStyle(fontSize: 22, color: Colors.white),
            ),
            const SizedBox(height: 30),
            StreamBuilder<DurationState>(
              stream: _durationStateStream,
              builder: (context, snapshot) {
                final durationState = snapshot.data;
                final progress = durationState?.position ?? Duration.zero;
                final total = durationState?.total ?? Duration.zero;

                return Column(
                  children: [
                    Slider(
                      activeColor: accentColor,
                      inactiveColor: Colors.grey[700],
                      min: 0.0,
                      max: total.inMilliseconds.toDouble(),
                      value: progress.inMilliseconds.toDouble().clamp(0.0, total.inMilliseconds.toDouble()),
                      onChanged: (value) {
                        _player.seek(Duration(milliseconds: value.toInt()));
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_formatDuration(progress), style: const TextStyle(color: Colors.white70)),
                        Text(_formatDuration(total - progress), style: const TextStyle(color: Colors.white70)),
                      ],
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.skip_previous),
                  color: Colors.white,
                  iconSize: 36,
                  onPressed: () => _player.seek(Duration.zero),
                ),
                IconButton(
                  icon: Icon(
                    isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
                    color: accentColor,
                  ),
                  iconSize: 64,
                  onPressed: _togglePlayPause,
                ),
                IconButton(
                  icon: const Icon(Icons.skip_next),
                  color: Colors.white,
                  iconSize: 36,
                  onPressed: () => _player.seek(_player.duration ?? Duration.zero),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextButton.icon(
              onPressed: _toggleLike,
              icon: Icon(
                isLiked ? Icons.favorite : Icons.favorite_border,
                color: isLiked ? Colors.red : Colors.grey,
              ),
              label: Text(
                isLiked ? "Liked" : "Like",
                style: TextStyle(color: isLiked ? Colors.red : Colors.white),
              ),
              style: TextButton.styleFrom(
                backgroundColor: backgroundColor.withOpacity(0.3),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}

class DurationState {
  final Duration position;
  final Duration total;

  DurationState(this.position, this.total);
}