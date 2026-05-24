import 'package:flutter/material.dart';

class HelplineContact {
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
