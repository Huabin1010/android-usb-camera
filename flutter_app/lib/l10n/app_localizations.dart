import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_id.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ar'),
    Locale('de'),
    Locale('es'),
    Locale('fr'),
    Locale('hi'),
    Locale('id'),
    Locale('ja'),
    Locale('ko'),
    Locale('pt'),
    Locale('ru'),
    Locale('zh'),
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'USB Camera'**
  String get appTitle;

  /// No description provided for @appEngineCredit.
  ///
  /// In en, this message translates to:
  /// **'Camera engine based on AUSBC (UVC / OpenGL)'**
  String get appEngineCredit;

  /// No description provided for @appLicense.
  ///
  /// In en, this message translates to:
  /// **'License {license}'**
  String appLicense(String license);

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String appVersion(String version);

  /// No description provided for @permissionNeeded.
  ///
  /// In en, this message translates to:
  /// **'Camera, microphone, and photos access are required'**
  String get permissionNeeded;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @mode.
  ///
  /// In en, this message translates to:
  /// **'Mode'**
  String get mode;

  /// No description provided for @devices.
  ///
  /// In en, this message translates to:
  /// **'Devices'**
  String get devices;

  /// No description provided for @hideControls.
  ///
  /// In en, this message translates to:
  /// **'Hide controls'**
  String get hideControls;

  /// No description provided for @noUsbCamera.
  ///
  /// In en, this message translates to:
  /// **'No USB camera yet'**
  String get noUsbCamera;

  /// No description provided for @workspaceWatch.
  ///
  /// In en, this message translates to:
  /// **'Watch'**
  String get workspaceWatch;

  /// No description provided for @workspaceCapture.
  ///
  /// In en, this message translates to:
  /// **'Capture'**
  String get workspaceCapture;

  /// No description provided for @workspaceTune.
  ///
  /// In en, this message translates to:
  /// **'Tune'**
  String get workspaceTune;

  /// No description provided for @workspaceWatchHint.
  ///
  /// In en, this message translates to:
  /// **'Preview only. Open the device list when you need to switch cameras.'**
  String get workspaceWatchHint;

  /// No description provided for @workspaceCaptureHint.
  ///
  /// In en, this message translates to:
  /// **'Photo, video, and audio with the shutter bar.'**
  String get workspaceCaptureHint;

  /// No description provided for @workspaceTuneHint.
  ///
  /// In en, this message translates to:
  /// **'Picture, video, effects, audio, and segment settings.'**
  String get workspaceTuneHint;

  /// No description provided for @recordingBlocksMode.
  ///
  /// In en, this message translates to:
  /// **'Stop recording or audio capture before switching modes'**
  String get recordingBlocksMode;

  /// No description provided for @sectionPicture.
  ///
  /// In en, this message translates to:
  /// **'Picture'**
  String get sectionPicture;

  /// No description provided for @sectionVideo.
  ///
  /// In en, this message translates to:
  /// **'Video'**
  String get sectionVideo;

  /// No description provided for @sectionEffects.
  ///
  /// In en, this message translates to:
  /// **'Effects'**
  String get sectionEffects;

  /// No description provided for @sectionAudio.
  ///
  /// In en, this message translates to:
  /// **'Audio'**
  String get sectionAudio;

  /// No description provided for @sectionSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get sectionSettings;

  /// No description provided for @autoFocus.
  ///
  /// In en, this message translates to:
  /// **'Auto focus'**
  String get autoFocus;

  /// No description provided for @autoWhiteBalance.
  ///
  /// In en, this message translates to:
  /// **'Auto white balance'**
  String get autoWhiteBalance;

  /// No description provided for @resetDefaults.
  ///
  /// In en, this message translates to:
  /// **'Reset to defaults'**
  String get resetDefaults;

  /// No description provided for @imageBrightness.
  ///
  /// In en, this message translates to:
  /// **'Brightness'**
  String get imageBrightness;

  /// No description provided for @imageContrast.
  ///
  /// In en, this message translates to:
  /// **'Contrast'**
  String get imageContrast;

  /// No description provided for @imageSaturation.
  ///
  /// In en, this message translates to:
  /// **'Saturation'**
  String get imageSaturation;

  /// No description provided for @imageHue.
  ///
  /// In en, this message translates to:
  /// **'Hue'**
  String get imageHue;

  /// No description provided for @imageGain.
  ///
  /// In en, this message translates to:
  /// **'Gain'**
  String get imageGain;

  /// No description provided for @imageGamma.
  ///
  /// In en, this message translates to:
  /// **'Gamma'**
  String get imageGamma;

  /// No description provided for @imageSharpness.
  ///
  /// In en, this message translates to:
  /// **'Sharpness'**
  String get imageSharpness;

  /// No description provided for @imageZoom.
  ///
  /// In en, this message translates to:
  /// **'Zoom'**
  String get imageZoom;

  /// No description provided for @format.
  ///
  /// In en, this message translates to:
  /// **'Format'**
  String get format;

  /// No description provided for @orientation.
  ///
  /// In en, this message translates to:
  /// **'Orientation'**
  String get orientation;

  /// No description provided for @resolution.
  ///
  /// In en, this message translates to:
  /// **'Resolution'**
  String get resolution;

  /// No description provided for @frameRate.
  ///
  /// In en, this message translates to:
  /// **'Frame rate'**
  String get frameRate;

  /// No description provided for @resolutionsAfterConnect.
  ///
  /// In en, this message translates to:
  /// **'Shown after a device is connected'**
  String get resolutionsAfterConnect;

  /// No description provided for @flipUpDown.
  ///
  /// In en, this message translates to:
  /// **'Flip vertical'**
  String get flipUpDown;

  /// No description provided for @flipLeftRight.
  ///
  /// In en, this message translates to:
  /// **'Flip horizontal'**
  String get flipLeftRight;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @animation.
  ///
  /// In en, this message translates to:
  /// **'Animation'**
  String get animation;

  /// No description provided for @none.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get none;

  /// No description provided for @filterMono.
  ///
  /// In en, this message translates to:
  /// **'Black & white'**
  String get filterMono;

  /// No description provided for @animSoul.
  ///
  /// In en, this message translates to:
  /// **'Soul'**
  String get animSoul;

  /// No description provided for @animZoom.
  ///
  /// In en, this message translates to:
  /// **'Zoom'**
  String get animZoom;

  /// No description provided for @audioSource.
  ///
  /// In en, this message translates to:
  /// **'Audio source'**
  String get audioSource;

  /// No description provided for @micSystem.
  ///
  /// In en, this message translates to:
  /// **'Phone microphone'**
  String get micSystem;

  /// No description provided for @micDevice.
  ///
  /// In en, this message translates to:
  /// **'Device microphone'**
  String get micDevice;

  /// No description provided for @micAuto.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get micAuto;

  /// No description provided for @listenMic.
  ///
  /// In en, this message translates to:
  /// **'Monitor microphone'**
  String get listenMic;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @tips.
  ///
  /// In en, this message translates to:
  /// **'Tips'**
  String get tips;

  /// No description provided for @tipOtgTitle.
  ///
  /// In en, this message translates to:
  /// **'OTG / USB Host required'**
  String get tipOtgTitle;

  /// No description provided for @tipOtgBody.
  ///
  /// In en, this message translates to:
  /// **'Connect a UVC camera, endoscope, or capture card with an OTG adapter. This app is for devices the system camera cannot open.'**
  String get tipOtgBody;

  /// No description provided for @tipPrefsTitle.
  ///
  /// In en, this message translates to:
  /// **'Preferences are remembered'**
  String get tipPrefsTitle;

  /// No description provided for @tipPrefsBody.
  ///
  /// In en, this message translates to:
  /// **'Workspace mode, resolution, frame rate, format, orientation, audio source, and segments restore on the next launch.'**
  String get tipPrefsBody;

  /// No description provided for @tipMultiTitle.
  ///
  /// In en, this message translates to:
  /// **'Multi-camera preview'**
  String get tipMultiTitle;

  /// No description provided for @tipMultiBody.
  ///
  /// In en, this message translates to:
  /// **'Multi-camera grid still lives in the reference Android UI. This build provides a single preview.'**
  String get tipMultiBody;

  /// No description provided for @segmentDuration.
  ///
  /// In en, this message translates to:
  /// **'Segment length'**
  String get segmentDuration;

  /// No description provided for @segmentNone.
  ///
  /// In en, this message translates to:
  /// **'No segments'**
  String get segmentNone;

  /// No description provided for @segmentMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String segmentMinutes(int minutes);

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get languageSystem;

  /// No description provided for @waitingUsb.
  ///
  /// In en, this message translates to:
  /// **'Waiting for USB camera'**
  String get waitingUsb;

  /// No description provided for @openFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not open this camera'**
  String get openFailed;

  /// No description provided for @waitingHintEmpty.
  ///
  /// In en, this message translates to:
  /// **'Use an OTG adapter to connect a UVC camera or capture card. Android will ask for USB permission.'**
  String get waitingHintEmpty;

  /// No description provided for @waitingHintDetected.
  ///
  /// In en, this message translates to:
  /// **'A device was detected. Open the list below to choose a camera.'**
  String get waitingHintDetected;

  /// No description provided for @errorHint.
  ///
  /// In en, this message translates to:
  /// **'Check USB permission, or try another cable.'**
  String get errorHint;

  /// No description provided for @selectDevice.
  ///
  /// In en, this message translates to:
  /// **'Select device'**
  String get selectDevice;

  /// No description provided for @retryDevice.
  ///
  /// In en, this message translates to:
  /// **'Retry device'**
  String get retryDevice;

  /// No description provided for @modePhoto.
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get modePhoto;

  /// No description provided for @modeVideo.
  ///
  /// In en, this message translates to:
  /// **'Video'**
  String get modeVideo;

  /// No description provided for @modeAudio.
  ///
  /// In en, this message translates to:
  /// **'Audio'**
  String get modeAudio;

  /// No description provided for @shutter.
  ///
  /// In en, this message translates to:
  /// **'Shutter'**
  String get shutter;

  /// No description provided for @fpsLabel.
  ///
  /// In en, this message translates to:
  /// **'{fps} FPS'**
  String fpsLabel(int fps);

  /// No description provided for @fpsOption.
  ///
  /// In en, this message translates to:
  /// **'{fps} fps'**
  String fpsOption(int fps);

  /// No description provided for @defaultDeviceName.
  ///
  /// In en, this message translates to:
  /// **'USB camera'**
  String get defaultDeviceName;

  /// No description provided for @msgSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get msgSaved;

  /// No description provided for @msgSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save'**
  String get msgSaveFailed;

  /// No description provided for @msgNoDevice.
  ///
  /// In en, this message translates to:
  /// **'No USB camera found'**
  String get msgNoDevice;

  /// No description provided for @msgPreviewNotReady.
  ///
  /// In en, this message translates to:
  /// **'Preview is not ready yet'**
  String get msgPreviewNotReady;

  /// No description provided for @msgCameraError.
  ///
  /// In en, this message translates to:
  /// **'Camera error'**
  String get msgCameraError;

  /// No description provided for @previewStatus.
  ///
  /// In en, this message translates to:
  /// **'{width}×{height} · {format} · {fps}fps'**
  String previewStatus(int width, int height, String format, int fps);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'ar',
    'de',
    'en',
    'es',
    'fr',
    'hi',
    'id',
    'ja',
    'ko',
    'pt',
    'ru',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+script codes are specified.
  switch (locale.languageCode) {
    case 'zh':
      {
        switch (locale.scriptCode) {
          case 'Hant':
            return AppLocalizationsZhHant();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'hi':
      return AppLocalizationsHi();
    case 'id':
      return AppLocalizationsId();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'pt':
      return AppLocalizationsPt();
    case 'ru':
      return AppLocalizationsRu();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
