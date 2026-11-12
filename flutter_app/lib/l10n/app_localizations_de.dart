// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'USB-Kamera';

  @override
  String get appEngineCredit =>
      'Kamera-Engine basierend auf AUSBC (UVC / OpenGL)';

  @override
  String appLicense(String license) {
    return 'Lizenz $license';
  }

  @override
  String appVersion(String version) {
    return 'Version $version';
  }

  @override
  String get permissionNeeded =>
      'Kamera-, Mikrofon- und Fotoberechtigung erforderlich';

  @override
  String get retry => 'Erneut versuchen';

  @override
  String get close => 'Schließen';

  @override
  String get mode => 'Modus';

  @override
  String get devices => 'Geräte';

  @override
  String get hideControls => 'Steuerung ausblenden';

  @override
  String get noUsbCamera => 'Noch keine USB-Kamera';

  @override
  String get workspaceWatch => 'Ansehen';

  @override
  String get workspaceCapture => 'Aufnehmen';

  @override
  String get workspaceTune => 'Einstellen';

  @override
  String get workspaceWatchHint =>
      'Nur Vorschau. Geräteliste öffnen, um die Kamera zu wechseln.';

  @override
  String get workspaceCaptureHint =>
      'Foto, Video und Audio mit dem Auslöser unten.';

  @override
  String get workspaceTuneHint => 'Bild, Video, Effekte, Audio und Segmente.';

  @override
  String get recordingBlocksMode =>
      'Aufnahme stoppen, bevor der Modus gewechselt wird';

  @override
  String get sectionPicture => 'Bild';

  @override
  String get sectionVideo => 'Video';

  @override
  String get sectionEffects => 'Effekte';

  @override
  String get sectionAudio => 'Audio';

  @override
  String get sectionSettings => 'Einstellungen';

  @override
  String get autoFocus => 'Autofokus';

  @override
  String get autoWhiteBalance => 'Automatischer Weißabgleich';

  @override
  String get resetDefaults => 'Zurücksetzen';

  @override
  String get imageBrightness => 'Helligkeit';

  @override
  String get imageContrast => 'Kontrast';

  @override
  String get imageSaturation => 'Sättigung';

  @override
  String get imageHue => 'Farbton';

  @override
  String get imageGain => 'Verstärkung';

  @override
  String get imageGamma => 'Gamma';

  @override
  String get imageSharpness => 'Schärfe';

  @override
  String get imageZoom => 'Zoom';

  @override
  String get format => 'Format';

  @override
  String get orientation => 'Ausrichtung';

  @override
  String get resolution => 'Auflösung';

  @override
  String get frameRate => 'Bildrate';

  @override
  String get resolutionsAfterConnect => 'Wird nach Geräteanschluss angezeigt';

  @override
  String get flipUpDown => 'Vertikal spiegeln';

  @override
  String get flipLeftRight => 'Horizontal spiegeln';

  @override
  String get filter => 'Filter';

  @override
  String get animation => 'Animation';

  @override
  String get none => 'Keine';

  @override
  String get filterMono => 'Schwarzweiß';

  @override
  String get animSoul => 'Soul';

  @override
  String get animZoom => 'Zoom';

  @override
  String get audioSource => 'Audioquelle';

  @override
  String get micSystem => 'Telefonmikrofon';

  @override
  String get micDevice => 'Gerätemikrofon';

  @override
  String get micAuto => 'Automatisch';

  @override
  String get listenMic => 'Mikrofon abhören';

  @override
  String get about => 'Info';

  @override
  String get tips => 'Tipps';

  @override
  String get tipOtgTitle => 'OTG / USB Host erforderlich';

  @override
  String get tipOtgBody =>
      'Schließen Sie eine UVC-Kamera, ein Endoskop oder eine Capture-Karte per OTG an. Für Geräte, die die Systemkamera nicht öffnet.';

  @override
  String get tipPrefsTitle => 'Einstellungen werden gespeichert';

  @override
  String get tipPrefsBody =>
      'Modus, Auflösung, Bildrate, Format, Ausrichtung, Audio und Segmente werden beim nächsten Start wiederhergestellt.';

  @override
  String get tipMultiTitle => 'Multi-Vorschau';

  @override
  String get tipMultiBody =>
      'Das Multi-Raster liegt in der Referenz-Android-UI. Dieser Build bietet eine Einzelvorschau.';

  @override
  String get segmentDuration => 'Segmentlänge';

  @override
  String get segmentNone => 'Keine Segmente';

  @override
  String segmentMinutes(int minutes) {
    return '$minutes Min.';
  }

  @override
  String get language => 'Sprache';

  @override
  String get languageSystem => 'Systemstandard';

  @override
  String get waitingUsb => 'Warte auf USB-Kamera';

  @override
  String get openFailed => 'Diese Kamera konnte nicht geöffnet werden';

  @override
  String get waitingHintEmpty =>
      'Mit OTG eine UVC-Kamera oder Capture-Karte anschließen. Android fragt nach USB-Berechtigung.';

  @override
  String get waitingHintDetected =>
      'Gerät erkannt. Öffnen Sie die Liste unten zur Auswahl.';

  @override
  String get errorHint =>
      'USB-Berechtigung prüfen oder anderes Kabel versuchen.';

  @override
  String get selectDevice => 'Gerät wählen';

  @override
  String get retryDevice => 'Gerät erneut versuchen';

  @override
  String get modePhoto => 'Foto';

  @override
  String get modeVideo => 'Video';

  @override
  String get modeAudio => 'Audio';

  @override
  String get shutter => 'Auslöser';

  @override
  String fpsLabel(int fps) {
    return '$fps FPS';
  }

  @override
  String fpsOption(int fps) {
    return '$fps fps';
  }

  @override
  String get defaultDeviceName => 'USB-Kamera';

  @override
  String get msgSaved => 'Gespeichert';

  @override
  String get msgSaveFailed => 'Speichern fehlgeschlagen';

  @override
  String get msgNoDevice => 'Keine USB-Kamera gefunden';

  @override
  String get msgPreviewNotReady => 'Vorschau ist noch nicht bereit';

  @override
  String get msgCameraError => 'Kamerafehler';

  @override
  String previewStatus(int width, int height, String format, int fps) {
    return '$width×$height · $format · ${fps}fps';
  }
}
