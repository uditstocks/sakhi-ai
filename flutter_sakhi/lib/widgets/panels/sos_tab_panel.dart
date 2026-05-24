import 'package:flutter/material.dart';
import 'package:sakhi_ai/data/india_helplines.dart';
import 'package:sakhi_ai/l10n/app_strings.dart';
import 'package:sakhi_ai/models/helpline_contact.dart';
import 'package:sakhi_ai/theme/sakhi_colors.dart';
import 'package:sakhi_ai/theme/sakhi_theme.dart';
import 'package:url_launcher/url_launcher.dart';

class SosTabPanel extends StatelessWidget {
  const SosTabPanel({super.key, required this.strings});

  final AppStrings strings;

  Future<void> _callNumber(BuildContext context, String number) async {
    final uri = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cannot dial $number'), behavior: SnackBarBehavior.floating),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  SakhiColors.sosRed,
                  SakhiColors.sosRedDark,
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: SakhiColors.sosRed.withValues(alpha: 0.45),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                const Icon(Icons.emergency_rounded, size: 56, color: Colors.white),
                const SizedBox(height: 12),
                Text(
                  strings.sosTitle,
                  style: SakhiTheme.hind(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  strings.sosHint,
                  style: SakhiTheme.hind(
                    fontSize: 16,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            strings.emergencyNumbers,
            style: SakhiTheme.hind(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: SakhiColors.cream,
            ),
          ),
          const SizedBox(height: 12),
          ...kIndiaHelplines.map(
            (h) => _HelplineCard(
              contact: h,
              label: strings.helplineLabel(h.labelKey),
              callLabel: strings.callNow,
              onCall: (n) => _callNumber(context, n),
            ),
          ),
        ],
      ),
    );
  }
}

class _HelplineCard extends StatelessWidget {
  const _HelplineCard({
    required this.contact,
    required this.label,
    required this.callLabel,
    required this.onCall,
  });

  final HelplineContact contact;
  final String label;
  final String callLabel;
  final void Function(String number) onCall;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SakhiColors.deepGreenDark.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: contact.color.withValues(alpha: 0.5), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: contact.color.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(contact.icon, color: contact.color, size: 26),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${contact.emoji} $label',
                      style: SakhiTheme.hind(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: SakhiColors.cream,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: contact.numbers.map((number) {
              return Material(
                color: contact.color,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: () => onCall(number),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.phone_in_talk_rounded, color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          number,
                          style: SakhiTheme.poppins(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          callLabel,
                          style: SakhiTheme.poppins(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
