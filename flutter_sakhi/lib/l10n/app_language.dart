enum AppLanguage {
  hindi('Hindi', 'हिंदी', 'hi'),
  english('English', 'English', 'en'),
  marathi('Marathi', 'मराठी', 'mr'),
  telugu('Telugu', 'తెలుగు', 'te'),
  tamil('Tamil', 'தமிழ்', 'ta'),
  bengali('Bengali', 'বাংলা', 'bn'),
  kannada('Kannada', 'ಕನ್ನಡ', 'kn');

  const AppLanguage(this.englishName, this.nativeName, this.code);

  final String englishName;
  final String nativeName;
  final String code;

  String get displayLabel => nativeName;
}
