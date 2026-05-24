import 'package:flutter/material.dart';
import 'package:sakhi_ai/l10n/app_language.dart';
import 'package:sakhi_ai/l10n/app_strings.dart';
import 'package:sakhi_ai/theme/sakhi_colors.dart';
import 'package:sakhi_ai/theme/sakhi_theme.dart';

class SakhiTopBar extends StatelessWidget {
  const SakhiTopBar({
    super.key,
    required this.strings,
    required this.language,
    required this.onLanguageTap,
  });

  final AppStrings strings;
  final AppLanguage language;
  final VoidCallback onLanguageTap;

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
