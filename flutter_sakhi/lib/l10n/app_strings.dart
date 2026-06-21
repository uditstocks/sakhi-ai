/// Localized strings for the Sakhi AI app.
///
/// Provides translated UI strings for all 7 supported languages (Hindi,
/// English, Marathi, Telugu, Tamil, Bengali, Kannada). Each getter uses a
/// switch expression on the current [AppLanguage] to return the correct
/// translation.
import 'package:sakhi_ai/l10n/app_language.dart';

/// Holds all user-facing strings for the app, resolved by [language].
///
/// Instantiate with an [AppLanguage] and access localized strings via
/// getters (e.g., `strings.tagline`, `strings.tapToSpeakPrimary`).
class AppStrings {
  /// Creates an [AppStrings] instance for the given [language].
  AppStrings(this.language);

  final AppLanguage language;

  String get tagline => switch (language) {
        AppLanguage.hindi => 'आपकी खेती, आपकी आवाज़',
        AppLanguage.marathi => 'तुमची शेती, तुमचा आवाज',
        AppLanguage.telugu => 'మీ పొలం, మీ గొంతు',
        AppLanguage.tamil => 'உங்கள் பண்ணை, உங்கள் குரல்',
        AppLanguage.bengali => 'আপনার খামার, আপনার কণ্ঠ',
        AppLanguage.kannada => 'ನಿಮ್ಮ ಕೃಷಿ, ನಿಮ್ಮ ಧ್ವನಿ',
        AppLanguage.english => 'Your Farm, Your Voice',
      };

  String get tapToSpeakPrimary => switch (language) {
        AppLanguage.hindi => 'बोलने के लिए टैप करें',
        AppLanguage.marathi => 'बोलण्यासाठी टॅप करा',
        AppLanguage.telugu => 'మాట్లాడటానికి ట్యాప్ చేయండి',
        AppLanguage.tamil => 'பேச தட்டவும்',
        AppLanguage.bengali => 'কথা বলতে ট্যাপ করুন',
        AppLanguage.kannada => 'ಮಾತನಾಡಲು ಟ್ಯಾಪ್ ಮಾಡಿ',
        AppLanguage.english => 'Tap to Speak',
      };

  String get tapToSpeakSecondary => 'Tap to Speak';

  String get voiceSubtitle => switch (language) {
        AppLanguage.hindi => 'टाइप की ज़रूरत नहीं • बोलो, हम सुनेंगे',
        AppLanguage.marathi => 'टाइप गरज नाही • बोला, आम्ही ऐकू',
        AppLanguage.telugu => 'టైప్ అవసరం లేదు • మాట్లాడండి, మేము వింటాము',
        AppLanguage.tamil => 'தட்டச்சு தேவையில்லை • பேசுங்கள், நாங்கள் கேட்போம்',
        AppLanguage.bengali => 'টাইপের দরকার নেই • বলুন, আমরা শুনব',
        AppLanguage.kannada => 'ಟೈಪ್ ಬೇಡ • ಮಾತನಾಡಿ, ನಾವು ಕೇಳುತ್ತೇವೆ',
        AppLanguage.english => 'No typing needed • Speak, we listen',
      };

  String get listeningNative => switch (language) {
        AppLanguage.hindi => 'सुन रही हूँ...',
        AppLanguage.marathi => 'ऐकत आहे...',
        AppLanguage.telugu => 'వింటున్నాను...',
        AppLanguage.tamil => 'கேட்கிறேன்...',
        AppLanguage.bengali => 'শুনছি...',
        AppLanguage.kannada => 'ಕೇಳುತ್ತಿದ್ದೇನೆ...',
        AppLanguage.english => 'Listening...',
      };

  String get listeningEnglish => 'Listening...';

  String get offlineReady => switch (language) {
        AppLanguage.hindi => '📶 ऑफ़लाइन मोड तैयार',
        AppLanguage.marathi => '📶 ऑफलाइन मोड तयार',
        AppLanguage.telugu => '📶 ఆఫ్‌లైన్ మోడ్ సిద్ధం',
        AppLanguage.tamil => '📶 ஆஃப்லைன் முறை தயார்',
        AppLanguage.bengali => '📶 অফলাইন মোড প্রস্তুত',
        AppLanguage.kannada => '📶 ಆಫ್‌ಲೈನ್ ಮೋಡ್ ಸಿದ್ಧ',
        AppLanguage.english => '📶 Offline Mode Ready',
      };

