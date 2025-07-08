import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

class MusicWebSocketClient {
  final WebSocketChannel channel;
  void Function(Map<String, dynamic>)? _onData;

  MusicWebSocketClient(String uri)
      : channel = WebSocketChannel.connect(Uri.parse(uri)) {
    channel.stream.listen(
          (event) {
        try {
          final decoded = jsonDecode(event);
          if (decoded is Map<String, dynamic> && _onData != null) {
            _onData!(decoded);
          }
        } catch (e) {
          print("❗ WebSocket parsing error: $e");
        }
      },
      onError: (error) => print('WebSocket error: $error'),
      onDone: () => print('WebSocket connection closed.'),
    );
  }

  void listen(void Function(Map<String, dynamic>) onData) {
    _onData = onData;
  }

  void close() {
    channel.sink.close();
  }

  void send(Map<String, dynamic> message) {
    final jsonMessage = jsonEncode(message);
    channel.sink.add(jsonMessage);
  }

  void signup(String username, String email, String password) {
    send({
      "action": "signup",
      "username": username,
      "email": email,
      "password": password,
    });
  }

  void login(String username, String email, String password) {
    send({
      "action": "login",
      "username": username,
      "email": email,
      "password": password,
    });
  }

  void sendAccountStatus({
    required String username,
    required String email,
    required bool premium,
  }) {
    send({
      "action": "account_status",
      "username": username,
      "email": email,
      "premium": premium,
    });
  }

  void sendComment({
    required int userId,
    required int songId,
    required String content,
    required String username,
  }) {
    send({
      "action": "add_comment",
      "userId": userId,
      "songId": songId,
      "content": content,
      "username": username,
    });
  }

  void deleteComment({
    required int commentId,
    required int songId,
  }) {
    send({
      "action": "delete_comment",
      "commentId": commentId,
      "songId": songId,
    });
  }

  void getComments(int songId) {
    send({
      "action": "get_comments",
      "songId": songId,
    });
  }

  void toggleLike({
    required int userId,
    required int songId,
    required String type,
  }) {
    send({
      "action": "like_dislike",
      "userId": userId,
      "songId": songId,
      "type": type,
    });
  }

  void getLikeCount(int songId) {
    send({
      "action": "get_likes_count",
      "songId": songId,
    });
  }
}