/// Crop disease detection tab panel.
///
/// Allows the user to capture a leaf image with the device camera, sends it
/// to the backend for AI-powered diagnosis, and plays the audio response.
library;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sakhi_ai/l10n/app_strings.dart';
import 'package:sakhi_ai/services/sakhi_api_service.dart';
import 'package:sakhi_ai/services/audio_player_service.dart';
import 'package:sakhi_ai/theme/sakhi_colors.dart';
import 'package:sakhi_ai/theme/sakhi_theme.dart';

/// Stateful widget for the crop disease detection panel.
///
/// Provides a camera button to capture a leaf photo, uploads it to the backend
/// for AI diagnosis, and plays back the spoken response through the audio
/// player service.
class DiseaseTabPanel extends StatefulWidget {
  const DiseaseTabPanel({
    super.key,
    required this.strings,
    required this.api,
  });

  final AppStrings strings;
  final SakhiApiService api;

  @override
  State<DiseaseTabPanel> createState() => _DiseaseTabPanelState();
}

/// State for [DiseaseTabPanel].
///
/// Manages the captured image, upload progress, and audio playback lifecycle.
class _DiseaseTabPanelState extends State<DiseaseTabPanel> {
  final _picker = ImagePicker();
  final SakhiAudioPlayer _player = SakhiAudioPlayer();

  XFile? _image;
  bool _uploading = false;

  /// Releases the audio player resources when the widget is disposed.
  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  /// Opens the device camera and lets the user capture a leaf photo.
  ///
  /// The captured image is stored in [_image] and immediately sent for
  /// AI diagnosis via [_analyzeImage].
  Future<void> _pickFromCamera() async {
    final file = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1280,
      imageQuality: 75,
    );

    if (file == null || !mounted) return;

    setState(() => _image = file);

    await _analyzeImage(file);
  }

  /// Sends the captured leaf image to the backend for AI disease diagnosis.
  ///
  /// Displays a loading indicator during upload. On success, plays the
  /// returned audio bytes through [SakhiAudioPlayer]. On failure, shows a
  /// snackbar with an error message.
  Future<void> _analyzeImage(XFile file) async {
    setState(() => _uploading = true);

    try {
      // Send image to backend
      final audioBytes = await widget.api.diagnoseCropImage(
        imageFile: File(file.path),
        languageCode: 'hi',
      );

      if (!mounted) return;

      if (audioBytes != null && audioBytes.isNotEmpty) {
        await _player.playBytes(audioBytes);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No response from backend'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      print('Diagnose error: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Backend se connect nahi hua. Try again.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _uploading = false);
      }
    }
  }

  /// Builds the disease panel UI: a card with a leaf emoji, camera button,
  /// title, hint text, captured image preview, and a "Take Photo" button.
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: SakhiColors.cardGreen,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.22),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                const Text(
                  '🌿',
                  style: TextStyle(fontSize: 56),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Material(
                    color: SakhiColors.gold,
                    shape: const CircleBorder(),
                    elevation: 4,
                    child: InkWell(
                      onTap: _uploading ? null : _pickFromCamera,
                      customBorder: const CircleBorder(),
                      child: SizedBox(
                        width: 44,
                        height: 44,
                        child: _uploading
                            ? const Padding(
                                padding: EdgeInsets.all(10),
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: SakhiColors.deepGreen,
                                ),
                              )
                            : const Icon(
                                Icons.camera_alt_rounded,
                                size: 22,
                                color: SakhiColors.deepGreen,
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              widget.strings.diseaseTitle,
              style: SakhiTheme.hind(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: SakhiColors.cream,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              'Crop Disease',
              style: SakhiTheme.poppins(
                fontSize: 15,
                color: SakhiColors.cream,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.strings.diseaseHint,
              style: SakhiTheme.hind(
                fontSize: 17,
                color: SakhiColors.creamMuted,
              ),
              textAlign: TextAlign.center,
            ),
            if (_image != null) ...[
              const SizedBox(height: 20),
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(
                  File(_image!.path),
                  height: 140,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton.icon(
                onPressed: _uploading ? null : _pickFromCamera,
                style: FilledButton.styleFrom(
                  backgroundColor: SakhiColors.gold,
                  foregroundColor: SakhiColors.deepGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(
                  Icons.camera_alt_rounded,
                  size: 22,
                ),
                label: Text(
                  widget.strings.takePhoto,
                  style: SakhiTheme.hind(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: SakhiColors.deepGreen,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}