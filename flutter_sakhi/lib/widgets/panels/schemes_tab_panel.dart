/// Government schemes tab panel.
///
/// Fetches agricultural schemes from the backend API, displays them in a
/// scrollable list, and falls back to bundled demo data when offline.
import 'package:flutter/material.dart';
import 'package:sakhi_ai/data/demo_schemes.dart';
import 'package:sakhi_ai/l10n/app_language.dart';
import 'package:sakhi_ai/l10n/app_strings.dart';
import 'package:sakhi_ai/models/govt_scheme.dart';
import 'package:sakhi_ai/services/sakhi_api_service.dart';
import 'package:sakhi_ai/theme/sakhi_colors.dart';
import 'package:sakhi_ai/theme/sakhi_theme.dart';

/// Stateful widget that displays government agricultural schemes.
///
/// Provides a "Connect to Database" button to fetch live scheme data from the
/// backend. Shows a loading spinner during fetch and gracefully falls back to
/// [kDemoSchemes] when the backend is unreachable.
class SchemesTabPanel extends StatefulWidget {
  const SchemesTabPanel({
    super.key,
    required this.strings,
    required this.api,
    required this.language,
  });

  final AppStrings strings;
  final SakhiApiService api;
  final AppLanguage language;

  @override
  State<SchemesTabPanel> createState() => _SchemesTabPanelState();
}

/// State for [SchemesTabPanel].
///
/// Manages the list of schemes, loading flag, connection status, and
/// offline-fallback flag. Triggers a backend fetch on init.
class _SchemesTabPanelState extends State<SchemesTabPanel> {
  List<GovtScheme> _schemes = [];
  bool _loading = false;
  bool _connected = false;
  bool _usedOfflineFallback = false;

  @override
  void initState() {
    super.initState();
    _loadFromDatabase();
  }

  /// Fetches government schemes from the backend API.
  ///
  /// On success, parses the JSON response into [GovtScheme] objects and shows
  /// a snackbar confirming the connection. On failure, falls back to
  /// [kDemoSchemes] and marks the panel as offline.
  Future<void> _loadFromDatabase() async {
    setState(() => _loading = true);

    try {
      final raw = await widget.api.fetchGovtSchemes();
      final parsed = raw
          .whereType<Map<String, dynamic>>()
          .map(GovtScheme.fromJson)
          .toList();

      if (!mounted) return;
      setState(() {
        _connected = true;
        _usedOfflineFallback = false;
        _schemes = parsed.isNotEmpty ? parsed : kDemoSchemes;
        _loading = false;
      });

      if (parsed.isNotEmpty && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.strings.dbConnected),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _connected = false;
        _usedOfflineFallback = true;
        _schemes = kDemoSchemes;
        _loading = false;
      });
    }
  }

  /// Builds the schemes panel UI: a header card with the connect button,
  /// a connection-status indicator, and a list of scheme cards below.
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: SakhiColors.cardGreen,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                const Text('📋', style: TextStyle(fontSize: 48)),
                const SizedBox(height: 12),
                Text(
                  widget.strings.schemesTitle,
                  style: SakhiTheme.hind(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: SakhiColors.cream,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: FilledButton.icon(
                    onPressed: _loading ? null : _loadFromDatabase,
                    style: FilledButton.styleFrom(
                      backgroundColor: SakhiColors.gold,
                      foregroundColor: SakhiColors.deepGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: Icon(
                      _connected ? Icons.storage_rounded : Icons.cloud_sync_rounded,
                    ),
                    label: Text(
                      widget.strings.connectDatabase,
                      style: SakhiTheme.hind(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: SakhiColors.deepGreen,
                      ),
                    ),
                  ),
                ),
                if (_connected) ...[
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle, color: SakhiColors.gold, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        widget.strings.dbConnected,
                        style: SakhiTheme.poppins(
                          fontSize: 13,
                          color: SakhiColors.creamMuted,
                        ),
                      ),
                    ],
                  ),
                ] else if (_usedOfflineFallback) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Offline sample data',
                    style: SakhiTheme.poppins(
                      fontSize: 12,
                      color: SakhiColors.creamMuted,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.strings.availableSchemes,
            style: SakhiTheme.hind(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: SakhiColors.cream,
            ),
          ),
          const SizedBox(height: 10),
          if (_loading)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(
                child: CircularProgressIndicator(color: SakhiColors.gold),
              ),
            )
          else if (_schemes.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                widget.strings.noSchemes,
                style: SakhiTheme.hind(fontSize: 16, color: SakhiColors.creamMuted),
                textAlign: TextAlign.center,
              ),
            )
          else
            ..._schemes.map((s) => _SchemeCard(scheme: s)),
        ],
      ),
    );
  }
}

/// Card widget that displays a single government scheme's details.
///
/// Shows the scheme name, state (if available), summary, and eligibility
/// criteria in a styled container with a gold-accent border.
class _SchemeCard extends StatelessWidget {
  const _SchemeCard({required this.scheme});

  final GovtScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SakhiColors.fieldGreen.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SakhiColors.gold.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            scheme.name,
            style: SakhiTheme.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: SakhiColors.gold,
            ),
          ),
          if (scheme.state != null) ...[
            const SizedBox(height: 4),
            Text(
              scheme.state!,
              style: SakhiTheme.poppins(fontSize: 12, color: SakhiColors.creamMuted),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            scheme.summary,
            style: SakhiTheme.hind(fontSize: 14, color: SakhiColors.cream),
          ),
          if (scheme.eligibility != null) ...[
            const SizedBox(height: 8),
            Text(
              scheme.eligibility!,
              style: SakhiTheme.poppins(
                fontSize: 12,
                color: SakhiColors.creamMuted,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
