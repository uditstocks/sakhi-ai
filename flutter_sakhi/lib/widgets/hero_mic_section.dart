import 'package:flutter/material.dart';
import 'package:sakhi_ai/l10n/app_strings.dart';
import 'package:sakhi_ai/theme/sakhi_colors.dart';
import 'package:sakhi_ai/theme/sakhi_theme.dart';
import 'package:sakhi_ai/widgets/pulsing_mic_button.dart';
import 'package:sakhi_ai/widgets/waveform_animation.dart';

class HeroMicSection extends StatelessWidget {
  const HeroMicSection({
    super.key,
    required this.strings,
    required this.isListening,
    required this.onMicTap,
  });

  final AppStrings strings;
  final bool isListening;
  final VoidCallback onMicTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (isListening) ...[
            Text(
              strings.listeningNative,
              style: SakhiTheme.hind(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: SakhiColors.gold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              strings.listeningEnglish,
              style: SakhiTheme.poppins(
                fontSize: 16,
                color: SakhiColors.creamMuted,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            const WaveformAnimation(),
            const SizedBox(height: 20),
            Center(
              child: PulsingMicButton(
                isListening: isListening,
                onPressed: onMicTap,
              ),
            ),
          ] else ...[
            Text(
              strings.tapToSpeakPrimary,
              style: SakhiTheme.hind(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: SakhiColors.cream,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              strings.tapToSpeakSecondary,
              style: SakhiTheme.poppins(
                fontSize: 15,
                color: SakhiColors.creamMuted,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Center(
              child: PulsingMicButton(
                isListening: isListening,
                onPressed: onMicTap,
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                strings.voiceSubtitle,
                style: SakhiTheme.hind(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: SakhiColors.creamMuted,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
