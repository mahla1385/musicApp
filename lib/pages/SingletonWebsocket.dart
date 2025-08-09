import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

class MusicWebSocketClient {
  static final MusicWebSocketClient _instance = MusicWebSocketClient._internal();

  factory MusicWebSocketClient() => _instance;

  late final WebSocketChannel channel;
  void Function(Map<String, dynamic>)? _onData;

  MusicWebSocketClient._internal() {
    channel = WebSocketChannel.connect(Uri.parse('ws://192.168.1.3:8080/ws'));

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
      onError: (error) => print('❌ WebSocket error: $error'),
      onDone: () => print('ℹ️ WebSocket connection closed.'),
    );
  }

  void setOnData(void Function(Map<String, dynamic>) handler) {
    _onData = handler;
  }

  void send(Map<String, dynamic> message) {
    try {
      channel.sink.add(jsonEncode(message));
    } catch (e) {
      print("❗ WebSocket send error: $e");
    }
  }

  void dispose() {
    channel.sink.close();
  }

  // متد لاگین با callback نتیجه
  void login({
    required String username,
    required String email,
    required String password,
    required void Function(bool success, Map<String, dynamic>? data, String? message) onResult,
  }) {
    final loginRequest = {
      "action": "login",
      "username": username,
      "email": email,
      "password": password,
    };

    send(loginRequest);

    void handler(Map<String, dynamic> response) {
      if (response["action"] == "login_response") {
        final success = response["status"] == "success";
        final message = response["message"];
        final data = success ? response["data"] : null;

        onResult(success, data, message);

        _onData = null;
      }
    }

    setOnData(handler);
  }

  // متد ساین آپ
  void signup({
    required String username,
    required String email,
    required String password,
    required void Function(bool success, String? message) onResult,
  }) {
    final signupRequest = {
      "action": "signup",
      "username": username,
      "email": email,
      "password": password,
    };

    send(signupRequest);

    void handler(Map<String, dynamic> response) {
      if (response["action"] == "signup_response") {
        final success = response["status"] == "success";
        final message = response["message"];

        onResult(success, message);

        _onData = null;
      }
    }

    setOnData(handler);
  }

  // متد تغییر رمز
  void resetPassword({
    required String email,
    required String newPassword,
    required void Function(bool success, String? message) onResult,
  }) {
    final resetRequest = {
      "action": "reset_password",
      "email": email,
      "newPassword": newPassword,
    };

    send(resetRequest);

    void handler(Map<String, dynamic> response) {
      if (response["action"] == "reset_password_response") {
        final success = response["status"] == "success";
        final message = response["message"];

        onResult(success, message);

        _onData = null;
      }
    }

    setOnData(handler);
  }

  // متدهای کامنت

  void sendComment({
    required int userId,
    required int songId,
    required String username,
    required String content,
  }) {
    final msg = {
      "action": "add_comment",
      "userId": userId,
      "songId": songId,
      "username": username,
      "content": content,
    };
    send(msg);
  }

  void getComments(int songId) {
    final msg = {
      "action": "get_comments",
      "songId": songId,
    };
    send(msg);
  }

  void deleteComment({
    required int commentId,
    required int songId,
  }) {
    final msg = {
      "action": "delete_comment",
      "commentId": commentId,
      "songId": songId,
    };
    send(msg);
  }

  // متد لایک و دیس‌لایک (مثال)
  void toggleLike({
    required int userId,
    required int songId,
    required String type, // "like" or "dislike"
  }) {
    final msg = {
      "action": "toggle_like",
      "userId": userId,
      "songId": songId,
      "type": type,
    };
    send(msg);
  }

  // متد دریافت تعداد لایک‌ها
  void getLikeCount(int songId) {
    final msg = {
      "action": "get_likes_count",
      "songId": songId,
    };
    send(msg);
  }

  // متد گوش دادن به پیام‌ها (برای استفاده ساده‌تر)
  void listen(void Function(Map<String, dynamic>) handler) {
    setOnData(handler);
  }
}