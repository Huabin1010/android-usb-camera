// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Câmera USB';

  @override
  String get appEngineCredit =>
      'Motor de câmera baseado em AUSBC (UVC / OpenGL)';

  @override
  String appLicense(String license) {
    return 'Licença $license';
  }

  @override
  String appVersion(String version) {
    return 'Versão $version';
  }

  @override
  String get permissionNeeded =>
      'É necessário acesso à câmera, microfone e fotos';

  @override
  String get retry => 'Tentar de novo';

  @override
  String get close => 'Fechar';

  @override
  String get mode => 'Modo';

  @override
  String get devices => 'Dispositivos';

  @override
  String get hideControls => 'Ocultar controles';

  @override
  String get noUsbCamera => 'Ainda não há câmera USB';

  @override
  String get workspaceWatch => 'Assistir';

  @override
  String get workspaceCapture => 'Capturar';

  @override
  String get workspaceTune => 'Ajustar';

  @override
  String get workspaceWatchHint =>
      'Só pré-visualização. Abra a lista para trocar de câmera.';

  @override
  String get workspaceCaptureHint =>
      'Foto, vídeo e áudio com o obturador inferior.';

  @override
  String get workspaceTuneHint => 'Imagem, vídeo, efeitos, áudio e segmentos.';

  @override
  String get recordingBlocksMode => 'Pare a gravação antes de mudar de modo';

  @override
  String get sectionPicture => 'Imagem';

  @override
  String get sectionVideo => 'Vídeo';

  @override
  String get sectionEffects => 'Efeitos';

  @override
  String get sectionAudio => 'Áudio';

  @override
  String get sectionSettings => 'Configurações';

  @override
  String get autoFocus => 'Foco automático';

  @override
  String get autoWhiteBalance => 'Balanço de branco automático';

  @override
  String get resetDefaults => 'Restaurar padrões';

  @override
  String get imageBrightness => 'Brilho';

  @override
  String get imageContrast => 'Contraste';

  @override
  String get imageSaturation => 'Saturação';

  @override
  String get imageHue => 'Matiz';

  @override
  String get imageGain => 'Ganho';

  @override
  String get imageGamma => 'Gama';

  @override
  String get imageSharpness => 'Nitidez';

  @override
  String get imageZoom => 'Zoom';

  @override
  String get format => 'Formato';

  @override
  String get orientation => 'Orientação';

  @override
  String get resolution => 'Resolução';

  @override
  String get frameRate => 'Taxa de quadros';

  @override
  String get resolutionsAfterConnect => 'Aparece após conectar um dispositivo';

  @override
  String get flipUpDown => 'Inverter vertical';

  @override
  String get flipLeftRight => 'Inverter horizontal';

  @override
  String get filter => 'Filtro';

  @override
  String get animation => 'Animação';

  @override
  String get none => 'Nenhum';

  @override
  String get filterMono => 'Preto e branco';

  @override
  String get animSoul => 'Soul';

  @override
  String get animZoom => 'Zoom';

  @override
  String get audioSource => 'Fonte de áudio';

  @override
  String get micSystem => 'Microfone do telefone';

  @override
  String get micDevice => 'Microfone do dispositivo';

  @override
  String get micAuto => 'Automático';

  @override
  String get listenMic => 'Monitorar microfone';

  @override
  String get about => 'Sobre';

  @override
  String get tips => 'Dicas';

  @override
  String get tipOtgTitle => 'OTG / USB Host necessário';

  @override
  String get tipOtgBody =>
      'Conecte uma câmera UVC, endoscópio ou capturadora com adaptador OTG. Para dispositivos que a câmera do sistema não abre.';

  @override
  String get tipPrefsTitle => 'Preferências lembradas';

  @override
  String get tipPrefsBody =>
      'Modo, resolução, fps, formato, orientação, áudio e segmentos são restaurados na próxima abertura.';

  @override
  String get tipMultiTitle => 'Pré-visualização multi';

  @override
  String get tipMultiBody =>
      'A grade multi-câmera está na UI Android de referência. Esta versão é de pré-visualização única.';

  @override
  String get segmentDuration => 'Duração do segmento';

  @override
  String get segmentNone => 'Sem segmentos';

  @override
  String segmentMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String get language => 'Idioma';

  @override
  String get languageSystem => 'Padrão do sistema';

  @override
  String get waitingUsb => 'Aguardando câmera USB';

  @override
  String get openFailed => 'Não foi possível abrir esta câmera';

  @override
  String get waitingHintEmpty =>
      'Use um adaptador OTG para conectar uma câmera UVC ou capturadora. O Android pedirá permissão USB.';

  @override
  String get waitingHintDetected =>
      'Dispositivo detectado. Abra a lista abaixo para escolher.';

  @override
  String get errorHint => 'Verifique a permissão USB ou tente outro cabo.';

  @override
  String get selectDevice => 'Selecionar dispositivo';

  @override
  String get retryDevice => 'Tentar dispositivo de novo';

  @override
  String get modePhoto => 'Foto';

  @override
  String get modeVideo => 'Vídeo';

  @override
  String get modeAudio => 'Áudio';

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
  String get defaultDeviceName => 'Câmera USB';
}
