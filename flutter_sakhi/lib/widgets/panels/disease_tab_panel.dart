import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sakhi_ai/l10n/app_strings.dart';
import 'package:sakhi_ai/services/sakhi_api_service.dart';
import 'package:sakhi_ai/theme/sakhi_colors.dart';
import 'package:sakhi_ai/theme/sakhi_theme.dart';

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

class _DiseaseTabPanelState extends State<DiseaseTabPanel> {
  final _picker = ImagePicker();
  XFile? _image;
  bool _uploading = false;

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

  Future<void> _analyzeImage(XFile file) async {
    setState(() => _uploading = true);
    try {
      final bytes = await file.readAsBytes();
      final base64 = base64Encode(bytes);
      final result = await widget.api.diagnoseCrop(
        description: 'crop leaf photo',
        imageBase64: base64,
      );
      if (!mounted) return;
      final diagnosis = result['diagnosis'] ?? result['reply'] ?? 'Analysis sent';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(diagnosis.toString()), behavior: SnackBarBehavior.floating),
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Photo saved — connect backend for diagnosis'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

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
                const Text('🌿', style: TextStyle(fontSize: 56)),
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
              style: SakhiTheme.poppins(fontSize: 15, color: SakhiColors.cream),
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
                icon: const Icon(Icons.camera_alt_rounded, size: 22),
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
