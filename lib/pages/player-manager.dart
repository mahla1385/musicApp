import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class PlayerManager extends ChangeNotifier {
  final AudioPlayer player = AudioPlayer();

  Future<void> playSong(String url) async {
    await player.setUrl(url);
    player.play();
    notifyListeners();
  }

  void pause() {
    player.pause();
    notifyListeners();
  }

  void disposePlayer() {
    player.dispose();
    super.dispose();
  }
}