  String lastSynced(String timeAgo) => switch (language) {
        AppLanguage.hindi => 'आखिरी सिंक: $timeAgo',
        AppLanguage.marathi => 'शेवटचे सिंक: $timeAgo',
        AppLanguage.telugu => 'చివరి సింక్: $timeAgo',
        AppLanguage.tamil => 'கடைசி ஒத்திசைவு: $timeAgo',
        AppLanguage.bengali => 'সর্বশেষ সিঙ্ক: $timeAgo',
        AppLanguage.kannada => 'ಕೊನೆಯ ಸಿಂಕ್: $timeAgo',
        AppLanguage.english => 'Last synced: $timeAgo',
      };

  String get navHome => switch (language) {
        AppLanguage.hindi => 'होम',
        AppLanguage.marathi => 'होम',
        AppLanguage.telugu => 'హోమ్',
        AppLanguage.tamil => 'முகப்பு',
        AppLanguage.bengali => 'হোম',
        AppLanguage.kannada => 'ಮುಖ್ಯ',
        AppLanguage.english => 'Home',
      };

  String get navMandi => switch (language) {
        AppLanguage.hindi => 'मंडी',
        AppLanguage.marathi => 'मंडी',
        AppLanguage.telugu => 'మండి',
        AppLanguage.tamil => 'சந்தை',
        AppLanguage.bengali => 'মণ্ডি',
        AppLanguage.kannada => 'ಮಂಡಿ',
        AppLanguage.english => 'Mandi',
      };

  String get navDisease => switch (language) {
        AppLanguage.hindi => 'रोग',
        AppLanguage.marathi => 'रोग',
        AppLanguage.telugu => 'రోగం',
        AppLanguage.tamil => 'நோய்',
        AppLanguage.bengali => 'রোগ',
        AppLanguage.kannada => 'ರೋಗ',
        AppLanguage.english => 'Disease',
      };

  String get navSchemes => switch (language) {
        AppLanguage.hindi => 'योजना',
        AppLanguage.marathi => 'योजना',
        AppLanguage.telugu => 'పథకం',
        AppLanguage.tamil => 'திட்டம்',
        AppLanguage.bengali => 'প্রকল্প',
        AppLanguage.kannada => 'ಯೋಜನೆ',
        AppLanguage.english => 'Schemes',
      };

  String get navSos => 'SOS';

  String get mandiTitle => switch (language) {
        AppLanguage.hindi => 'मंडी भाव',
        AppLanguage.marathi => 'मंडी भाव',
        AppLanguage.telugu => 'మండి ధరలు',
        AppLanguage.tamil => 'சந்தை விலை',
        AppLanguage.bengali => 'মণ্ডি দর',
        AppLanguage.kannada => 'ಮಂಡಿ ಬೆಲೆ',
        AppLanguage.english => 'Mandi Price',
      };

  String get mandiHint => switch (language) {
        AppLanguage.hindi => 'आज के भाव • आवाज़ से पूछें',
        AppLanguage.marathi => 'आजचे दर • आवाजाने विचारा',
        AppLanguage.telugu => 'నేటి ధరలు • మాట్లాడి అడగండి',
        AppLanguage.tamil => 'இன்றைய விலை • பேசி கேளுங்கள்',
        AppLanguage.bengali => 'আজকের দর • কথা বলে জিজ্ঞেস করুন',
        AppLanguage.kannada => 'ಇಂದಿನ ಬೆಲೆ • ಮಾತನಾಡಿ ಕೇಳಿ',
        AppLanguage.english => "Today's prices • Ask by voice",
      };

  String get diseaseTitle => switch (language) {
        AppLanguage.hindi => 'फसल रोग',
        AppLanguage.marathi => 'पीक रोग',
        AppLanguage.telugu => 'పంట రోగం',
        AppLanguage.tamil => 'பயிர் நோய்',
        AppLanguage.bengali => 'ফসলের রোগ',
        AppLanguage.kannada => 'ಬೆಳೆ ರೋಗ',
        AppLanguage.english => 'Crop Disease',
      };

