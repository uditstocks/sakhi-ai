/// Native (mobile/desktop) audio player implementation.
///
/// Uses the `just_audio` package to play MP3 audio. Writes incoming
/// audio bytes to a temporary file before playback, since `just_audio`
/// requires a file path or URI on native platforms.
library;

import 'dart:io';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sakhi_ai/services/audio_player_service.dart';

/// Factory function returning a native audio player instance.
///
/// Called by the conditional import in [audio_player_service.dart]
/// when `dart:io` is available.
SakhiAudioPlayer getAudioPlayerInstance() => SakhiAudioPlayerNative();

/// Native audio player backed by the `just_audio` package.
///
/// Writes audio bytes to a uniquely-named temporary file, then plays
/// it via [AudioPlayer.setFilePath]. Each call to [playBytes] creates
/// a new temp file to avoid conflicts with concurrent writes.
class SakhiAudioPlayerNative implements SakhiAudioPlayer {
  final AudioPlayer _player = AudioPlayer();

  /// Plays the given audio [bytes] by writing them to a temp file.
  ///
  /// The temp file is named with a timestamp to ensure uniqueness.
  /// Catches and prints any errors without rethrowing.
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

  /// Stops the current audio playback.
  @override
  Future<void> stop() async {
    await _player.stop();
  }

  /// Disposes the underlying [AudioPlayer] and releases native resources.
  @override
  void dispose() {
    _player.dispose();
  }
}
