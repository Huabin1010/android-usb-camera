// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'USB 摄像头';

  @override
  String get appEngineCredit => '相机引擎基于 AUSBC（UVC / OpenGL）';

  @override
  String appLicense(String license) {
    return '许可 $license';
  }

  @override
  String appVersion(String version) {
    return '版本 $version';
  }

  @override
  String get permissionNeeded => '需要相机、麦克风和相册权限';

  @override
  String get retry => '重试';

  @override
  String get close => '关闭';

  @override
  String get mode => '模式';

  @override
  String get devices => '设备';

  @override
  String get hideControls => '隐藏控制';

  @override
  String get noUsbCamera => '还没有 USB 摄像头';

  @override
  String get workspaceWatch => '观看';

  @override
  String get workspaceCapture => '拍摄';

  @override
  String get workspaceTune => '调节';

  @override
  String get workspaceWatchHint => '只看画面。需要时再打开设备列表切换摄像头。';

  @override
  String get workspaceCaptureHint => '拍照、录像、录音，底部快门可用。';

  @override
  String get workspaceTuneHint => '画面、视频、效果、音频和分段设置。';

  @override
  String get recordingBlocksMode => '录像或录音进行中，先停下来再切换模式';

  @override
  String get sectionPicture => '画面';

  @override
  String get sectionVideo => '视频';

  @override
  String get sectionEffects => '效果';

  @override
  String get sectionAudio => '音频';

  @override
  String get sectionSettings => '设置';

  @override
  String get autoFocus => '自动对焦';

  @override
  String get autoWhiteBalance => '自动白平衡';

  @override
  String get resetDefaults => '恢复默认';

  @override
  String get imageBrightness => '亮度';

  @override
  String get imageContrast => '对比度';

  @override
  String get imageSaturation => '饱和度';

  @override
  String get imageHue => '色调';

  @override
  String get imageGain => '增益';

  @override
  String get imageGamma => '伽马';

  @override
  String get imageSharpness => '锐度';

  @override
  String get imageZoom => '变焦';

  @override
  String get format => '格式';

  @override
  String get orientation => '方向';

  @override
  String get resolution => '分辨率';

  @override
  String get frameRate => '帧率';

  @override
  String get resolutionsAfterConnect => '接入设备后显示';

  @override
  String get flipUpDown => '上下翻转';

  @override
  String get flipLeftRight => '左右翻转';

  @override
  String get filter => '滤镜';

  @override
  String get animation => '动画';

  @override
  String get none => '无';

  @override
  String get filterMono => '黑白';

  @override
  String get animSoul => '灵魂';

  @override
  String get animZoom => '缩放';

  @override
  String get audioSource => '音源';

  @override
  String get micSystem => '系统麦克风';

  @override
  String get micDevice => '设备麦克风';

  @override
  String get micAuto => '自动';

  @override
  String get listenMic => '监听麦克风';

  @override
  String get about => '关于';

  @override
  String get tips => '使用提示';

  @override
  String get tipOtgTitle => '需要 OTG / USB Host';

  @override
  String get tipOtgBody => '用转接头把 UVC 摄像头、内窥镜或标准采集卡接到手机。系统相机认不了的设备，才是主场景。';

  @override
  String get tipPrefsTitle => '偏好会记住';

  @override
  String get tipPrefsBody => '工作台模式、分辨率、帧率、格式、方向、音源和分段会在下次启动时恢复。';

  @override
  String get tipMultiTitle => '多路预览';

  @override
  String get tipMultiBody => '多路网格仍在参考工程的 Android 界面里。本版先提供单路预览。';

  @override
  String get segmentDuration => '分段时长';

  @override
  String get segmentNone => '不分段';

  @override
  String segmentMinutes(int minutes) {
    return '$minutes 分钟';
  }

  @override
  String get language => '语言';

  @override
  String get languageSystem => '跟随系统';

  @override
  String get waitingUsb => '等待 USB 摄像头';

  @override
  String get openFailed => '打不开这台摄像头';

  @override
  String get waitingHintEmpty => '用 OTG 转接头接上 UVC 摄像头或采集卡。插上后系统会询问 USB 权限。';

  @override
  String get waitingHintDetected => '已检测到设备，点下面打开列表选择摄像头。';

  @override
  String get errorHint => '检查 USB 权限，或换一根线再试。';

  @override
  String get selectDevice => '选择设备';

  @override
  String get retryDevice => '重试设备';

  @override
  String get modePhoto => '拍照';

  @override
  String get modeVideo => '录像';

  @override
  String get modeAudio => '录音';

  @override
  String get shutter => '快门';

  @override
  String fpsLabel(int fps) {
    return '$fps FPS';
  }

  @override
  String fpsOption(int fps) {
    return '$fps fps';
  }

  @override
  String get defaultDeviceName => 'USB 摄像头';
}

/// The translations for Chinese, using the Han script (`zh_Hant`).
class AppLocalizationsZhHant extends AppLocalizationsZh {
  AppLocalizationsZhHant() : super('zh_Hant');

