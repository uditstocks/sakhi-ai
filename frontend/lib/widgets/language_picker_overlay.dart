/// Full-screen language selection overlay for Sakhi AI.
///
/// Presents a centered dialog containing a 2-column grid of language tiles
/// (Hindi, English, Marathi, Telugu, Tamil, Bengali, Kannada). Tapping a tile
/// pops the overlay and returns the selected [AppLanguage].
library;
import 'package:flutter/material.dart';
import 'package:sakhi_ai/l10n/app_language.dart';
import 'package:sakhi_ai/theme/sakhi_colors.dart';
import 'package:sakhi_ai/theme/sakhi_theme.dart';

/// Opens a modal overlay that lets the user pick an app language.
///
/// Returns the selected [AppLanguage], or `null` if the user dismisses the
/// overlay without choosing.
Future<AppLanguage?> showLanguagePicker(
  BuildContext context, {
  required AppLanguage current,
}) {
  return showGeneralDialog<AppLanguage>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Choose language',
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (context, animation, secondaryAnimation) {
      return const SizedBox.shrink();
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final scale = CurvedAnimation(parent: animation, curve: Curves.easeOutBack);
      return FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.92, end: 1).animate(scale),
          child: _LanguagePickerSheet(current: current),
        ),
      );
    },
  );
}

/// The inner content of the language picker dialog.
///
/// Renders a titled card with a 2-column grid of [_LanguageTile] widgets,
/// one for each supported [AppLanguage].
class _LanguagePickerSheet extends StatelessWidget {
  const _LanguagePickerSheet({required this.current});

  /// The currently active language, used to highlight the selected tile.
  final AppLanguage current;

  /// Builds the dialog card with title, subtitle, and language grid.
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 320,
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
          decoration: BoxDecoration(
            color: SakhiColors.deepGreenDark,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: SakhiColors.gold.withValues(alpha: 0.45), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.45),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Choose Language',
                style: SakhiTheme.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: SakhiColors.gold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'भाषा चुनें',
                style: SakhiTheme.hind(
                  fontSize: 15,
                  color: SakhiColors.creamMuted,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 380,
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 1.05,
                  children: AppLanguage.values.map((lang) {
                    final selected = lang == current;
                    return _LanguageTile(
                      language: lang,
                      selected: selected,
                      onTap: () => Navigator.of(context).pop(lang),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A single square tile representing one language in the picker grid.
///
/// Shows the language's English name, native name, and a check-mark icon
/// when it is the currently selected language.
class _LanguageTile extends StatelessWidget {
  const _LanguageTile({
    required this.language,
    required this.selected,
    required this.onTap,
  });

  /// The language this tile represents.
  final AppLanguage language;

  /// Whether this tile is the currently selected language.
  final bool selected;

  /// Callback invoked when the user taps this tile.
  final VoidCallback onTap;

  /// Renders the tile with a highlighted border and check-mark when selected.
  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: '${language.englishName}, ${language.nativeName}',
      child: Material(
        color: selected
            ? SakhiColors.gold.withValues(alpha: 0.22)
            : SakhiColors.cardGreen,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: selected ? SakhiColors.gold : SakhiColors.gold.withValues(alpha: 0.25),
                width: selected ? 2 : 1,
              ),
            ),
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  language.englishName,
                  style: SakhiTheme.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: selected ? SakhiColors.gold : SakhiColors.cream,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  language.nativeName,
                  style: SakhiTheme.hind(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: SakhiColors.cream,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (selected) ...[
                  const SizedBox(height: 6),
                  Icon(
                    Icons.check_circle_rounded,
                    color: SakhiColors.gold,
                    size: 18,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
