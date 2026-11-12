import 'package:ausbc_flutter/l10n/app_localizations.dart';
import 'package:flutter/widgets.dart';

import 'app_info.dart';

export 'package:ausbc_flutter/l10n/app_localizations.dart';

extension AppL10nX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

extension AppLocalizationsLabels on AppLocalizations {
  String workspaceLabel(String id) {
    return switch (id) {
      'capture' => workspaceCapture,
      'tune' => workspaceTune,
      _ => workspaceWatch,
    };
  }

  String workspaceHint(String id) {
    return switch (id) {
      'capture' => workspaceCaptureHint,
      'tune' => workspaceTuneHint,
      _ => workspaceWatchHint,
    };
  }

  String sectionTitle(String id) {
    return switch (id) {
      'picture' => sectionPicture,
      'video' => sectionVideo,
      'effects' => sectionEffects,
      'audio' => sectionAudio,
      _ => sectionSettings,
    };
  }

  String imageLabel(String key) {
    return switch (key) {
      'brightness' => imageBrightness,
      'contrast' => imageContrast,
      'saturation' => imageSaturation,
      'hue' => imageHue,
      'gain' => imageGain,
      'gamma' => imageGamma,
      'sharpness' => imageSharpness,
      'zoom' => imageZoom,
      _ => key,
    };
  }

  String rotateLabel(String key) {
    return switch (key) {
      'ANGLE_0' => '0°',
      'ANGLE_90' => '90°',
      'ANGLE_180' => '180°',
      'ANGLE_270' => '270°',
      'FLIP_UP_DOWN' => flipUpDown,
      'FLIP_LEFT_RIGHT' => flipLeftRight,
      _ => key,
    };
  }

  String connectionTitle(String connection) {
    return connection == 'error' ? openFailed : waitingUsb;
  }

  String aboutSubtitle(String version) {
    return '${appVersion(version)}\n$appEngineCredit\n${appLicense(AppInfo.license)}';
  }
}
