/// Top app bar widget for the Sakhi AI home screen.
///
/// Displays the "Sakhi AI" title, a localized tagline, and a button that
/// opens the language picker showing the current language label.
library;
import 'package:flutter/material.dart';
import 'package:sakhi_ai/l10n/app_language.dart';
import 'package:sakhi_ai/l10n/app_strings.dart';
import 'package:sakhi_ai/theme/sakhi_colors.dart';
import 'package:sakhi_ai/theme/sakhi_theme.dart';

/// A stateless top bar that renders the app branding and a language switcher.
///
/// Requires [strings] for localized text, [language] for the current locale,
/// and [onLanguageTap] to handle language-button presses.
class SakhiTopBar extends StatelessWidget {
  const SakhiTopBar({
    super.key,
    required this.strings,
    required this.language,
    required this.onLanguageTap,
  });

  /// Localized UI strings used for the tagline.
  final AppStrings strings;

  /// The currently selected app language.
  final AppLanguage language;

  /// Callback invoked when the language pill button is tapped.
  final VoidCallback onLanguageTap;

  /// Builds the top bar layout with title on the left and language button on the right.
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 12, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sakhi AI',
                  style: SakhiTheme.poppins(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: SakhiColors.gold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  strings.tagline,
                  style: SakhiTheme.hind(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: SakhiColors.creamMuted,
                  ),
                ),
              ],
            ),
          ),
          Semantics(
            button: true,
            label: 'Change language, current ${language.displayLabel}',
            child: Material(
              color: SakhiColors.fieldGreen.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(24),
              child: InkWell(
                onTap: onLanguageTap,
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.language_rounded, color: SakhiColors.gold, size: 22),
                      const SizedBox(width: 6),
                      Text(
                        language.displayLabel,
                        style: SakhiTheme.hind(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: SakhiColors.cream,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
