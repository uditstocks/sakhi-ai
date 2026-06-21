/// Abstract audio player interface with conditional platform imports.
///
/// Uses Dart's conditional import mechanism to select the correct
/// platform-specific implementation at compile time:
/// - Web: [audio_player_service_web.dart] (HTML AudioElement + Blob URLs)
/// - Native (mobile/desktop): [audio_player_service_native.dart] (just_audio)
/// - Unsupported platforms: [audio_player_service_stub.dart] (throws)
library;

import 'package:sakhi_ai/services/audio_player_service_stub.dart'
    if (dart.library.js_interop) 'package:sakhi_ai/services/audio_player_service_web.dart'
    if (dart.library.io) 'package:sakhi_ai/services/audio_player_service_native.dart';

/// Abstract interface for playing audio bytes across platforms.
///
/// Obtain an instance via the default constructor, which delegates to
/// the platform-specific factory function. Supports playing raw audio
/// bytes, stopping playback, and disposing resources.
abstract class SakhiAudioPlayer {
  /// Creates a platform-specific audio player instance.
  ///
  /// Delegates to [getAudioPlayerInstance] which is resolved at compile
  /// time via conditional imports.
  factory SakhiAudioPlayer() => getAudioPlayerInstance();

  /// Plays the given audio [bytes] (expected to be MP3-encoded).
  Future<void> playBytes(List<int> bytes);

  /// Stops the current audio playback immediately.
  Future<void> stop();

  /// Releases all audio resources held by this player.
  void dispose();
}
