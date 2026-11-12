# USB 摄像头

把 UVC 摄像头、内窥镜或标准 USB 采集卡接到安卓手机，立刻预览、拍照、录像、录音。

界面是 Flutter，相机引擎沿用归档在 `reference/` 里的 [AUSBC](https://github.com/jiangdongguo/AndroidUSBCamera)（UVC / OpenGL / 编码）。本仓库是独立历史，不延续上游 Git。

| 项 | 说明 |
| --- | --- |
| 包名 | `com.jiangdg.ausbc.flutter` |
| 版本 | 3.8.0（versionCode 137） |
| 系统 | Android 7.0+（minSdk 24），targetSdk 35 |
| ABI | `armeabi-v7a`、`arm64-v8a`（不含 x86） |
| 语言 | 跟随系统；设置内可切换。en / 简中 / 繁中 / ja / ko / es / pt / de / fr / ru / id / hi / ar |
| 许可 | Apache-2.0 |

## 能做什么

- 三种工作台模式，顶部胶囊用 HoldMenu 切换（与 Cursor Remote 同款展开）：
  - **观看**：纯画面；点一下显示控制，USB 圆钮打开设备列表
  - **拍摄**：拍照 / 录像 / 录音与快门
  - **调节**：画面、视频、效果、音频、分段与关于（默认进入）
- 单路 UVC 预览（默认 MJPEG + OpenGL）；插上匹配设备可自动打开应用
- 拍照（JPEG → `DCIM/Camera`）、录像（H.264 + AAC 的 MP4）、单独录音（MP3）
- 分辨率、帧率、MJPEG / YUYV、旋转与翻转；偏好会记住
- 亮度等画面调节（0–100）、自动对焦 / 白平衡（按设备能力）
- 黑白滤镜、灵魂 / 缩放动画
- 音源：手机麦 / 设备麦 / 自动；可监听麦克风
- 录像分段：不分段，或每 1 / 5 / 10 / 30 分钟
- 预览时保持亮屏；右上角显示实时帧率与目标分辨率 / 格式 / 帧率
- 多语言界面（Google Play 上架准备）：默认跟随系统，设置里可单独切换并记住

多路网格仍在 `reference/` 的 Android 演示里，Flutter 版先做单路。

## Google Play 语言说明

应用内文案使用 Flutter `gen-l10n`（`flutter_app/lib/l10n/*.arb`）。桌面图标名走 Android `values-*/strings.xml`。上架时可在 Play Console 为同一套语言补商店短描述 / 完整描述与截图本地化。

## 仓库结构

```text
android-usb-camera/
├── flutter_app/     # 日常使用的 Flutter 应用
├── reference/       # 归档的原 Android 工程与 libausbc / libuvc / libnative
├── scripts/         # debug 热重载：dev.sh / reload.sh / restart.sh
└── docs/            # 产品需求、验收清单、与 USB Camera 功能对照
```

## 快速开始

### 安装 Release

到 [Releases](https://github.com/Huabin1010/android-usb-camera/releases) 下载 APK，用支持 OTG 的安卓手机安装。首次打开需要相机、麦克风，以及相册相关权限。

### 自己编译

环境：Flutter 3.35+、Android SDK、NDK 27、Java 17。

```bash
git clone https://github.com/Huabin1010/android-usb-camera.git
cd android-usb-camera

# Debug，连上真机后热重载
./scripts/dev.sh

# Release APK
cd flutter_app && flutter build apk --release
```

`./scripts/dev.sh` 是 debug 会话。保存 `flutter_app/lib/**/*.dart` 会热重载；终端里 `r` 热重载、`R` 热重启、`q` 退出。另一个终端可执行 `./scripts/reload.sh`。改了 `reference/` 里的 native 引擎后需要热重启或重新跑脚本。

## 使用注意

1. 需要 USB Host / OTG。系统相机认不了的 UVC 设备，才是这个应用的主场景。
2. 第一次插设备时，系统会弹 USB 权限；拒绝后可以在「设备」里点重试。已授权的匹配设备插入时，可直接把应用拉到前台。
3. 没有 USB 摄像头时，空态会提示接线与权限，并可打开设备列表。
4. 模拟器一般没有 UVC，只能验收无设备和界面结构；真机预览、拍照、录像请接真实设备。

## 文档

- [产品需求](docs/USB摄像头产品需求.md)
- [验收清单](docs/验收清单.md)
- [与 USB Camera 功能对照](docs/与USB摄像头功能对照.md)

## 致谢

相机引擎基于 [jiangdongguo/AndroidUSBCamera](https://github.com/jiangdongguo/AndroidUSBCamera)（AUSBC）。界面与发布仓库由本项目维护。
