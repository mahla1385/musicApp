import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:rxdart/rxdart.dart';
import 'audio_player_singleton.dart';

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
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _player = GlobalAudioPlayer.instance;
    _init();
    _player.playerStateStream.listen((state) {
      setState(() {
        _isPlaying = state.playing;
      });
    });
  }

  Future<void> _init() async {
    final uri = widget.song['uri'] ?? widget.song['file'] ?? widget.song['data'];
    if (uri != null && uri.toString().isNotEmpty) {
      if (_player.audioSource == null ||
          (_player.audioSource is ProgressiveAudioSource &&
              (_player.audioSource as ProgressiveAudioSource).uri.toString() != uri.toString())) {
        await _player.setUrl(uri);
      }
      _player.play();
    }
  }

  @override
  void dispose() {
    // نباید _player را dispose کنی که آهنگ قطع نشود!
    super.dispose();
  }

  bool get isLiked {
    return widget.favorites.any((song) => song['id'] == widget.song['id']);
  }

  void _togglePlayPause() {
    if (_player.playing) {
      _player.pause();
    } else {
      _player.play();
    }
  }

  void _toggleLike() {
    widget.onLike(widget.song);
    setState(() {});
  }

  Stream<DurationState> get _durationStateStream =>
      Rx.combineLatest2<Duration, Duration?, DurationState>(
        _player.positionStream,
        _player.durationStream,
            (position, duration) => DurationState(
          position,
          duration ?? Duration.zero,
        ),
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
          widget.song['title'] ?? "",
          style: TextStyle(color: accentColor, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isLiked ? Icons.favorite : Icons.favorite_border,
              color: isLiked ? Colors.red : accentColor,
            ),
            onPressed: _toggleLike,
            tooltip: "Like",
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            QueryArtworkWidget(
              id: widget.song['id'] ?? 0,
              type: ArtworkType.AUDIO,
              nullArtworkWidget: Icon(Icons.music_note, color: accentColor, size: 120),
              artworkBorder: BorderRadius.circular(20),
              artworkHeight: 180,
              artworkWidth: 180,
            ),
            const SizedBox(height: 24),
            Text(
              widget.song['artist'] ?? "Unknown Artist",
              style: const TextStyle(color: Colors.white70, fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            StreamBuilder<DurationState>(
              stream: _durationStateStream,
              builder: (context, snapshot) {
                final durationState = snapshot.data ??
                    DurationState(const Duration(seconds: 0), const Duration(seconds: 0));
                final position = durationState.position;
                final total = durationState.total;
                return Column(
                  children: [
                    Slider(
                      activeColor: accentColor,
                      inactiveColor: Colors.cyan[100],
                      min: 0,
                      max: total.inMilliseconds.toDouble(),
                      value: position.inMilliseconds.clamp(0, total.inMilliseconds).toDouble(),
                      onChanged: (value) {
                        _player.seek(Duration(milliseconds: value.toInt()));
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_formatDuration(position), style: TextStyle(color: Colors.white70)),
                        Text(_formatDuration(total), style: TextStyle(color: Colors.white70)),
                      ],
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.replay_10, color: Colors.white),
                  iconSize: 40,
                  onPressed: () {
                    final newPosition = _player.position - const Duration(seconds: 10);
                    _player.seek(newPosition > Duration.zero ? newPosition : Duration.zero);
                  },
                ),
                const SizedBox(width: 16),
                CircleAvatar(
                  radius: 34,
                  backgroundColor: accentColor,
                  child: IconButton(
                    icon: Icon(
                      _isPlaying ? Icons.pause : Icons.play_arrow,
                      color: backgroundColor,
                      size: 40,
                    ),
                    onPressed: _togglePlayPause,
                  ),
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.forward_10, color: Colors.white),
                  iconSize: 40,
                  onPressed: () async {
                    final total = await _player.duration ?? Duration.zero;
                    final newPosition = _player.position + const Duration(seconds: 10);
                    _player.seek(newPosition < total ? newPosition : total);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }
}

class DurationState {
  final Duration position;
  final Duration total;

  DurationState(this.position, this.total);
}