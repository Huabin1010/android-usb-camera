// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Caméra USB';

  @override
  String get appEngineCredit => 'Moteur caméra basé sur AUSBC (UVC / OpenGL)';

  @override
  String appLicense(String license) {
    return 'Licence $license';
  }

  @override
  String appVersion(String version) {
    return 'Version $version';
  }

  @override
  String get permissionNeeded => 'Accès caméra, micro et photos requis';

  @override
  String get retry => 'Réessayer';

  @override
  String get close => 'Fermer';

  @override
  String get mode => 'Mode';

  @override
  String get devices => 'Appareils';

  @override
  String get hideControls => 'Masquer les commandes';

  @override
  String get noUsbCamera => 'Pas encore de caméra USB';

  @override
  String get workspaceWatch => 'Regarder';

  @override
  String get workspaceCapture => 'Capturer';

  @override
  String get workspaceTune => 'Régler';

  @override
  String get workspaceWatchHint =>
      'Aperçu uniquement. Ouvrez la liste pour changer de caméra.';

  @override
  String get workspaceCaptureHint =>
      'Photo, vidéo et audio avec l’obturateur en bas.';

  @override
  String get workspaceTuneHint => 'Image, vidéo, effets, audio et segments.';

  @override
  String get recordingBlocksMode =>
      'Arrêtez l’enregistrement avant de changer de mode';

  @override
  String get sectionPicture => 'Image';

  @override
  String get sectionVideo => 'Vidéo';

  @override
  String get sectionEffects => 'Effets';

  @override
  String get sectionAudio => 'Audio';

  @override
  String get sectionSettings => 'Réglages';

  @override
  String get autoFocus => 'Mise au point auto';

  @override
  String get autoWhiteBalance => 'Balance des blancs auto';

  @override
  String get resetDefaults => 'Réinitialiser';

  @override
  String get imageBrightness => 'Luminosité';

  @override
  String get imageContrast => 'Contraste';

  @override
  String get imageSaturation => 'Saturation';

  @override
  String get imageHue => 'Teinte';

  @override
  String get imageGain => 'Gain';

  @override
  String get imageGamma => 'Gamma';

  @override
  String get imageSharpness => 'Netteté';

  @override
  String get imageZoom => 'Zoom';

  @override
  String get format => 'Format';

  @override
  String get orientation => 'Orientation';

  @override
  String get resolution => 'Résolution';

  @override
  String get frameRate => 'Images/s';

  @override
  String get resolutionsAfterConnect => 'Affiché après connexion d’un appareil';

  @override
  String get flipUpDown => 'Retournement vertical';

  @override
  String get flipLeftRight => 'Retournement horizontal';

  @override
  String get filter => 'Filtre';

  @override
  String get animation => 'Animation';

  @override
  String get none => 'Aucun';

  @override
  String get filterMono => 'Noir et blanc';

  @override
  String get animSoul => 'Soul';

  @override
  String get animZoom => 'Zoom';

  @override
  String get audioSource => 'Source audio';

  @override
  String get micSystem => 'Micro du téléphone';

  @override
  String get micDevice => 'Micro de l’appareil';

  @override
  String get micAuto => 'Auto';

  @override
  String get listenMic => 'Écouter le micro';

  @override
  String get about => 'À propos';

  @override
  String get tips => 'Astuces';

  @override
  String get tipOtgTitle => 'OTG / USB Host requis';

  @override
  String get tipOtgBody =>
      'Branchez une caméra UVC, un endoscope ou une carte de capture via OTG. Pour les appareils que la caméra système n’ouvre pas.';

  @override
  String get tipPrefsTitle => 'Préférences mémorisées';

  @override
  String get tipPrefsBody =>
      'Mode, résolution, ips, format, orientation, audio et segments sont restaurés au prochain lancement.';

  @override
  String get tipMultiTitle => 'Aperçu multi';

  @override
  String get tipMultiBody =>
      'La grille multi-caméras est dans l’UI Android de référence. Cette version est en aperçu unique.';

  @override
  String get segmentDuration => 'Durée des segments';

  @override
  String get segmentNone => 'Sans segments';

  @override
  String segmentMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String get language => 'Langue';

  @override
  String get languageSystem => 'Par défaut du système';

  @override
  String get appearance => 'Apparence';

  @override
  String get themeSystem => 'Par défaut du système';

  @override
  String get themeLight => 'Clair';

  @override
  String get themeDark => 'Sombre';

  @override
  String get tools => 'Réglages';

  @override
  String get previewPresets => 'Préréglages';

  @override
  String get presetCustom => 'Personnalisé…';

  @override
  String get presetManage => 'Gérer les préréglages';

  @override
  String get presetAddCurrent => 'Ajouter l’actuel';

  @override
  String get presetAdd => 'Ajouter un préréglage';

  @override
  String get presetReset => 'Réinitialiser';

  @override
  String get presetDelete => 'Supprimer';

  @override
  String get presetEmpty => 'Aucun préréglage';

  @override
  String get presetAdded => 'Ajouté';

  @override
  String get presetExists => 'Déjà présent';

  @override
  String get presetPickResolution => 'Choisir la résolution';

  @override
  String get presetPickFps => 'Choisir le fps';

  @override
  String get presetSave => 'Enregistrer comme préréglage';

  @override
  String get presetApply => 'Appliquer';

  @override
  String get waitingUsb => 'En attente de caméra USB';

  @override
  String get openFailed => 'Impossible d’ouvrir cette caméra';

  @override
  String get waitingHintEmpty =>
      'Utilisez un adaptateur OTG pour brancher une caméra UVC ou une carte de capture. Android demandera l’autorisation USB.';

  @override
  String get waitingHintDetected =>
      'Appareil détecté. Ouvrez la liste ci-dessous pour choisir.';

  @override
  String get errorHint =>
      'Vérifiez l’autorisation USB ou essayez un autre câble.';

  @override
  String get selectDevice => 'Choisir l’appareil';

  @override
  String get retryDevice => 'Réessayer l’appareil';

  @override
  String get modePhoto => 'Photo';

  @override
  String get modeVideo => 'Vidéo';

  @override
  String get modeAudio => 'Audio';

  @override
  String get shutter => 'Obturateur';

  @override
  String fpsLabel(int fps) {
    return '$fps FPS';
  }

  @override
  String fpsOption(int fps) {
    return '$fps fps';
  }

  @override
  String get defaultDeviceName => 'Caméra USB';

  @override
  String get msgSaved => 'Enregistré';

  @override
  String get msgSaveFailed => 'Échec de l’enregistrement';

  @override
  String get msgNoDevice => 'Aucune caméra USB trouvée';

  @override
  String get msgPreviewNotReady => 'L’aperçu n’est pas encore prêt';

  @override
  String get msgCameraError => 'Erreur de caméra';

  @override
  String previewStatus(int width, int height, String format, int fps) {
    return '$width×$height · $format · ${fps}fps';
  }
}