  String get diseaseHint => switch (language) {
        AppLanguage.hindi => 'पत्ते की फोटो खींचें',
        AppLanguage.marathi => 'पानाचा फोटो काढा',
        AppLanguage.telugu => 'ఆకు ఫోటో తీయండి',
        AppLanguage.tamil => 'இலை புகைப்படம் எடுக்கவும்',
        AppLanguage.bengali => 'পাতার ছবি তুলুন',
        AppLanguage.kannada => 'ಎಲೆಯ ಫೋಟೋ ತೆಗೆಯಿರಿ',
        AppLanguage.english => 'Take a photo of crop leaves',
      };

  String get takePhoto => switch (language) {
        AppLanguage.hindi => 'फोटो लें',
        AppLanguage.marathi => 'फोटो काढा',
        AppLanguage.telugu => 'ఫోటో తీయండి',
        AppLanguage.tamil => 'புகைப்படம் எடு',
        AppLanguage.bengali => 'ছবি তুলুন',
        AppLanguage.kannada => 'ಫೋಟೋ ತೆಗೆಯಿರಿ',
        AppLanguage.english => 'Take Photo',
      };

  String get schemesTitle => switch (language) {
        AppLanguage.hindi => 'सरकारी योजना',
        AppLanguage.marathi => 'सरकारी योजना',
        AppLanguage.telugu => 'ప్రభుత్వ పథకాలు',
        AppLanguage.tamil => 'அரசு திட்டங்கள்',
        AppLanguage.bengali => 'সরকারি প্রকল্প',
        AppLanguage.kannada => 'ಸರ್ಕಾರಿ ಯೋಜನೆಗಳು',
        AppLanguage.english => 'Govt Schemes',
      };

  String get connectDatabase => switch (language) {
        AppLanguage.hindi => 'डेटाबेस से जोड़ें',
        AppLanguage.marathi => 'डेटाबेसशी जोडा',
        AppLanguage.telugu => 'డేటాబేస్ కనెక్ట్',
        AppLanguage.tamil => 'தரவுத்தள இணைப்பு',
        AppLanguage.bengali => 'ডাটাবেস সংযোগ',
        AppLanguage.kannada => 'ಡೇಟಾಬೇಸ್ ಸಂಪರ್ಕ',
        AppLanguage.english => 'Connect to Database',
      };

  String get loadingSchemes => switch (language) {
        AppLanguage.hindi => 'योजनाएँ लोड हो रही हैं...',
        AppLanguage.marathi => 'योजना लोड होत आहेत...',
        AppLanguage.telugu => 'పథకాలు లోడ్ అవుతున్నాయి...',
        AppLanguage.tamil => 'திட்டங்கள் ஏற்றப்படுகின்றன...',
        AppLanguage.bengali => 'প্রকল্প লোড হচ্ছে...',
        AppLanguage.kannada => 'ಯೋಜನೆಗಳು ಲೋಡ್ ಆಗುತ್ತಿದೆ...',
        AppLanguage.english => 'Loading schemes...',
      };

  String get dbConnected => switch (language) {
        AppLanguage.hindi => 'डेटाबेस से जुड़ा',
        AppLanguage.marathi => 'डेटाबेसशी जोडले',
        AppLanguage.telugu => 'డేటాబేస్ కనెక్ట్ అయింది',
        AppLanguage.tamil => 'தரவுத்தளம் இணைக்கப்பட்டது',
        AppLanguage.bengali => 'ডাটাবেস সংযুক্ত',
        AppLanguage.kannada => 'ಡೇಟಾಬೇಸ್ ಸಂಪರ್ಕವಾಗಿದೆ',
        AppLanguage.english => 'Connected to database',
      };

  String get noSchemes => switch (language) {
        AppLanguage.hindi => 'कोई योजना नहीं मिली',
        AppLanguage.marathi => 'योजना सापडल्या नाहीत',
        AppLanguage.telugu => 'పథకాలు లేవు',
        AppLanguage.tamil => 'திட்டங்கள் இல்லை',
        AppLanguage.bengali => 'কোনো প্রকল্প নেই',
        AppLanguage.kannada => 'ಯೋಜನೆಗಳಿಲ್ಲ',
        AppLanguage.english => 'No schemes found',
      };