  @override
  String get appTitle => 'USB 攝影機';

  @override
  String get appEngineCredit => '相機引擎基於 AUSBC（UVC / OpenGL）';

  @override
  String appLicense(String license) {
    return '授權 $license';
  }

  @override
  String appVersion(String version) {
    return '版本 $version';
  }

  @override
  String get permissionNeeded => '需要相機、麥克風與相簿權限';

  @override
  String get retry => '重試';

  @override
  String get close => '關閉';

  @override
  String get mode => '模式';

  @override
  String get devices => '裝置';

  @override
  String get hideControls => '隱藏控制';

  @override
  String get noUsbCamera => '尚未連接 USB 攝影機';

  @override
  String get workspaceWatch => '觀看';

  @override
  String get workspaceCapture => '拍攝';

  @override
  String get workspaceTune => '調整';

  @override
  String get workspaceWatchHint => '只看畫面。需要時再開啟裝置列表切換攝影機。';

  @override
  String get workspaceCaptureHint => '拍照、錄影、錄音，底部快門可用。';

  @override
  String get workspaceTuneHint => '畫面、影片、效果、音訊與分段設定。';

  @override
  String get recordingBlocksMode => '錄影或錄音進行中，請先停止再切換模式';

  @override
  String get sectionPicture => '畫面';

  @override
  String get sectionVideo => '影片';

  @override
  String get sectionEffects => '效果';

  @override
  String get sectionAudio => '音訊';

  @override
  String get sectionSettings => '設定';

  @override
  String get autoFocus => '自動對焦';

  @override
  String get autoWhiteBalance => '自動白平衡';

  @override
  String get resetDefaults => '恢復預設';

  @override
  String get imageBrightness => '亮度';

  @override
  String get imageContrast => '對比';

  @override
  String get imageSaturation => '飽和度';

  @override
  String get imageHue => '色調';

  @override
  String get imageGain => '增益';

  @override
  String get imageGamma => '伽馬';

  @override
  String get imageSharpness => '銳利度';

  @override
  String get imageZoom => '變焦';

  @override
  String get format => '格式';

  @override
  String get orientation => '方向';

  @override
  String get resolution => '解析度';

  @override
  String get frameRate => '幀率';

  @override
  String get resolutionsAfterConnect => '連接裝置後顯示';

  @override
  String get flipUpDown => '上下翻轉';

  @override
  String get flipLeftRight => '左右翻轉';

  @override
  String get filter => '濾鏡';

  @override
  String get animation => '動畫';

  @override
  String get none => '無';

  @override
  String get filterMono => '黑白';

  @override
  String get animSoul => '靈魂';

  @override
  String get animZoom => '縮放';

  @override
  String get audioSource => '音源';

  @override
  String get micSystem => '系統麥克風';

  @override
  String get micDevice => '裝置麥克風';

  @override
  String get micAuto => '自動';

  @override
  String get listenMic => '監聽麥克風';

  @override
  String get about => '關於';

  @override
  String get tips => '使用提示';

  @override
  String get tipOtgTitle => '需要 OTG / USB Host';

  @override
  String get tipOtgBody => '用轉接頭把 UVC 攝影機、內視鏡或擷取卡接到手機。系統相機無法開啟的裝置，才是主要場景。';

  @override
  String get tipPrefsTitle => '偏好會記住';

  @override
  String get tipPrefsBody => '工作台模式、解析度、幀率、格式、方向、音源與分段會在下次啟動時還原。';

  @override
  String get tipMultiTitle => '多路預覽';

  @override
  String get tipMultiBody => '多路網格仍在參考工程的 Android 介面。本版先提供單路預覽。';

  @override
  String get segmentDuration => '分段時長';

  @override
  String get segmentNone => '不分段';

  @override
  String segmentMinutes(int minutes) {
    return '$minutes 分鐘';
  }

  @override
  String get language => '語言';

  @override
  String get languageSystem => '跟隨系統';

  @override
  String get waitingUsb => '等待 USB 攝影機';

  @override
  String get openFailed => '無法開啟這台攝影機';

  @override
  String get waitingHintEmpty => '用 OTG 轉接頭接上 UVC 攝影機或擷取卡。插入後系統會詢問 USB 權限。';

  @override
  String get waitingHintDetected => '已偵測到裝置，點下方開啟列表選擇攝影機。';

  @override
  String get errorHint => '請檢查 USB 權限，或換一條線再試。';

  @override
  String get selectDevice => '選擇裝置';

  @override
  String get retryDevice => '重試裝置';

  @override
  String get modePhoto => '拍照';

  @override
  String get modeVideo => '錄影';

  @override
  String get modeAudio => '錄音';

  @override
  String get shutter => '快門';

  @override
  String fpsLabel(int fps) {
    return '$fps FPS';
  }

  @override
  String fpsOption(int fps) {
    return '$fps fps';
  }

  @override
  String get defaultDeviceName => 'USB 攝影機';
}
