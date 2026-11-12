// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appTitle => 'USB कैमरा';

  @override
  String get appEngineCredit => 'कैमरा इंजन AUSBC (UVC / OpenGL) पर आधारित';

  @override
  String appLicense(String license) {
    return 'लाइसेंस $license';
  }

  @override
  String appVersion(String version) {
    return 'संस्करण $version';
  }

  @override
  String get permissionNeeded => 'कैमरा, माइक्रोफ़ोन और फ़ोटो अनुमति आवश्यक है';

  @override
  String get retry => 'फिर कोशिश करें';

  @override
  String get close => 'बंद करें';

  @override
  String get mode => 'मोड';

  @override
  String get devices => 'डिवाइस';

  @override
  String get hideControls => 'नियंत्रण छिपाएँ';

  @override
  String get noUsbCamera => 'अभी कोई USB कैमरा नहीं';

  @override
  String get workspaceWatch => 'देखें';

  @override
  String get workspaceCapture => 'कैप्चर';

  @override
  String get workspaceTune => 'ट्यून';

  @override
  String get workspaceWatchHint =>
      'केवल पूर्वावलोकन। कैमरा बदलने के लिए सूची खोलें।';

  @override
  String get workspaceCaptureHint => 'फ़ोटो, वीडियो और ऑडियो नीचे शटर से।';

  @override
  String get workspaceTuneHint => 'चित्र, वीडियो, प्रभाव, ऑडियो और खंड।';

  @override
  String get recordingBlocksMode => 'मोड बदलने से पहले रिकॉर्डिंग रोकें';

  @override
  String get sectionPicture => 'चित्र';

  @override
  String get sectionVideo => 'वीडियो';

  @override
  String get sectionEffects => 'प्रभाव';

  @override
  String get sectionAudio => 'ऑडियो';

  @override
  String get sectionSettings => 'सेटिंग्स';

  @override
  String get autoFocus => 'ऑटो फ़ोकस';

  @override
  String get autoWhiteBalance => 'ऑटो व्हाइट बैलेंस';

  @override
  String get resetDefaults => 'डिफ़ॉल्ट पर लाएँ';

  @override
  String get imageBrightness => 'चमक';

  @override
  String get imageContrast => 'कंट्रास्ट';

  @override
  String get imageSaturation => 'संतृप्ति';

  @override
  String get imageHue => 'ह्यू';

  @override
  String get imageGain => 'गेन';

  @override
  String get imageGamma => 'गामा';

  @override
  String get imageSharpness => 'तीक्ष्णता';

  @override
  String get imageZoom => 'ज़ूम';

  @override
  String get format => 'फ़ॉर्मेट';

  @override
  String get orientation => 'ओरिएंटेशन';

  @override
  String get resolution => 'रिज़ॉल्यूशन';

  @override
  String get frameRate => 'फ़्रेम दर';

  @override
  String get resolutionsAfterConnect => 'डिवाइस कनेक्ट होने के बाद दिखेगा';

  @override
  String get flipUpDown => 'ऊपर-नीचे पलटें';

  @override
  String get flipLeftRight => 'बाएँ-दाएँ पलटें';

  @override
  String get filter => 'फ़िल्टर';

  @override
  String get animation => 'एनिमेशन';

  @override
  String get none => 'कोई नहीं';

  @override
  String get filterMono => 'श्याम-श्वेत';

  @override
  String get animSoul => 'सोल';

  @override
  String get animZoom => 'ज़ूम';

  @override
  String get audioSource => 'ऑडियो स्रोत';

  @override
  String get micSystem => 'फ़ोन माइक';

  @override
  String get micDevice => 'डिवाइस माइक';

  @override
  String get micAuto => 'ऑटो';

  @override
  String get listenMic => 'माइक मॉनिटर';

  @override
  String get about => 'परिचय';

  @override
  String get tips => 'सुझाव';

  @override
  String get tipOtgTitle => 'OTG / USB Host आवश्यक';

  @override
  String get tipOtgBody =>
      'OTG एडाप्टर से UVC कैमरा, एंडोस्कोप या कैप्चर कार्ड जोड़ें। सिस्टम कैमरा न खोल पाए ऐसे उपकरणों के लिए।';

  @override
  String get tipPrefsTitle => 'पसंद याद रहती है';

  @override
  String get tipPrefsBody =>
      'मोड, रिज़ॉल्यूशन, fps, फ़ॉर्मेट, ओरिएंटेशन, ऑडियो और खंड अगली बार बहाल होते हैं।';

  @override
  String get tipMultiTitle => 'मल्टी पूर्वावलोकन';

  @override
  String get tipMultiBody =>
      'मल्टी ग्रिड संदर्भ Android UI में है। यह बिल्ड एकल पूर्वावलोकन देता है।';

  @override
  String get segmentDuration => 'खंड अवधि';

  @override
  String get segmentNone => 'कोई खंड नहीं';

  @override
  String segmentMinutes(int minutes) {
    return '$minutes मि';
  }

  @override
  String get language => 'भाषा';

  @override
  String get languageSystem => 'सिस्टम डिफ़ॉल्ट';

  @override
  String get waitingUsb => 'USB कैमरा की प्रतीक्षा';

  @override
  String get openFailed => 'यह कैमरा नहीं खुल सका';

  @override
  String get waitingHintEmpty =>
      'OTG से UVC कैमरा या कैप्चर कार्ड जोड़ें। Android USB अनुमति माँगेगा।';

  @override
  String get waitingHintDetected => 'डिवाइस मिला। नीचे सूची से चुनें।';

  @override
  String get errorHint => 'USB अनुमति जाँचें या दूसरी केबल आज़माएँ।';

  @override
  String get selectDevice => 'डिवाइस चुनें';

  @override
  String get retryDevice => 'डिवाइस फिर आज़माएँ';

  @override
  String get modePhoto => 'फ़ोटो';

  @override
  String get modeVideo => 'वीडियो';

  @override
  String get modeAudio => 'ऑडियो';

  @override
  String get shutter => 'शटर';

  @override
  String fpsLabel(int fps) {
    return '$fps FPS';
  }

  @override
  String fpsOption(int fps) {
    return '$fps fps';
  }

  @override
  String get defaultDeviceName => 'USB कैमरा';
}