  String get availableSchemes => switch (language) {
        AppLanguage.hindi => 'उपलब्ध योजनाएँ',
        AppLanguage.marathi => 'उपलब्ध योजना',
        AppLanguage.telugu => 'అందుబాటులో ఉన్న పథకాలు',
        AppLanguage.tamil => 'கிடைக்கும் திட்டங்கள்',
        AppLanguage.bengali => 'উপলব্ধ প্রকল্প',
        AppLanguage.kannada => 'ಲಭ್ಯವಿರುವ ಯೋಜನೆಗಳು',
        AppLanguage.english => 'Available Schemes',
      };

  String get sosTitle => switch (language) {
        AppLanguage.hindi => 'SOS सुरक्षा',
        AppLanguage.marathi => 'SOS सुरक्षा',
        AppLanguage.telugu => 'SOS భద్రత',
        AppLanguage.tamil => 'SOS பாதுகாப்பு',
        AppLanguage.bengali => 'SOS নিরাপত্তা',
        AppLanguage.kannada => 'SOS ಸುರಕ್ಷೆ',
        AppLanguage.english => 'SOS Safety',
      };

  String get sosHint => switch (language) {
        AppLanguage.hindi => 'तुरंत कॉल करें',
        AppLanguage.marathi => 'लगेच कॉल करा',
        AppLanguage.telugu => 'వెంటనే కాల్ చేయండి',
        AppLanguage.tamil => 'உடனே அழைக்கவும்',
        AppLanguage.bengali => 'এখনই কল করুন',
        AppLanguage.kannada => 'ತಕ್ಷಣ ಕರೆ ಮಾಡಿ',
        AppLanguage.english => 'Call for help now',
      };

  String get emergencyNumbers => switch (language) {
        AppLanguage.hindi => 'आपातकालीन नंबर',
        AppLanguage.marathi => 'आपत्कालीन क्रमांक',
        AppLanguage.telugu => 'అత్యవసర నంబర్లు',
        AppLanguage.tamil => 'அவசர எண்கள்',
        AppLanguage.bengali => 'জরুরি নম্বর',
        AppLanguage.kannada => 'ತುರ್ತು ಸಂಖ್ಯೆಗಳು',
        AppLanguage.english => 'Emergency Numbers',
      };

  String helplineLabel(String key) => switch (key) {
        'ambulance' => switch (language) {
            AppLanguage.hindi => 'एम्बुलेंस',
            AppLanguage.marathi => 'ॲम्ब्युलन्स',
            AppLanguage.telugu => 'అంబులెన్స్',
            AppLanguage.tamil => 'ஆம்புலன்ஸ்',
            AppLanguage.bengali => 'অ্যাম্বুলেন্স',
            AppLanguage.kannada => 'ಆಂಬುಲೆನ್ಸ್',
            AppLanguage.english => 'Ambulance',
          },
        'police' => switch (language) {
            AppLanguage.hindi => 'पुलिस',
            AppLanguage.marathi => 'पोलीस',
            AppLanguage.telugu => 'పోలీసు',
            AppLanguage.tamil => 'போலீசு',
            AppLanguage.bengali => 'পুলিশ',
            AppLanguage.kannada => 'ಪೊಲೀಸ್',
            AppLanguage.english => 'Police',
          },
        'women' => switch (language) {
            AppLanguage.hindi => 'महिला हेल्पलाइन',
            AppLanguage.marathi => 'महिला हेल्पलाइन',
            AppLanguage.telugu => 'మహిళా హెల్ప్‌లైన్',
            AppLanguage.tamil => 'பெண்கள் உதவி',
            AppLanguage.bengali => 'নারী হেল্পলাইন',
            AppLanguage.kannada => 'ಮಹಿಳಾ ಸಹಾಯವಾಣಿ',
            AppLanguage.english => 'Women Helpline',
          },
        _ => key,
      };

  String get callNow => switch (language) {
        AppLanguage.hindi => 'कॉल करें',
        AppLanguage.marathi => 'कॉल करा',
        AppLanguage.telugu => 'కాల్',
        AppLanguage.tamil => 'அழை',
        AppLanguage.bengali => 'কল',
        AppLanguage.kannada => 'ಕರೆ',
        AppLanguage.english => 'Call',
      };
}
