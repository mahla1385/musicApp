import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';

class SongDetailPage extends StatefulWidget {
  final Map<String, dynamic> song;

  const SongDetailPage({Key? key, required this.song}) : super(key: key);

  @override
  State<SongDetailPage> createState() => _SongDetailPageState();
}

class _SongDetailPageState extends State<SongDetailPage> {
  late AudioPlayer _player;
  bool isPlaying = false;

  final Color backgroundColor = const Color(0xFF1E1E1E); // طوسی تیره
  final Color accentColor = const Color(0xFF00E5FF);     // آبی فیروزه‌ای

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _init();
  }

  Future<void> _init() async {
    try {
      await _player.setAsset(widget.song['file']!);
    } catch (e) {
      print("Error loading audio source: $e");
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
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

  Stream<DurationState> get _durationStateStream =>
      Rx.combineLatest2<Duration, void, DurationState>(
        _player.positionStream,
        Stream.periodic(const Duration(milliseconds: 500)),
            (position, _) => DurationState(position, _player.duration ?? Duration.zero),
      );

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
