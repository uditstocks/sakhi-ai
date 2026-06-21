/// Data model for an emergency helpline contact.
///
/// Holds the contact's unique ID, display emoji, localization key, phone
/// numbers, Material icon, and theme color for rendering in the SOS panel.
library;
import 'package:flutter/material.dart';

/// Immutable representation of a single emergency helpline entry.
///
/// Used by the SOS panel to display contact cards with tap-to-call
/// functionality. Each contact can have multiple phone numbers.
class HelplineContact {
  /// Creates a [HelplineContact] with all required display and dialing fields.
  const HelplineContact({
    required this.id,
    required this.emoji,
    required this.labelKey,
    required this.numbers,
    required this.icon,
    required this.color,
  });

  final String id;
  final String emoji;
  final String labelKey;
  final List<String> numbers;
  final IconData icon;
  final Color color;
}
