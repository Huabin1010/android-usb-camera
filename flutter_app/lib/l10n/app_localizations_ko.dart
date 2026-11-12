// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => 'USB 카메라';

  @override
  String get appEngineCredit => '카메라 엔진: AUSBC(UVC / OpenGL)';

  @override
  String appLicense(String license) {
    return '라이선스 $license';
  }

  @override
  String appVersion(String version) {
    return '버전 $version';
  }

  @override
  String get permissionNeeded => '카메라, 마이크, 사진 권한이 필요합니다';

  @override
  String get retry => '다시 시도';

  @override
  String get close => '닫기';

  @override
  String get mode => '모드';

  @override
  String get devices => '장치';

  @override
  String get hideControls => '컨트롤 숨기기';

  @override
  String get noUsbCamera => 'USB 카메라가 없습니다';

  @override
  String get workspaceWatch => '시청';

  @override
  String get workspaceCapture => '촬영';

  @override
  String get workspaceTune => '조절';

  @override
  String get workspaceWatchHint => '미리보기만. 필요하면 장치 목록에서 전환하세요.';

  @override
  String get workspaceCaptureHint => '사진, 동영상, 녹음. 하단 셔터 사용.';

  @override
  String get workspaceTuneHint => '화면, 동영상, 효과, 오디오, 분할 설정.';

  @override
  String get recordingBlocksMode => '녹화/녹음 중에는 모드를 바꿀 수 없습니다';

  @override
  String get sectionPicture => '화면';

  @override
  String get sectionVideo => '동영상';

  @override
  String get sectionEffects => '효과';

  @override
  String get sectionAudio => '오디오';

  @override
  String get sectionSettings => '설정';

  @override
  String get autoFocus => '자동 초점';

  @override
  String get autoWhiteBalance => '자동 화이트밸런스';

  @override
  String get resetDefaults => '기본값으로';

  @override
  String get imageBrightness => '밝기';

  @override
  String get imageContrast => '대비';

  @override
  String get imageSaturation => '채도';

  @override
  String get imageHue => '색조';

  @override
  String get imageGain => '게인';

  @override
  String get imageGamma => '감마';

  @override
  String get imageSharpness => '선명도';

  @override
  String get imageZoom => '줌';

  @override
  String get format => '형식';

  @override
  String get orientation => '방향';

  @override
  String get resolution => '해상도';

  @override
  String get frameRate => '프레임 속도';

  @override
  String get resolutionsAfterConnect => '장치 연결 후 표시';

  @override
  String get flipUpDown => '상하 반전';

  @override
  String get flipLeftRight => '좌우 반전';

  @override
  String get filter => '필터';

  @override
  String get animation => '애니메이션';

  @override
  String get none => '없음';

  @override
  String get filterMono => '흑백';

  @override
  String get animSoul => '소울';

  @override
  String get animZoom => '줌';

  @override
  String get audioSource => '오디오 소스';

  @override
  String get micSystem => '휴대폰 마이크';

  @override
  String get micDevice => '장치 마이크';

  @override
  String get micAuto => '자동';

  @override
  String get listenMic => '마이크 모니터';

  @override
  String get about => '정보';

  @override
  String get tips => '팁';

  @override
  String get tipOtgTitle => 'OTG / USB Host 필요';

  @override
  String get tipOtgBody =>
      'OTG로 UVC 카메라·내시경·캡처 카드를 연결하세요. 시스템 카메라가 열지 못하는 장치용입니다.';

  @override
  String get tipPrefsTitle => '환경설정 저장';

  @override
  String get tipPrefsBody => '모드, 해상도, 프레임 속도, 형식, 방향, 오디오, 분할이 다음 실행에 복원됩니다.';

  @override
  String get tipMultiTitle => '다중 미리보기';

  @override
  String get tipMultiBody => '다중 그리드는 참고 Android UI에 있습니다. 이 빌드는 단일 미리보기입니다.';

  @override
  String get segmentDuration => '분할 길이';

  @override
  String get segmentNone => '분할 없음';

  @override
  String segmentMinutes(int minutes) {
    return '$minutes분';
  }

  @override
  String get language => '언어';

  @override
  String get languageSystem => '시스템 기본';

  @override
  String get waitingUsb => 'USB 카메라 대기 중';

  @override
  String get openFailed => '이 카메라를 열 수 없습니다';

  @override
  String get waitingHintEmpty => 'OTG로 UVC 카메라나 캡처 카드를 연결하세요. USB 권한을 요청합니다.';

  @override
  String get waitingHintDetected => '장치가 감지되었습니다. 아래에서 선택하세요.';

  @override
  String get errorHint => 'USB 권한을 확인하거나 다른 케이블을 사용해 보세요.';

  @override
  String get selectDevice => '장치 선택';

  @override
  String get retryDevice => '장치 다시 시도';

  @override
  String get modePhoto => '사진';

  @override
  String get modeVideo => '동영상';

  @override
  String get modeAudio => '녹음';

  @override
  String get shutter => '셔터';

  @override
  String fpsLabel(int fps) {
    return '$fps FPS';
  }

  @override
  String fpsOption(int fps) {
    return '$fps fps';
  }

  @override
  String get defaultDeviceName => 'USB 카메라';

  @override
  String get msgSaved => '저장됨';

  @override
  String get msgSaveFailed => '저장하지 못했습니다';

  @override
  String get msgNoDevice => 'USB 카메라를 찾을 수 없습니다';

  @override
  String get msgPreviewNotReady => '미리보기가 아직 준비되지 않았습니다';

  @override
  String get msgCameraError => '카메라 오류';

  @override
  String previewStatus(int width, int height, String format, int fps) {
    return '$width×$height · $format · ${fps}fps';
  }
}
