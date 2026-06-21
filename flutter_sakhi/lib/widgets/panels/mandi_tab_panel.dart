/// Mandi (market) prices tab panel.
///
/// Displays a card prompting the user to ask about crop prices via voice.
/// Includes a shimmer animation overlay for visual emphasis.
import 'package:flutter/material.dart';
import 'package:sakhi_ai/l10n/app_strings.dart';
import 'package:sakhi_ai/theme/sakhi_colors.dart';
import 'package:sakhi_ai/theme/sakhi_theme.dart';
import 'package:shimmer/shimmer.dart';

/// Stateless widget that renders the Mandi price inquiry panel.
///
/// Shows a styled card with a voice-prompt button. The card is wrapped in a
/// [Shimmer] effect to draw the user's attention. Accepts an optional
/// [onVoiceTap] callback to trigger voice input.
class MandiTabPanel extends StatelessWidget {
  const MandiTabPanel({
    super.key,
    required this.strings,
    this.onVoiceTap,
  });

  final AppStrings strings;
  final VoidCallback? onVoiceTap;

  /// Builds the mandi panel: a shimmer-wrapped card with a crop emoji,
  /// title, hint text, and a "Tap to Speak" voice button.
  @override
  Widget build(BuildContext context) {
    Widget panel = Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20),
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
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🌾', style: TextStyle(fontSize: 56)),
          const SizedBox(height: 16),
          Text(
            strings.mandiTitle,
            style: SakhiTheme.hind(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: SakhiColors.cream,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            strings.mandiHint,
            style: SakhiTheme.hind(fontSize: 17, color: SakhiColors.creamMuted),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton.icon(
              onPressed: onVoiceTap,
              style: FilledButton.styleFrom(
                backgroundColor: SakhiColors.gold,
                foregroundColor: SakhiColors.deepGreen,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              icon: const Icon(Icons.mic_rounded),
              label: Text(
                strings.tapToSpeakPrimary,
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
    );

    panel = Shimmer.fromColors(
      baseColor: SakhiColors.cardGreen,
      highlightColor: SakhiColors.gold.withValues(alpha: 0.35),
      period: const Duration(milliseconds: 1400),
      child: panel,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 12, bottom: 16),
      child: panel,
    );
  }
}
