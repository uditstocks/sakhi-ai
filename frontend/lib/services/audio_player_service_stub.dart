/// Stub audio player implementation for unsupported platforms.
///
/// Throws [UnsupportedError] when neither `dart:html` nor `dart:io`
/// is available, ensuring a clear failure message instead of a
/// compile-time error.
library;

import 'package:sakhi_ai/services/audio_player_service.dart';

/// Factory function that always throws [UnsupportedError].
///
/// Called by the conditional import in [audio_player_service.dart]
/// when no platform-specific implementation is available.
SakhiAudioPlayer getAudioPlayerInstance() => throw UnsupportedError(
    'Cannot create an audio player without dart:html or dart:io.');
