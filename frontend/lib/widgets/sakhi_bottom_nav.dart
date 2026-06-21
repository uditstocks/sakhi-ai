/// Bottom navigation bar for the Sakhi AI app.
///
/// Provides five tabs — Home, Mandi, Disease, Schemes, and SOS — each
/// represented by an emoji (or icon for SOS) and a localized label.
library;
import 'package:flutter/material.dart';
import 'package:sakhi_ai/l10n/app_strings.dart';
import 'package:sakhi_ai/theme/sakhi_colors.dart';
import 'package:sakhi_ai/theme/sakhi_theme.dart';

/// Enumerates the five top-level navigation destinations in the app.
enum SakhiNavTab { home, mandi, disease, schemes, sos }

/// A stateless bottom navigation bar that highlights the [activeTab] and
/// invokes [onTabSelected] when the user taps a tab.
class SakhiBottomNav extends StatelessWidget {
  const SakhiBottomNav({
    super.key,
    required this.strings,
    required this.activeTab,
    required this.onTabSelected,
  });

  /// Localized labels for each tab.
  final AppStrings strings;

  /// The currently selected navigation tab.
  final SakhiNavTab activeTab;

  /// Callback fired when the user taps a tab; receives the selected tab.
  final ValueChanged<SakhiNavTab> onTabSelected;

  /// Builds the horizontal row of five [_NavItem] widgets inside a styled container.
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: SakhiColors.deepGreenDark.withValues(alpha: 0.98),
        border: Border(
          top: BorderSide(color: SakhiColors.gold.withValues(alpha: 0.2)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              _NavItem(
                emoji: '🏠',
                label: strings.navHome,
                isActive: activeTab == SakhiNavTab.home,
                onTap: () => onTabSelected(SakhiNavTab.home),
              ),
              _NavItem(
                emoji: '🌾',
                label: strings.navMandi,
                isActive: activeTab == SakhiNavTab.mandi,
                onTap: () => onTabSelected(SakhiNavTab.mandi),
              ),
              _NavItem(
                emoji: '🌿',
                label: strings.navDisease,
                isActive: activeTab == SakhiNavTab.disease,
                onTap: () => onTabSelected(SakhiNavTab.disease),
              ),
              _NavItem(
                emoji: '📋',
                label: strings.navSchemes,
                isActive: activeTab == SakhiNavTab.schemes,
                onTap: () => onTabSelected(SakhiNavTab.schemes),
              ),
              _NavItem(
                label: strings.navSos,
                isActive: activeTab == SakhiNavTab.sos,
                isSos: true,
                onTap: () => onTabSelected(SakhiNavTab.sos),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A single navigation item inside [SakhiBottomNav].
///
/// Renders an emoji (or an emergency icon for SOS), a label, and adjusts
/// its colour to indicate whether it is the active tab.
class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.label,
    required this.isActive,
    required this.onTap,
    this.emoji,
    this.isSos = false,
  });

  /// Optional emoji displayed above the label (null for SOS).
  final String? emoji;

  /// Localized label text shown below the icon.
  final String label;

  /// Whether this tab is currently selected.
  final bool isActive;

  /// Whether this item is the SOS emergency tab (uses a red icon instead of emoji).
  final bool isSos;

  /// Callback invoked when the user taps this navigation item.
  final VoidCallback onTap;

  /// Builds the visual representation of this nav item, choosing between
  /// an emoji or SOS emergency icon and applying active/inactive colours.
  @override
  Widget build(BuildContext context) {
    final labelColor = isSos
        ? (isActive ? SakhiColors.gold : SakhiColors.sosRed)
        : (isActive ? SakhiColors.gold : SakhiColors.creamMuted);

    return Expanded(
      child: Semantics(
        button: true,
        selected: isActive,
        label: label,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 60),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isSos)
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: SakhiColors.sosRed.withValues(
                          alpha: isActive ? 0.45 : 0.28,
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: SakhiColors.sosRed,
                          width: isActive ? 2.5 : 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: SakhiColors.sosRed.withValues(alpha: 0.35),
                            blurRadius: isActive ? 8 : 4,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.emergency_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    )
                  else
                    Text(emoji!, style: const TextStyle(fontSize: 26)),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: SakhiTheme.hind(
                      fontSize: 13,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                      color: labelColor,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
