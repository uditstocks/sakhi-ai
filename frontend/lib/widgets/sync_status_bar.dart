/// Offline-mode status bar pinned above the bottom navigation.
///
/// Displays a sync icon, a localized "Offline Mode" title, a short status
/// message, an "OK" connectivity badge, and the last-synced timestamp.
library;
import 'package:flutter/material.dart';
import 'package:sakhi_ai/l10n/app_language.dart';
import 'package:sakhi_ai/l10n/app_strings.dart';
import 'package:sakhi_ai/theme/sakhi_colors.dart';
import 'package:sakhi_ai/theme/sakhi_theme.dart';

/// A stateless widget that renders a styled card summarising the app's
/// offline-readiness and the time of the last successful data sync.
class SyncStatusBar extends StatelessWidget {
  const SyncStatusBar({
    super.key,
    required this.strings,
    required this.lastSyncedLabel,
  });

  /// Localized strings for status messages and sync label.
  final AppStrings strings;

  /// Human-readable label describing when the last sync occurred.
  final String lastSyncedLabel;

  /// Builds the status card and the last-synced row beneath it.
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  SakhiColors.fieldGreen.withValues(alpha: 0.92),
                  SakhiColors.deepGreenDark.withValues(alpha: 0.95),
                ],
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: SakhiColors.gold.withValues(alpha: 0.35),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: SakhiColors.gold.withValues(alpha: 0.12),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: SakhiColors.gold.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: SakhiColors.gold.withValues(alpha: 0.45),
                    ),
                  ),
                  child: const Icon(
                    Icons.cloud_done_rounded,
                    color: SakhiColors.gold,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _offlineTitle(strings),
                        style: SakhiTheme.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: SakhiColors.cream,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        strings.offlineReady.replaceAll('📶 ', ''),
                        style: SakhiTheme.hind(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: SakhiColors.creamMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: SakhiColors.gold.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.wifi_off_rounded,
                        size: 14,
                        color: SakhiColors.gold.withValues(alpha: 0.95),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'OK',
                        style: SakhiTheme.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: SakhiColors.gold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.sync_rounded,
                size: 16,
                color: SakhiColors.creamMuted.withValues(alpha: 0.85),
              ),
              const SizedBox(width: 6),
              Text(
                strings.lastSynced(lastSyncedLabel),
                style: SakhiTheme.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: SakhiColors.creamMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Returns the localized "Offline Mode" title for the given [strings] language.
  String _offlineTitle(AppStrings strings) {
    return switch (strings.language) {
      AppLanguage.hindi => 'ऑफ़लाइन मोड',
      AppLanguage.marathi => 'ऑफलाइन मोड',
      AppLanguage.telugu => 'ఆఫ్‌లైన్ మోడ్',
      AppLanguage.tamil => 'ஆஃப்லைன் முறை',
      AppLanguage.bengali => 'অফলাইন মোড',
      AppLanguage.kannada => 'ಆಫ್‌ಲೈನ್ ಮೋಡ್',
      AppLanguage.english => 'Offline Mode',
    };
  }
}
