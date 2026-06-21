/// Web audio player implementation using HTML AudioElement and Blob URLs.
///
/// Converts raw audio bytes into a [Blob], creates an object URL via
/// [URL.createObjectURL], and plays it through an [HTMLAudioElement].
/// Only one audio element is active at a time; calling [playBytes]
/// stops any currently playing audio first.
library;

import 'dart:js_interop';
import 'dart:typed_data';
import 'package:web/web.dart' as web;
import 'package:sakhi_ai/services/audio_player_service.dart';

/// Factory function returning a web audio player instance.
///
/// Called by the conditional import in [audio_player_service.dart]
/// when `dart:js_interop` is available (web platform).
SakhiAudioPlayer getAudioPlayerInstance() => SakhiAudioPlayerWeb();

/// Web audio player backed by an HTML `<audio>` element.
///
/// Creates a Blob URL from raw audio bytes and plays it through
/// the browser's built-in audio element. Tracks the current audio
/// element to support stopping and disposal.
class SakhiAudioPlayerWeb implements SakhiAudioPlayer {
  /// The currently active audio element, or `null` if not playing.
  web.HTMLAudioElement? _currentAudio;

  /// Plays the given audio [bytes] in the browser.
  ///
  /// Converts [bytes] to a [Uint8List], wraps it in a [Blob], generates
  /// an object URL, and assigns it to a new [HTMLAudioElement]. Stops
  /// any previously playing audio before starting. Catches and prints
  /// errors without rethrowing.
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

  /// Stops the currently playing audio, if any.
  ///
  /// Pauses the active [HTMLAudioElement] and clears the reference.
  /// Silently catches any errors during stop.
  @override
  Future<void> stop() async {
    try {
      if (_currentAudio != null) {
        _currentAudio!.pause();
        _currentAudio = null;
      }
    } catch (_) {}
  }

  /// Disposes the audio player by stopping any active playback.
  @override
  void dispose() {
    stop();
  }
}
