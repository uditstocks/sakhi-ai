import 'package:flutter/material.dart';
import 'package:sakhi_ai/l10n/app_strings.dart';
import 'package:sakhi_ai/theme/sakhi_colors.dart';
import 'package:sakhi_ai/theme/sakhi_theme.dart';

enum SakhiNavTab { home, mandi, disease, schemes, sos }

class SakhiBottomNav extends StatelessWidget {
  const SakhiBottomNav({
    super.key,
    required this.strings,
    required this.activeTab,
    required this.onTabSelected,
  });

  final AppStrings strings;
  final SakhiNavTab activeTab;
  final ValueChanged<SakhiNavTab> onTabSelected;

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

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.label,
    required this.isActive,
    required this.onTap,
    this.emoji,
    this.isSos = false,
  });

  final String? emoji;
  final String label;
  final bool isActive;
  final bool isSos;
  final VoidCallback onTap;

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
