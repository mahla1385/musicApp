import 'package:just_audio/just_audio.dart';

class GlobalAudioPlayer {
  static final AudioPlayer _player = AudioPlayer();

  static AudioPlayer get instance => _player;
}