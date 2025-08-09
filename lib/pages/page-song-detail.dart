import 'dart:io';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:rxdart/rxdart.dart';
import 'audio_player_singleton.dart';
import 'SingletonWebsocket.dart';
import 'package:path_provider/path_provider.dart';
import '../utils/user_session.dart';

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
  final ws = MusicWebSocketClient();
  final TextEditingController _commentController = TextEditingController();
  List<Map<String, dynamic>> _comments = [];
  int _likes = 0;
  int _dislikes = 0;

  Map<int, String> _profilePaths = {}; // userId -> profile image path cache

  @override
  void initState() {
    super.initState();
    _player = GlobalAudioPlayer.instance;
    _init();

    ws.listen((message) {
      final action = message['action'];
      if (action == 'get_comments_response' && message['songId'] == widget.song['id']) {
        List<Map<String, dynamic>> comments = List<Map<String, dynamic>>.from(message['comments']);
        setState(() {
          _comments = comments;
        });
        _cacheProfilePaths(comments);
      } else if (action == 'comment_added' && message['songId'] == widget.song['id']) {
        ws.getComments(widget.song['id']);
      } else if (action == 'likes_count' && message['songId'] == widget.song['id']) {
        setState(() {
          _likes = message['likes'] ?? 0;
          _dislikes = message['dislikes'] ?? 0;
        });
      }
    });

    ws.getComments(widget.song['id']);
    ws.getLikeCount(widget.song['id']);

    _player.playerStateStream.listen((s) {
      setState(() => _isPlaying = s.playing);
    });
  }

  Future<void> _cacheProfilePaths(List<Map<String, dynamic>> comments) async {
    final dir = await getApplicationDocumentsDirectory();

    Map<int, String> newPaths = {};

    for (var c in comments) {
      int? userId = c['userId'];
      if (userId != null) {
        final path = '${dir.path}/profile_$userId.png';
        final file = File(path);
        if (await file.exists()) {
          newPaths[userId] = path;
        }
      }
    }
    setState(() {
      _profilePaths = newPaths;
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
    _commentController.dispose();
    super.dispose();
  }

  bool get isLiked => widget.favorites.any((song) => song['id'] == widget.song['id']);

  void _togglePlayPause() => _player.playing ? _player.pause() : _player.play();

  void _toggleLike() {
    widget.onLike(widget.song);
    setState(() {});
  }

  void _sendComment() {
    final text = _commentController.text.trim();
    final userId = UserSession.userId;
    final username = UserSession.username;
    if (text.isNotEmpty && userId != null && username != null) {
      ws.sendComment(
        userId: userId,
        songId: widget.song['id'],
        content: text,
        username: username,
      );
      _commentController.clear();
      Future.delayed(const Duration(milliseconds: 300), () => ws.getComments(widget.song['id']));
    }
  }

  void _deleteComment(int commentId) {
    ws.deleteComment(commentId: commentId, songId: widget.song['id']);
  }

  void _confirmDelete(int commentId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Comment"),
        content: const Text("Are you sure you want to delete this comment?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("No"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _deleteComment(commentId);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text("Yes"),
          ),
        ],
      ),
    );
  }

  void _sendLike(bool like) {
    final userId = UserSession.userId;
    if (userId == null) return;
    ws.toggleLike(userId: userId, songId: widget.song['id'], type: like ? "like" : "dislike");
  }

  Stream<DurationState> get _durationStateStream => Rx.combineLatest2(
    _player.positionStream,
    _player.durationStream,
        (Duration pos, Duration? total) => DurationState(pos, total ?? Duration.zero),
  );

  String _formatDuration(Duration d) => "${d.inMinutes.remainder(60).toString().padLeft(2, '0')}:${d.inSeconds.remainder(60).toString().padLeft(2, '0')}";

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFF1E1E1E);
    const accent = Color(0xFF00E5FF);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        foregroundColor: accent,
        elevation: 0,
        title: Text(widget.song['title'] ?? '', style: const TextStyle(color: accent, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(isLiked ? Icons.favorite : Icons.favorite_border, color: isLiked ? Colors.red : accent),
            onPressed: _toggleLike,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          QueryArtworkWidget(
            id: widget.song['id'] ?? 0,
            type: ArtworkType.AUDIO,
            nullArtworkWidget: const Icon(Icons.music_note, color: accent, size: 120),
            artworkBorder: BorderRadius.circular(20),
            artworkHeight: 180,
            artworkWidth: 180,
          ),
          const SizedBox(height: 12),
          Text(widget.song['artist'] ?? "Unknown Artist", textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 10),
          StreamBuilder<DurationState>(
            stream: _durationStateStream,
            builder: (_, snap) {
              final d = snap.data ?? DurationState(Duration.zero, Duration.zero);
              return Column(
                children: [
                  Slider(
                    min: 0,
                    max: d.total.inMilliseconds.toDouble(),
                    value: d.position.inMilliseconds.clamp(0, d.total.inMilliseconds).toDouble(),
                    onChanged: (v) => _player.seek(Duration(milliseconds: v.toInt())),
                    activeColor: accent,
                    inactiveColor: Colors.grey,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_formatDuration(d.position), style: const TextStyle(color: Colors.white70)),
                      Text(_formatDuration(d.total), style: const TextStyle(color: Colors.white70)),
                    ],
                  ),
                ],
              );
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(icon: const Icon(Icons.replay_10, color: Colors.white), onPressed: () => _player.seek(_player.position - const Duration(seconds: 10))),
              CircleAvatar(
                backgroundColor: accent,
                radius: 28,
                child: IconButton(
                  icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow, color: bg, size: 28),
                  onPressed: _togglePlayPause,
                ),
              ),
              IconButton(icon: const Icon(Icons.forward_10, color: Colors.white), onPressed: () => _player.seek(_player.position + const Duration(seconds: 10))),
            ],
          ),
          const Divider(color: Colors.white24, height: 32),
          const Text('Write a Comment', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          TextField(
            controller: _commentController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Write a comment...',
              hintStyle: const TextStyle(color: Colors.white54),
              suffixIcon: IconButton(
                icon: const Icon(Icons.send, color: accent),
                onPressed: _sendComment,
              ),
              filled: true,
              fillColor: Colors.white10,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Comments:', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (_comments.isEmpty)
            const Text('No comments yet.', style: TextStyle(color: Colors.white54))
          else
            ..._comments.map((c) {
              final userId = c['userId'] as int?;
              final profilePath = userId != null ? _profilePaths[userId] : null;
              final profileImageFile = profilePath != null ? File(profilePath) : null;

              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: profileImageFile != null ? FileImage(profileImageFile) : null,
                  child: profileImageFile == null ? const Icon(Icons.person, color: Colors.white) : null,
                  backgroundColor: Colors.grey[700],
                ),
                title: Text('${c['username'] ?? 'User'}: ${c['content']}', style: const TextStyle(color: Colors.white)),
                trailing: (UserSession.userId == userId)
                    ? IconButton(
                  icon: const Icon(Icons.delete, color: Colors.greenAccent),
                  onPressed: () => _confirmDelete(c['id']),
                )
                    : null,
              );
            }),
        ],
      ),
    );
  }
}

class DurationState {
  final Duration position;
  final Duration total;
  DurationState(this.position, this.total);
}