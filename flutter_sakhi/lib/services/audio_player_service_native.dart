import 'dart:io';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sakhi_ai/services/audio_player_service.dart';

SakhiAudioPlayer getAudioPlayerInstance() => SakhiAudioPlayerNative();

class SakhiAudioPlayerNative implements SakhiAudioPlayer {
  final AudioPlayer _player = AudioPlayer();

  @override
  Future<void> playBytes(List<int> bytes) async {
    try {
      final dir = await getTemporaryDirectory();
      final responseFile = File(
          '${dir.path}/sakhi_temp_play_${DateTime.now().millisecondsSinceEpoch}.mp3');
      await responseFile.writeAsBytes(bytes);
      await _player.setFilePath(responseFile.path);
      await _player.play();
    } catch (e) {
      print('Native Audio play error: $e');
    }
  }

  @override
  Future<void> stop() async {
    await _player.stop();
  }

  @override
  void dispose() {
    _player.dispose();
  }
}
