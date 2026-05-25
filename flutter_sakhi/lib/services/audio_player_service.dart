import 'package:sakhi_ai/services/audio_player_service_stub.dart'
    if (dart.library.js_interop) 'package:sakhi_ai/services/audio_player_service_web.dart'
    if (dart.library.io) 'package:sakhi_ai/services/audio_player_service_native.dart';

abstract class SakhiAudioPlayer {
  factory SakhiAudioPlayer() => getAudioPlayerInstance();

  Future<void> playBytes(List<int> bytes);
  Future<void> stop();
  void dispose();
}
