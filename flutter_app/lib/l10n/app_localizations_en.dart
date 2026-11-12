// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'USB Camera';

  @override
  String get appEngineCredit => 'Camera engine based on AUSBC (UVC / OpenGL)';

  @override
  String appLicense(String license) {
    return 'License $license';
  }

  @override
  String appVersion(String version) {
    return 'Version $version';
  }

  @override
  String get permissionNeeded =>
      'Camera, microphone, and photos access are required';

  @override
  String get retry => 'Retry';

  @override
  String get close => 'Close';

  @override
  String get mode => 'Mode';

  @override
  String get devices => 'Devices';

  @override
  String get hideControls => 'Hide controls';

  @override
  String get noUsbCamera => 'No USB camera yet';

  @override
  String get workspaceWatch => 'Watch';

  @override
  String get workspaceCapture => 'Capture';

  @override
  String get workspaceTune => 'Tune';

  @override
  String get workspaceWatchHint =>
      'Preview only. Open the device list when you need to switch cameras.';

  @override
  String get workspaceCaptureHint =>
      'Photo, video, and audio with the shutter bar.';

  @override
  String get workspaceTuneHint =>
      'Picture, video, effects, audio, and segment settings.';

  @override
  String get recordingBlocksMode =>
      'Stop recording or audio capture before switching modes';

  @override
  String get sectionPicture => 'Picture';

  @override
  String get sectionVideo => 'Video';

  @override
  String get sectionEffects => 'Effects';

  @override
  String get sectionAudio => 'Audio';

  @override
  String get sectionSettings => 'Settings';

  @override
  String get autoFocus => 'Auto focus';

  @override
  String get autoWhiteBalance => 'Auto white balance';

  @override
  String get resetDefaults => 'Reset to defaults';

  @override
  String get imageBrightness => 'Brightness';

  @override
  String get imageContrast => 'Contrast';

  @override
  String get imageSaturation => 'Saturation';

  @override
  String get imageHue => 'Hue';

  @override
  String get imageGain => 'Gain';

  @override
  String get imageGamma => 'Gamma';

  @override
  String get imageSharpness => 'Sharpness';

  @override
  String get imageZoom => 'Zoom';

  @override
  String get format => 'Format';

  @override
  String get orientation => 'Orientation';

  @override
  String get resolution => 'Resolution';

  @override
  String get frameRate => 'Frame rate';

  @override
  String get resolutionsAfterConnect => 'Shown after a device is connected';

  @override
  String get flipUpDown => 'Flip vertical';

  @override
  String get flipLeftRight => 'Flip horizontal';

  @override
  String get filter => 'Filter';

  @override
  String get animation => 'Animation';

  @override
  String get none => 'None';

  @override
  String get filterMono => 'Black & white';

  @override
  String get animSoul => 'Soul';

  @override
  String get animZoom => 'Zoom';

  @override
  String get audioSource => 'Audio source';

  @override
  String get micSystem => 'Phone microphone';

  @override
  String get micDevice => 'Device microphone';

  @override
  String get micAuto => 'Auto';

  @override
  String get listenMic => 'Monitor microphone';

  @override
  String get about => 'About';

  @override
  String get tips => 'Tips';

  @override
  String get tipOtgTitle => 'OTG / USB Host required';

  @override
  String get tipOtgBody =>
      'Connect a UVC camera, endoscope, or capture card with an OTG adapter. This app is for devices the system camera cannot open.';

  @override
  String get tipPrefsTitle => 'Preferences are remembered';

  @override
  String get tipPrefsBody =>
      'Workspace mode, resolution, frame rate, format, orientation, audio source, and segments restore on the next launch.';

  @override
  String get tipMultiTitle => 'Multi-camera preview';

  @override
  String get tipMultiBody =>
      'Multi-camera grid still lives in the reference Android UI. This build provides a single preview.';

  @override
  String get segmentDuration => 'Segment length';

  @override
  String get segmentNone => 'No segments';

  @override
  String segmentMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String get language => 'Language';

  @override
  String get languageSystem => 'System default';

  @override
  String get appearance => 'Appearance';

  @override
  String get themeSystem => 'System default';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get tools => 'Controls';

  @override
  String get previewPresets => 'Preview presets';

  @override
  String get presetCustom => 'Custom…';

  @override
  String get presetManage => 'Manage presets';

  @override
  String get presetAddCurrent => 'Add current setup';

  @override
  String get presetAdd => 'Add preset';

  @override
  String get presetReset => 'Reset default presets';

  @override
  String get presetDelete => 'Remove';

  @override
  String get presetEmpty => 'No presets yet';

  @override
  String get presetAdded => 'Added to presets';

  @override
  String get presetExists => 'Already in presets';

  @override
  String get presetPickResolution => 'Choose resolution';

  @override
  String get presetPickFps => 'Choose frame rate';

  @override
  String get presetSave => 'Save as preset';

  @override
  String get presetApply => 'Apply';

  @override
  String get waitingUsb => 'Waiting for USB camera';

  @override
  String get openFailed => 'Could not open this camera';

  @override
  String get waitingHintEmpty =>
      'Use an OTG adapter to connect a UVC camera or capture card. Android will ask for USB permission.';

  @override
  String get waitingHintDetected =>
      'A device was detected. Open the list below to choose a camera.';

  @override
  String get errorHint => 'Check USB permission, or try another cable.';

  @override
  String get selectDevice => 'Select device';

  @override
  String get retryDevice => 'Retry device';

  @override
  String get modePhoto => 'Photo';

  @override
  String get modeVideo => 'Video';

  @override
  String get modeAudio => 'Audio';

  @override
  String get shutter => 'Shutter';

  @override
  String fpsLabel(int fps) {
    return '$fps FPS';
  }

  @override
  String fpsOption(int fps) {
    return '$fps fps';
  }

  @override
  String get defaultDeviceName => 'USB camera';

  @override
  String get msgSaved => 'Saved';

  @override
  String get msgSaveFailed => 'Could not save';

  @override
  String get msgNoDevice => 'No USB camera found';

  @override
  String get msgPreviewNotReady => 'Preview is not ready yet';

  @override
  String get msgCameraError => 'Camera error';

  @override
  String previewStatus(int width, int height, String format, int fps) {
    return '$width×$height · $format · ${fps}fps';
  }
}
