package com.jiangdg.ausbc_flutter

import com.jiangdg.ausbc.base.BaseApplication
import com.jiangdg.ausbc.utils.Utils

/** Starts the same logging and crash hooks the camera engine expects. */
class AusbcApplication : BaseApplication() {
    override fun onCreate() {
        super.onCreate()
        // FPS 回调里会反复读分辨率列表；关闭 debug 避免每秒刷屏和多余 USB 查询。
        Utils.debugCamera = false
    }
}
