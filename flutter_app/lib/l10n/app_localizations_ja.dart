// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'USBカメラ';

  @override
  String get appEngineCredit => 'カメラエンジンは AUSBC（UVC / OpenGL）ベース';

  @override
  String appLicense(String license) {
    return 'ライセンス $license';
  }

  @override
  String appVersion(String version) {
    return 'バージョン $version';
  }

  @override
  String get permissionNeeded => 'カメラ、マイク、写真へのアクセスが必要です';

  @override
  String get retry => '再試行';

  @override
  String get close => '閉じる';

  @override
  String get mode => 'モード';

  @override
  String get devices => 'デバイス';

  @override
  String get hideControls => 'コントロールを隠す';

  @override
  String get noUsbCamera => 'USBカメラがありません';

  @override
  String get workspaceWatch => '視聴';

  @override
  String get workspaceCapture => '撮影';

  @override
  String get workspaceTune => '調整';

  @override
  String get workspaceWatchHint => 'プレビューのみ。切替時はデバイス一覧を開きます。';

  @override
  String get workspaceCaptureHint => '写真・動画・音声。下部シャッターを使用。';

  @override
  String get workspaceTuneHint => '映像、動画、効果、音声、分割設定。';

  @override
  String get recordingBlocksMode => '録画/録音中はモードを切り替えられません';

  @override
  String get sectionPicture => '映像';

  @override
  String get sectionVideo => '動画';

  @override
  String get sectionEffects => '効果';

  @override
  String get sectionAudio => '音声';

  @override
  String get sectionSettings => '設定';

  @override
  String get autoFocus => 'オートフォーカス';

  @override
  String get autoWhiteBalance => 'オートホワイトバランス';

  @override
  String get resetDefaults => 'デフォルトに戻す';

  @override
  String get imageBrightness => '明るさ';

  @override
  String get imageContrast => 'コントラスト';

  @override
  String get imageSaturation => '彩度';

  @override
  String get imageHue => '色相';

  @override
  String get imageGain => 'ゲイン';

  @override
  String get imageGamma => 'ガンマ';

  @override
  String get imageSharpness => 'シャープネス';

  @override
  String get imageZoom => 'ズーム';

  @override
  String get format => '形式';

  @override
  String get orientation => '向き';

  @override
  String get resolution => '解像度';

  @override
  String get frameRate => 'フレームレート';

  @override
  String get resolutionsAfterConnect => '接続後に表示';

  @override
  String get flipUpDown => '上下反転';

  @override
  String get flipLeftRight => '左右反転';

  @override
  String get filter => 'フィルター';

  @override
  String get animation => 'アニメーション';

  @override
  String get none => 'なし';

  @override
  String get filterMono => 'モノクロ';

  @override
  String get animSoul => 'ソウル';

  @override
  String get animZoom => 'ズーム';

  @override
  String get audioSource => '音声入力';

  @override
  String get micSystem => '端末マイク';

  @override
  String get micDevice => 'デバイスマイク';

  @override
  String get micAuto => '自動';

  @override
  String get listenMic => 'マイクをモニター';

  @override
  String get about => '情報';

  @override
  String get tips => 'ヒント';

  @override
  String get tipOtgTitle => 'OTG / USB Host が必要';

  @override
  String get tipOtgBody => 'OTGアダプタでUVCカメラやキャプチャカードを接続。システムカメラが開けない機器向けです。';

  @override
  String get tipPrefsTitle => '設定を記憶';

  @override
  String get tipPrefsBody => 'モード、解像度、フレームレート、形式、向き、音声、分割は次回起動時に復元されます。';

  @override
  String get tipMultiTitle => 'マルチカメラ';

  @override
  String get tipMultiBody => 'マルチグリッドは参考Android UIにあります。本ビルドは単一プレビューです。';

  @override
  String get segmentDuration => '分割長';

  @override
  String get segmentNone => '分割なし';

  @override
  String segmentMinutes(int minutes) {
    return '$minutes 分';
  }

  @override
  String get language => '言語';

  @override
  String get languageSystem => 'システム既定';

  @override
  String get appearance => '外観';

  @override
  String get themeSystem => 'システム既定';

  @override
  String get themeLight => 'ライト';

  @override
  String get themeDark => 'ダーク';

  @override
  String get tools => '調整';

  @override
  String get previewPresets => 'プレビュープリセット';

  @override
  String get presetCustom => 'カスタム…';

  @override
  String get presetManage => 'プリセット管理';

  @override
  String get presetAddCurrent => '現在の設定を追加';

  @override
  String get presetAdd => 'プリセットを追加';

  @override
  String get presetReset => 'デフォルトに戻す';

  @override
  String get presetDelete => '削除';

  @override
  String get presetEmpty => 'プリセットがありません';

  @override
  String get presetAdded => '追加しました';

  @override
  String get presetExists => '既にあります';

  @override
  String get presetPickResolution => '解像度を選択';

  @override
  String get presetPickFps => 'フレームレートを選択';

  @override
  String get presetSave => 'プリセットに保存';

  @override
  String get presetApply => '適用';

  @override
  String get waitingUsb => 'USBカメラを待機中';

  @override
  String get openFailed => 'このカメラを開けません';

  @override
  String get waitingHintEmpty => 'OTGでUVCカメラやキャプチャカードを接続。USB許可を求められます。';

  @override
  String get waitingHintDetected => 'デバイスを検出。下の一覧から選択してください。';

  @override
  String get errorHint => 'USB許可を確認するか、別のケーブルを試してください。';

  @override
  String get selectDevice => 'デバイスを選択';

  @override
  String get retryDevice => '再試行';

  @override
  String get modePhoto => '写真';

  @override
  String get modeVideo => '動画';

  @override
  String get modeAudio => '音声';

  @override
  String get shutter => 'シャッター';

  @override
  String fpsLabel(int fps) {
    return '$fps FPS';
  }

  @override
  String fpsOption(int fps) {
    return '$fps fps';
  }

  @override
  String get defaultDeviceName => 'USBカメラ';

  @override
  String get msgSaved => '保存しました';

  @override
  String get msgSaveFailed => '保存に失敗しました';

  @override
  String get msgNoDevice => 'USBカメラが見つかりません';

  @override
  String get msgPreviewNotReady => 'プレビューの準備ができていません';

  @override
  String get msgCameraError => 'カメラエラー';

  @override
  String previewStatus(int width, int height, String format, int fps) {
    return '$width×$height · $format · ${fps}fps';
  }
}
