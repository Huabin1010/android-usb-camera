// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'كاميرا USB';

  @override
  String get appEngineCredit => 'محرك الكاميرا مبني على AUSBC (UVC / OpenGL)';

  @override
  String appLicense(String license) {
    return 'الترخيص $license';
  }

  @override
  String appVersion(String version) {
    return 'الإصدار $version';
  }

  @override
  String get permissionNeeded => 'يلزم إذن الكاميرا والميكروفون والصور';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get close => 'إغلاق';

  @override
  String get mode => 'الوضع';

  @override
  String get devices => 'الأجهزة';

  @override
  String get hideControls => 'إخفاء عناصر التحكم';

  @override
  String get noUsbCamera => 'لا توجد كاميرا USB بعد';

  @override
  String get workspaceWatch => 'مشاهدة';

  @override
  String get workspaceCapture => 'التقاط';

  @override
  String get workspaceTune => 'ضبط';

  @override
  String get workspaceWatchHint =>
      'معاينة فقط. افتح قائمة الأجهزة لتبديل الكاميرا.';

  @override
  String get workspaceCaptureHint => 'صورة وفيديو وصوت مع زر الغالق السفلي.';

  @override
  String get workspaceTuneHint => 'صورة وفيديو وتأثيرات وصوت ومقاطع.';

  @override
  String get recordingBlocksMode => 'أوقف التسجيل قبل تغيير الوضع';

  @override
  String get sectionPicture => 'الصورة';

  @override
  String get sectionVideo => 'الفيديو';

  @override
  String get sectionEffects => 'التأثيرات';

  @override
  String get sectionAudio => 'الصوت';

  @override
  String get sectionSettings => 'الإعدادات';

  @override
  String get autoFocus => 'تركيز تلقائي';

  @override
  String get autoWhiteBalance => 'توازن أبيض تلقائي';

  @override
  String get resetDefaults => 'استعادة الافتراضي';

  @override
  String get imageBrightness => 'السطوع';

  @override
  String get imageContrast => 'التباين';

  @override
  String get imageSaturation => 'التشبع';

  @override
  String get imageHue => 'درجة اللون';

  @override
  String get imageGain => 'الكسب';

  @override
  String get imageGamma => 'غاما';

  @override
  String get imageSharpness => 'الحدة';

  @override
  String get imageZoom => 'التكبير';

  @override
  String get format => 'التنسيق';

  @override
  String get orientation => 'الاتجاه';

  @override
  String get resolution => 'الدقة';

  @override
  String get frameRate => 'معدل الإطارات';

  @override
  String get resolutionsAfterConnect => 'يظهر بعد توصيل جهاز';

  @override
  String get flipUpDown => 'قلب رأسي';

  @override
  String get flipLeftRight => 'قلب أفقي';

  @override
  String get filter => 'مرشح';

  @override
  String get animation => 'رسوم متحركة';

  @override
  String get none => 'لا شيء';

  @override
  String get filterMono => 'أبيض وأسود';

  @override
  String get animSoul => 'سول';

  @override
  String get animZoom => 'تكبير';

  @override
  String get audioSource => 'مصدر الصوت';

  @override
  String get micSystem => 'ميكروفون الهاتف';

  @override
  String get micDevice => 'ميكروفون الجهاز';

  @override
  String get micAuto => 'تلقائي';

  @override
  String get listenMic => 'مراقبة الميكروفون';

  @override
  String get about => 'حول';

  @override
  String get tips => 'نصائح';

  @override
  String get tipOtgTitle => 'يلزم OTG / USB Host';

  @override
  String get tipOtgBody =>
      'وصّل كاميرا UVC أو منظارًا أو بطاقة التقاط عبر محول OTG. للأجهزة التي لا تفتحها كاميرا النظام.';

  @override
  String get tipPrefsTitle => 'يتم تذكر التفضيلات';

  @override
  String get tipPrefsBody =>
      'يُعاد الوضع والدقة ومعدل الإطارات والتنسيق والاتجاه والصوت والمقاطع عند التشغيل التالي.';

  @override
  String get tipMultiTitle => 'معاينة متعددة';

  @override
  String get tipMultiBody =>
      'شبكة الكاميرات المتعددة في واجهة Android المرجعية. هذا الإصدار بمعاينة واحدة.';

  @override
  String get segmentDuration => 'طول المقطع';

  @override
  String get segmentNone => 'بدون مقاطع';

  @override
  String segmentMinutes(int minutes) {
    return '$minutes د';
  }

  @override
  String get language => 'اللغة';

  @override
  String get languageSystem => 'افتراضي النظام';

  @override
  String get appearance => 'المظهر';

  @override
  String get themeSystem => 'افتراضي النظام';

  @override
  String get themeLight => 'فاتح';

  @override
  String get themeDark => 'داكن';

  @override
  String get tools => 'الضبط';

  @override
  String get previewPresets => 'إعدادات مسبقة';

  @override
  String get presetCustom => 'مخصص…';

  @override
  String get presetManage => 'إدارة الإعدادات';

  @override
  String get presetAddCurrent => 'إضافة الحالي';

  @override
  String get presetAdd => 'إضافة إعداد مسبق';

  @override
  String get presetReset => 'استعادة الافتراضي';

  @override
  String get presetDelete => 'إزالة';

  @override
  String get presetEmpty => 'لا إعدادات';

  @override
  String get presetAdded => 'تمت الإضافة';

  @override
  String get presetExists => 'موجود بالفعل';

  @override
  String get presetPickResolution => 'اختر الدقة';

  @override
  String get presetPickFps => 'اختر معدل الإطارات';

  @override
  String get presetSave => 'حفظ كإعداد مسبق';

  @override
  String get presetApply => 'تطبيق';

  @override
  String get waitingUsb => 'بانتظار كاميرا USB';

  @override
  String get openFailed => 'تعذر فتح هذه الكاميرا';

  @override
  String get waitingHintEmpty =>
      'استخدم محول OTG لتوصيل كاميرا UVC أو بطاقة التقاط. سيطلب Android إذن USB.';

  @override
  String get waitingHintDetected =>
      'تم اكتشاف جهاز. افتح القائمة أدناه للاختيار.';

  @override
  String get errorHint => 'تحقق من إذن USB أو جرّب كبلًا آخر.';

  @override
  String get selectDevice => 'اختيار جهاز';

  @override
  String get retryDevice => 'إعادة محاولة الجهاز';

  @override
  String get modePhoto => 'صورة';

  @override
  String get modeVideo => 'فيديو';

  @override
  String get modeAudio => 'صوت';

  @override
  String get shutter => 'غالق';

  @override
  String fpsLabel(int fps) {
    return '$fps FPS';
  }

  @override
  String fpsOption(int fps) {
    return '$fps fps';
  }

  @override
  String get defaultDeviceName => 'كاميرا USB';

  @override
  String get msgSaved => 'تم الحفظ';

  @override
  String get msgSaveFailed => 'تعذر الحفظ';

  @override
  String get msgNoDevice => 'لم يتم العثور على كاميرا USB';

  @override
  String get msgPreviewNotReady => 'المعاينة غير جاهزة بعد';

  @override
  String get msgCameraError => 'خطأ في الكاميرا';

  @override
  String previewStatus(int width, int height, String format, int fps) {
    return '$width×$height · $format · ${fps}fps';
  }
}
