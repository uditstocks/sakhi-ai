class GovtScheme {
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
