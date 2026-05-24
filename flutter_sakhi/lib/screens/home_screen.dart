import 'package:flutter/material.dart';
import 'package:sakhi_ai/l10n/app_language.dart';
import 'package:sakhi_ai/l10n/app_strings.dart';
import 'package:sakhi_ai/services/sakhi_api_service.dart';
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
  AppLanguage _language = AppLanguage.hindi;
  SakhiNavTab _navTab = SakhiNavTab.home;
  bool _isListening = false;
  String _lastSynced = '2 mins ago';

  AppStrings get _strings => AppStrings(_language);

  @override
  void initState() {
    super.initState();
    _api = widget.apiService ?? SakhiApiService();
    _refreshSyncLabel();
  }

  @override
  void dispose() {
    if (widget.apiService == null) {
      _api.dispose();
    }
    super.dispose();
  }

  Future<void> _refreshSyncLabel() async {
    try {
      final status = await _api.fetchSyncStatus();
      final ago = status['last_sync_ago'] as String?;
      if (ago != null && mounted) {
        setState(() => _lastSynced = ago);
      }
    } catch (_) {}
  }

  Future<void> _openLanguagePicker() async {
    final selected = await showLanguagePicker(context, current: _language);
    if (selected != null && selected != _language) {
      setState(() => _language = selected);
    }
  }

  Future<void> _onMicTap() async {
    if (_isListening) {
      setState(() => _isListening = false);
      return;
    }

    setState(() => _isListening = true);

    try {
      await _api.sendVoiceQuery(
        languageCode: _language.code,
        transcript: null,
      );
    } catch (_) {}
  }

  void _goHomeAndSpeak() {
    setState(() {
      _navTab = SakhiNavTab.home;
      _isListening = false;
    });
    _onMicTap();
  }

  Widget _buildMainContent() {
    return switch (_navTab) {
      SakhiNavTab.home => LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Center(
                  child: HeroMicSection(
                    strings: _strings,
                    isListening: _isListening,
                    onMicTap: _onMicTap,
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
