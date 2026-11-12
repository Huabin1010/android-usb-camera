// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Cámara USB';

  @override
  String get appEngineCredit =>
      'Motor de cámara basado en AUSBC (UVC / OpenGL)';

  @override
  String appLicense(String license) {
    return 'Licencia $license';
  }

  @override
  String appVersion(String version) {
    return 'Versión $version';
  }

  @override
  String get permissionNeeded =>
      'Se requiere acceso a cámara, micrófono y fotos';

  @override
  String get retry => 'Reintentar';

  @override
  String get close => 'Cerrar';

  @override
  String get mode => 'Modo';

  @override
  String get devices => 'Dispositivos';

  @override
  String get hideControls => 'Ocultar controles';

  @override
  String get noUsbCamera => 'Aún no hay cámara USB';

  @override
  String get workspaceWatch => 'Ver';

  @override
  String get workspaceCapture => 'Capturar';

  @override
  String get workspaceTune => 'Ajustar';

  @override
  String get workspaceWatchHint =>
      'Solo vista previa. Abre la lista para cambiar de cámara.';

  @override
  String get workspaceCaptureHint =>
      'Foto, vídeo y audio con el obturador inferior.';

  @override
  String get workspaceTuneHint => 'Imagen, vídeo, efectos, audio y segmentos.';

  @override
  String get recordingBlocksMode =>
      'Detén la grabación antes de cambiar de modo';

  @override
  String get sectionPicture => 'Imagen';

  @override
  String get sectionVideo => 'Vídeo';

  @override
  String get sectionEffects => 'Efectos';

  @override
  String get sectionAudio => 'Audio';

  @override
  String get sectionSettings => 'Ajustes';

  @override
  String get autoFocus => 'Enfoque automático';

  @override
  String get autoWhiteBalance => 'Balance de blancos automático';

  @override
  String get resetDefaults => 'Restablecer';

  @override
  String get imageBrightness => 'Brillo';

  @override
  String get imageContrast => 'Contraste';

  @override
  String get imageSaturation => 'Saturación';

  @override
  String get imageHue => 'Tono';

  @override
  String get imageGain => 'Ganancia';

  @override
  String get imageGamma => 'Gamma';

  @override
  String get imageSharpness => 'Nitidez';

  @override
  String get imageZoom => 'Zoom';

  @override
  String get format => 'Formato';

  @override
  String get orientation => 'Orientación';

  @override
  String get resolution => 'Resolución';

  @override
  String get frameRate => 'Fotogramas';

  @override
  String get resolutionsAfterConnect =>
      'Se muestra tras conectar un dispositivo';

  @override
  String get flipUpDown => 'Voltear vertical';

  @override
  String get flipLeftRight => 'Voltear horizontal';

  @override
  String get filter => 'Filtro';

  @override
  String get animation => 'Animación';

  @override
  String get none => 'Ninguno';

  @override
  String get filterMono => 'Blanco y negro';

  @override
  String get animSoul => 'Soul';

  @override
  String get animZoom => 'Zoom';

  @override
  String get audioSource => 'Fuente de audio';

  @override
  String get micSystem => 'Micrófono del teléfono';

  @override
  String get micDevice => 'Micrófono del dispositivo';

  @override
  String get micAuto => 'Automático';

  @override
  String get listenMic => 'Monitorear micrófono';

  @override
  String get about => 'Acerca de';

  @override
  String get tips => 'Consejos';

  @override
  String get tipOtgTitle => 'Se requiere OTG / USB Host';

  @override
  String get tipOtgBody =>
      'Conecta una cámara UVC, endoscopio o capturadora con adaptador OTG. Para dispositivos que la cámara del sistema no abre.';

  @override
  String get tipPrefsTitle => 'Preferencias guardadas';

  @override
  String get tipPrefsBody =>
      'Modo, resolución, fps, formato, orientación, audio y segmentos se restauran al reiniciar.';

  @override
  String get tipMultiTitle => 'Vista multi-cámara';

  @override
  String get tipMultiBody =>
      'La cuadrícula multi-cámara está en la UI Android de referencia. Esta versión es de vista única.';

  @override
  String get segmentDuration => 'Duración del segmento';

  @override
  String get segmentNone => 'Sin segmentos';

  @override
  String segmentMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String get language => 'Idioma';

  @override
  String get languageSystem => 'Predeterminado del sistema';

  @override
  String get waitingUsb => 'Esperando cámara USB';

  @override
  String get openFailed => 'No se pudo abrir esta cámara';

  @override
  String get waitingHintEmpty =>
      'Usa un adaptador OTG para conectar una cámara UVC o capturadora. Android pedirá permiso USB.';

  @override
  String get waitingHintDetected =>
      'Dispositivo detectado. Ábrelo abajo para elegir la cámara.';

  @override
  String get errorHint => 'Comprueba el permiso USB o prueba otro cable.';

  @override
  String get selectDevice => 'Elegir dispositivo';

  @override
  String get retryDevice => 'Reintentar dispositivo';

  @override
  String get modePhoto => 'Foto';

  @override
  String get modeVideo => 'Vídeo';

  @override
  String get modeAudio => 'Audio';

  @override
  String get shutter => 'Obturador';

  @override
  String fpsLabel(int fps) {
    return '$fps FPS';
  }

  @override
  String fpsOption(int fps) {
    return '$fps fps';
  }

  @override
  String get defaultDeviceName => 'Cámara USB';

  @override
  String get msgSaved => 'Guardado';

  @override
  String get msgSaveFailed => 'No se pudo guardar';

  @override
  String get msgNoDevice => 'No se encontró cámara USB';

  @override
  String get msgPreviewNotReady => 'La vista previa aún no está lista';

  @override
  String get msgCameraError => 'Error de cámara';

  @override
  String previewStatus(int width, int height, String format, int fps) {
    return '$width×$height · $format · ${fps}fps';
  }
}
