import 'dart:js_interop';
import 'dart:typed_data';
import 'package:web/web.dart' as web;
import 'package:sakhi_ai/services/audio_player_service.dart';

SakhiAudioPlayer getAudioPlayerInstance() => SakhiAudioPlayerWeb();

class SakhiAudioPlayerWeb implements SakhiAudioPlayer {
  web.HTMLAudioElement? _currentAudio;

  @override
  Future<void> playBytes(List<int> bytes) async {
    try {
      await stop();
      final uint8list = Uint8List.fromList(bytes);
      final jsArray = [uint8list.toJS].toJS;
      final blob = web.Blob(jsArray);
      final url = web.URL.createObjectURL(blob);
      final audio = web.HTMLAudioElement()..src = url;
      _currentAudio = audio;
      audio.play();
    } catch (e) {
      print('Web Audio play error: $e');
    }
  }

  @override
  Future<void> stop() async {
    try {
      if (_currentAudio != null) {
        _currentAudio!.pause();
        _currentAudio = null;
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    stop();
  }
}
