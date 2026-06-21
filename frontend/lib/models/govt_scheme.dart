/// Data model for a government agricultural scheme.
///
/// Represents a scheme with an ID, name, summary, and optional state and
/// eligibility fields. Supports deserialization from JSON via [fromJson].
class GovtScheme {
  /// Creates a [GovtScheme] with the given required and optional fields.
  const GovtScheme({
    required this.id,
    required this.name,
    required this.summary,
    this.state,
    this.eligibility,
  });

  final String id;
  final String name;
  final String summary;
  final String? state;
  final String? eligibility;

  /// Deserializes a [GovtScheme] from a JSON map.
  ///
  /// Handles flexible field names (e.g., `id`/`_id`, `name`/`title`,
  /// `summary`/`description`) to accommodate different backend response formats.
  factory GovtScheme.fromJson(Map<String, dynamic> json) {
    return GovtScheme(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      name: json['name'] as String? ?? json['title'] as String? ?? 'Scheme',
      summary: json['summary'] as String? ??
          json['description'] as String? ??
          '',
      state: json['state'] as String?,
      eligibility: json['eligibility'] as String?,
    );
  }
}
