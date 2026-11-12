// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'USB-камера';

  @override
  String get appEngineCredit => 'Движок камеры на базе AUSBC (UVC / OpenGL)';

  @override
  String appLicense(String license) {
    return 'Лицензия $license';
  }

  @override
  String appVersion(String version) {
    return 'Версия $version';
  }

  @override
  String get permissionNeeded => 'Нужен доступ к камере, микрофону и фото';

  @override
  String get retry => 'Повторить';

  @override
  String get close => 'Закрыть';

  @override
  String get mode => 'Режим';

  @override
  String get devices => 'Устройства';

  @override
  String get hideControls => 'Скрыть управление';

  @override
  String get noUsbCamera => 'USB-камера ещё не подключена';

  @override
  String get workspaceWatch => 'Просмотр';

  @override
  String get workspaceCapture => 'Съёмка';

  @override
  String get workspaceTune => 'Настройка';

  @override
  String get workspaceWatchHint =>
      'Только превью. Откройте список, чтобы сменить камеру.';

  @override
  String get workspaceCaptureHint =>
      'Фото, видео и звук с нижней кнопкой затвора.';

  @override
  String get workspaceTuneHint =>
      'Изображение, видео, эффекты, звук и сегменты.';

  @override
  String get recordingBlocksMode => 'Остановите запись перед сменой режима';

  @override
  String get sectionPicture => 'Изображение';

  @override
  String get sectionVideo => 'Видео';

  @override
  String get sectionEffects => 'Эффекты';

  @override
  String get sectionAudio => 'Звук';

  @override
  String get sectionSettings => 'Настройки';

  @override
  String get autoFocus => 'Автофокус';

  @override
  String get autoWhiteBalance => 'Автобаланс белого';

  @override
  String get resetDefaults => 'Сбросить';

  @override
  String get imageBrightness => 'Яркость';

  @override
  String get imageContrast => 'Контраст';

  @override
  String get imageSaturation => 'Насыщенность';

  @override
  String get imageHue => 'Оттенок';

  @override
  String get imageGain => 'Усиление';

  @override
  String get imageGamma => 'Гамма';

  @override
  String get imageSharpness => 'Резкость';

  @override
  String get imageZoom => 'Зум';

  @override
  String get format => 'Формат';

  @override
  String get orientation => 'Ориентация';

  @override
  String get resolution => 'Разрешение';

  @override
  String get frameRate => 'Частота кадров';

  @override
  String get resolutionsAfterConnect => 'Появится после подключения устройства';

  @override
  String get flipUpDown => 'Отразить по вертикали';

  @override
  String get flipLeftRight => 'Отразить по горизонтали';

  @override
  String get filter => 'Фильтр';

  @override
  String get animation => 'Анимация';

  @override
  String get none => 'Нет';

  @override
  String get filterMono => 'Ч/б';

  @override
  String get animSoul => 'Soul';

  @override
  String get animZoom => 'Зум';

  @override
  String get audioSource => 'Источник звука';

  @override
  String get micSystem => 'Микрофон телефона';

  @override
  String get micDevice => 'Микрофон устройства';

  @override
  String get micAuto => 'Авто';

  @override
  String get listenMic => 'Прослушивать микрофон';

  @override
  String get about => 'О приложении';

  @override
  String get tips => 'Подсказки';

  @override
  String get tipOtgTitle => 'Нужен OTG / USB Host';

  @override
  String get tipOtgBody =>
      'Подключите UVC-камеру, эндоскоп или карту захвата через OTG. Для устройств, которые не открывает системная камера.';

  @override
  String get tipPrefsTitle => 'Настройки сохраняются';

  @override
  String get tipPrefsBody =>
      'Режим, разрешение, fps, формат, ориентация, звук и сегменты восстанавливаются при следующем запуске.';

  @override
  String get tipMultiTitle => 'Мультипревью';

  @override
  String get tipMultiBody =>
      'Сетка нескольких камер — в справочном Android UI. В этой сборке одно превью.';

  @override
  String get segmentDuration => 'Длина сегмента';

  @override
  String get segmentNone => 'Без сегментов';

  @override
  String segmentMinutes(int minutes) {
    return '$minutes мин';
  }

  @override
  String get language => 'Язык';

  @override
  String get languageSystem => 'Как в системе';

  @override
  String get waitingUsb => 'Ожидание USB-камеры';

  @override
  String get openFailed => 'Не удалось открыть эту камеру';

  @override
  String get waitingHintEmpty =>
      'Подключите UVC-камеру или карту захвата через OTG. Android запросит разрешение USB.';

  @override
  String get waitingHintDetected =>
      'Устройство обнаружено. Откройте список ниже, чтобы выбрать камеру.';

  @override
  String get errorHint =>
      'Проверьте разрешение USB или попробуйте другой кабель.';

  @override
  String get selectDevice => 'Выбрать устройство';

  @override
  String get retryDevice => 'Повторить устройство';

  @override
  String get modePhoto => 'Фото';

  @override
  String get modeVideo => 'Видео';

  @override
  String get modeAudio => 'Аудио';

  @override
  String get shutter => 'Затвор';

  @override
  String fpsLabel(int fps) {
    return '$fps FPS';
  }

  @override
  String fpsOption(int fps) {
    return '$fps fps';
  }

  @override
  String get defaultDeviceName => 'USB-камера';
}
