/// Enum defining the languages supported by Sakhi AI.
///
/// Each language carries its English name, native-script name, and ISO 639-1
/// language code. Used throughout the app for localization and language
/// selection UI.
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
