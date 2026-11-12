// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get appTitle => 'Kamera USB';

  @override
  String get appEngineCredit => 'Mesin kamera berbasis AUSBC (UVC / OpenGL)';

  @override
  String appLicense(String license) {
    return 'Lisensi $license';
  }

  @override
  String appVersion(String version) {
    return 'Versi $version';
  }

  @override
  String get permissionNeeded => 'Diperlukan akses kamera, mikrofon, dan foto';

  @override
  String get retry => 'Coba lagi';

  @override
  String get close => 'Tutup';

  @override
  String get mode => 'Mode';

  @override
  String get devices => 'Perangkat';

  @override
  String get hideControls => 'Sembunyikan kontrol';

  @override
  String get noUsbCamera => 'Belum ada kamera USB';

  @override
  String get workspaceWatch => 'Tonton';

  @override
  String get workspaceCapture => 'Rekam';

  @override
  String get workspaceTune => 'Sesuaikan';

  @override
  String get workspaceWatchHint =>
      'Hanya pratinjau. Buka daftar untuk ganti kamera.';

  @override
  String get workspaceCaptureHint =>
      'Foto, video, dan audio dengan tombol rana bawah.';

  @override
  String get workspaceTuneHint => 'Gambar, video, efek, audio, dan segmen.';

  @override
  String get recordingBlocksMode => 'Hentikan rekaman sebelum mengganti mode';

  @override
  String get sectionPicture => 'Gambar';

  @override
  String get sectionVideo => 'Video';

  @override
  String get sectionEffects => 'Efek';

  @override
  String get sectionAudio => 'Audio';

  @override
  String get sectionSettings => 'Pengaturan';

  @override
  String get autoFocus => 'Fokus otomatis';

  @override
  String get autoWhiteBalance => 'White balance otomatis';

  @override
  String get resetDefaults => 'Pulihkan default';

  @override
  String get imageBrightness => 'Kecerahan';

  @override
  String get imageContrast => 'Kontras';

  @override
  String get imageSaturation => 'Saturasi';

  @override
  String get imageHue => 'Hue';

  @override
  String get imageGain => 'Gain';

  @override
  String get imageGamma => 'Gamma';

  @override
  String get imageSharpness => 'Ketajaman';

  @override
  String get imageZoom => 'Zoom';

  @override
  String get format => 'Format';

  @override
  String get orientation => 'Orientasi';

  @override
  String get resolution => 'Resolusi';

  @override
  String get frameRate => 'Frame rate';

  @override
  String get resolutionsAfterConnect =>
      'Ditampilkan setelah perangkat terhubung';

  @override
  String get flipUpDown => 'Balik vertikal';

  @override
  String get flipLeftRight => 'Balik horizontal';

  @override
  String get filter => 'Filter';

  @override
  String get animation => 'Animasi';

  @override
  String get none => 'Tidak ada';

  @override
  String get filterMono => 'Hitam putih';

  @override
  String get animSoul => 'Soul';

  @override
  String get animZoom => 'Zoom';

  @override
  String get audioSource => 'Sumber audio';

  @override
  String get micSystem => 'Mikrofon ponsel';

  @override
  String get micDevice => 'Mikrofon perangkat';

  @override
  String get micAuto => 'Otomatis';

  @override
  String get listenMic => 'Monitor mikrofon';

  @override
  String get about => 'Tentang';

  @override
  String get tips => 'Tips';

  @override
  String get tipOtgTitle => 'Diperlukan OTG / USB Host';

  @override
  String get tipOtgBody =>
      'Hubungkan kamera UVC, endoskop, atau kartu capture dengan adapter OTG. Untuk perangkat yang tidak bisa dibuka kamera sistem.';

  @override
  String get tipPrefsTitle => 'Preferensi diingat';

  @override
  String get tipPrefsBody =>
      'Mode, resolusi, fps, format, orientasi, audio, dan segmen dipulihkan saat peluncuran berikutnya.';

  @override
  String get tipMultiTitle => 'Pratinjau multi';

  @override
  String get tipMultiBody =>
      'Grid multi-kamera ada di UI Android referensi. Build ini menyediakan pratinjau tunggal.';

  @override
  String get segmentDuration => 'Panjang segmen';

  @override
  String get segmentNone => 'Tanpa segmen';

  @override
  String segmentMinutes(int minutes) {
    return '$minutes mnt';
  }

  @override
  String get language => 'Bahasa';

  @override
  String get languageSystem => 'Default sistem';

  @override
  String get appearance => 'Tampilan';

  @override
  String get themeSystem => 'Default sistem';

  @override
  String get themeLight => 'Terang';

  @override
  String get themeDark => 'Gelap';

  @override
  String get tools => 'Kontrol';

  @override
  String get previewPresets => 'Preset pratinjau';

  @override
  String get presetCustom => 'Kustom…';

  @override
  String get presetManage => 'Kelola preset';

  @override
  String get presetAddCurrent => 'Tambah saat ini';

  @override
  String get presetAdd => 'Tambah preset';

  @override
  String get presetReset => 'Pulihkan default';

  @override
  String get presetDelete => 'Hapus';

  @override
  String get presetEmpty => 'Belum ada preset';

  @override
  String get presetAdded => 'Ditambahkan';

  @override
  String get presetExists => 'Sudah ada';

  @override
  String get presetPickResolution => 'Pilih resolusi';

  @override
  String get presetPickFps => 'Pilih fps';

  @override
  String get presetSave => 'Simpan sebagai preset';

  @override
  String get presetApply => 'Terapkan';

  @override
  String get waitingUsb => 'Menunggu kamera USB';

  @override
  String get openFailed => 'Tidak dapat membuka kamera ini';

  @override
  String get waitingHintEmpty =>
      'Gunakan adapter OTG untuk menghubungkan kamera UVC atau kartu capture. Android akan meminta izin USB.';

  @override
  String get waitingHintDetected =>
      'Perangkat terdeteksi. Buka daftar di bawah untuk memilih.';

  @override
  String get errorHint => 'Periksa izin USB atau coba kabel lain.';

  @override
  String get selectDevice => 'Pilih perangkat';

  @override
  String get retryDevice => 'Coba perangkat lagi';

  @override
  String get modePhoto => 'Foto';

  @override
  String get modeVideo => 'Video';

  @override
  String get modeAudio => 'Audio';

  @override
  String get shutter => 'Rana';

  @override
  String fpsLabel(int fps) {
    return '$fps FPS';
  }

  @override
  String fpsOption(int fps) {
    return '$fps fps';
  }

  @override
  String get defaultDeviceName => 'Kamera USB';

  @override
  String get msgSaved => 'Tersimpan';

  @override
  String get msgSaveFailed => 'Gagal menyimpan';

  @override
  String get msgNoDevice => 'Kamera USB tidak ditemukan';

  @override
  String get msgPreviewNotReady => 'Pratinjau belum siap';

  @override
  String get msgCameraError => 'Kesalahan kamera';

  @override
  String previewStatus(int width, int height, String format, int fps) {
    return '$width×$height · $format · ${fps}fps';
  }
}
