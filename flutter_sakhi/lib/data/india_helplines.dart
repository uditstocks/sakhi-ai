/// Static list of Indian emergency helpline contacts.
///
/// Defines three critical emergency services — ambulance, police, and women
/// helpline — with their phone numbers, icons, and theme colors. Used by
/// the SOS panel to render tap-to-call contact cards.
import 'package:flutter/material.dart';
import 'package:sakhi_ai/models/helpline_contact.dart';
import 'package:sakhi_ai/theme/sakhi_colors.dart';

/// Bundled list of emergency [HelplineContact] entries for India.
const List<HelplineContact> kIndiaHelplines = [
  HelplineContact(
    id: 'ambulance',
    emoji: '🚑',
    labelKey: 'ambulance',
    numbers: ['108', '102'],
    icon: Icons.local_hospital_rounded,
    color: Color(0xFFE53935),
  ),
  HelplineContact(
    id: 'police',
    emoji: '👮',
    labelKey: 'police',
    numbers: ['100', '112'],
    icon: Icons.local_police_rounded,
    color: Color(0xFF1565C0),
  ),
  HelplineContact(
    id: 'women',
    emoji: '👩',
    labelKey: 'women',
    numbers: ['181', '1091', '7827170170'],
    icon: Icons.volunteer_activism_rounded,
    color: SakhiColors.sosRed,
  ),
];
