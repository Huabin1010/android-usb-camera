# USB 摄像头

Flutter 界面，相机引擎用归档在 `reference/` 里的 AUSBC。

手机连上后，在仓库根目录执行：

```bash
./scripts/dev.sh
```

这是 debug 模式。保存 `flutter_app/lib` 里的 Dart 文件会自动热重载，也可以在这个终端按 `r`。热重启是 `R`，退出是 `q`。另一个终端可以用 `./scripts/reload.sh`。

`reference/` 是原来的 Android 工程，不再作为当前仓库的历史。改 native 引擎后需要在调试终端按 `R`，或重新执行 `./scripts/dev.sh`。
