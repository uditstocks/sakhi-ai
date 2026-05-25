import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:sakhi_ai/l10n/app_language.dart';
import 'package:sakhi_ai/l10n/app_strings.dart';
import 'package:sakhi_ai/services/sakhi_api_service.dart';
import 'package:sakhi_ai/services/audio_player_service.dart';
import 'package:sakhi_ai/widgets/crop_field_background.dart';
import 'package:sakhi_ai/widgets/hero_mic_section.dart';
import 'package:sakhi_ai/widgets/language_picker_overlay.dart';
import 'package:sakhi_ai/widgets/panels/disease_tab_panel.dart';
import 'package:sakhi_ai/widgets/panels/mandi_tab_panel.dart';
import 'package:sakhi_ai/widgets/panels/schemes_tab_panel.dart';
import 'package:sakhi_ai/widgets/panels/sos_tab_panel.dart';
import 'package:sakhi_ai/widgets/sakhi_bottom_nav.dart';
import 'package:sakhi_ai/widgets/sync_status_bar.dart';
import 'package:sakhi_ai/widgets/top_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.apiService});
  final SakhiApiService? apiService;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final SakhiApiService _api;

  // ── State ──────────────────────────────────────────────────────
  AppLanguage _language = AppLanguage.hindi;
  SakhiNavTab _navTab = SakhiNavTab.home;
  bool _isListening = false;
  bool _isLoading = false;
  String _lastSynced = '2 mins ago';
  String _statusMessage = '';

  // ── Audio tools ────────────────────────────────────────────────
  final AudioRecorder _recorder = AudioRecorder();
  final SakhiAudioPlayer _player = SakhiAudioPlayer();

  AppStrings get _strings => AppStrings(_language);

  // ── Lifecycle ──────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _api = widget.apiService ?? SakhiApiService();
    _refreshSyncLabel();
  }

  @override
  void dispose() {
    _recorder.dispose();
    _player.dispose();
    if (widget.apiService == null) _api.dispose();
    super.dispose();
  }

  // ── Sync label ─────────────────────────────────────────────────

  Future<void> _refreshSyncLabel() async {
    try {
      final status = await _api.fetchSyncStatus();
      final ago = status['last_sync_ago'] as String?;
      if (ago != null && mounted) {
        setState(() => _lastSynced = ago);
      }
    } catch (_) {}
  }

  // ── Language picker ────────────────────────────────────────────

  Future<void> _openLanguagePicker() async {
    final selected = await showLanguagePicker(context, current: _language);
    if (selected != null && selected != _language && mounted) {
      setState(() => _language = selected);
    }
  }

  // ── Mic tap ────────────────────────────────────────────────────

  Future<void> _onMicTap() async {
    if (_isLoading) return;
    if (_isListening) {
      await _stopRecordingAndSend();
    } else {
      await _startRecording();
    }
  }

  Future<void> _startRecording() async {
    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) {
      _setStatus('Microphone permission required');
      return;
    }

    String path = '';
    if (!kIsWeb) {
      final dir = await getTemporaryDirectory();
      path = '${dir.path}/sakhi_${DateTime.now().millisecondsSinceEpoch}.m4a';
    }

    await _recorder.start(
      const RecordConfig(encoder: AudioEncoder.aacLc),
      path: path,
    );

    if (mounted) {
      setState(() {
        _isListening = true;
        _statusMessage = 'Sun rahi hoon...';
      });
    }
  }

  Future<void> _stopRecordingAndSend() async {
    final path = await _recorder.stop();
    if (mounted) {
      setState(() {
        _isListening = false;
        _isLoading = true;
        _statusMessage = 'Soch rahi hoon...';
      });
    }

    if (path == null) {
      _setStatus('Recording failed. Try again.');
      setState(() => _isLoading = false);
      return;
    }

    try {
      final VoiceApiResult result;

      if (kIsWeb) {
        final response = await http.get(Uri.parse(path));
        result = await _api.sendVoiceBytes(
          audioBytes: response.bodyBytes,
          languageCode: _language.code,
        );
      } else {
        result = await _api.sendVoiceFile(
          audioFile: File(path),
          languageCode: _language.code,
        );
      }

      final audioBytes = result.audioBytes;
      if (audioBytes != null && audioBytes.isNotEmpty) {
        await _player.playBytes(audioBytes);
        _setStatus('');
      } else if (result.isNetworkError) {
        _setStatus('Internet nahi hai. Baad mein try karein.');
      } else if (result.isTranscriptionFailed) {
        _setStatus('Awaaz sunai nahi di. 2-3 second bol kar dubara try karein.');
      } else {
        _setStatus('Jawab nahi mila. Backend check karein.');
      }
    } catch (e) {
      print('Voice send error: $e');
      _setStatus('Internet nahi hai. Baad mein try karein.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _setStatus(String msg) {
    if (mounted) setState(() => _statusMessage = msg);
  }

  void _goHomeAndSpeak() {
    setState(() {
      _navTab = SakhiNavTab.home;
      _isListening = false;
    });
    _onMicTap();
  }

  // ── Main content switcher ──────────────────────────────────────

  Widget _buildMainContent() {
    return switch (_navTab) {
      SakhiNavTab.home => LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      HeroMicSection(
                        strings: _strings,
                        isListening: _isListening,
                        onMicTap: _onMicTap,
                      ),
                      if (_isLoading) ...[
                        const SizedBox(height: 16),
                        const CircularProgressIndicator(),
                      ],
                      if (_statusMessage.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                            _statusMessage,
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Colors.white70,
                                  fontSize: 16,
                                ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      SakhiNavTab.mandi => MandiTabPanel(
          strings: _strings,
          onVoiceTap: _goHomeAndSpeak,
        ),
      SakhiNavTab.disease => DiseaseTabPanel(
          strings: _strings,
          api: _api,
        ),
      SakhiNavTab.schemes => SchemesTabPanel(
          strings: _strings,
          api: _api,
          language: _language,
        ),
      SakhiNavTab.sos => SosTabPanel(strings: _strings),
    };
  }

  // ── Build ──────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CropFieldBackground(
        child: SafeArea(
          child: Column(
            children: [
              SakhiTopBar(
                strings: _strings,
                language: _language,
                onLanguageTap: _openLanguagePicker,
              ),
              Expanded(child: _buildMainContent()),
              if (_navTab == SakhiNavTab.home) ...[
                const SizedBox(height: 20),
                SyncStatusBar(
                  strings: _strings,
                  lastSyncedLabel: _lastSynced,
                ),
              ],
              SakhiBottomNav(
                strings: _strings,
                activeTab: _navTab,
                onTabSelected: (tab) => setState(() => _navTab = tab),
              ),
            ],
          ),
        ),
      ),
    );
  }
}