/*
 * Copyright 2017-2023 Jiangdg
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package com.jiangdg.ausbc.render.env

import android.opengl.*
import android.opengl.EGLSurface
import android.view.Surface
import com.jiangdg.ausbc.utils.Logger

/**
 * 创建EGL，将其与目标Surface绑定
 *
 * @author Created by jiangdg on 2021/10/14
 */
class EGLEvn {
    private var mEglDisplay: EGLDisplay = EGL14.EGL_NO_DISPLAY
    private var mEglSurface: EGLSurface = EGL14.EGL_NO_SURFACE
    private var mEglContext: EGLContext = EGL14.EGL_NO_CONTEXT
    private var mSurface: Surface? = null
    private val configs = arrayOfNulls<EGLConfig>(1)

    fun initEgl(curContext: EGLContext? = null): Boolean {
        // 1. 获取EGL Display
        mEglDisplay = EGL14.eglGetDisplay(EGL14.EGL_DEFAULT_DISPLAY)
        if (mEglDisplay == EGL14.EGL_NO_DISPLAY) {
            loggerError("Get display")
            return false
        }
        // 2. 初始化EGL
        val version = IntArray(2)
        if (! EGL14.eglInitialize(mEglDisplay, version, 0, version, 1)) {
            loggerError("Init egl")
            return false
        }
        // 3. 指定Surface配置
        // RGB888 & opengl ES2
        // EGL_RECORDABLE_ANDROID（API26以下必须指定）
        val configAttribs = intArrayOf(
		    EGL14.EGL_RED_SIZE, 8,
            EGL14.EGL_GREEN_SIZE, 8,
            EGL14.EGL_BLUE_SIZE, 8,
            EGL14.EGL_ALPHA_SIZE, 8,
            EGL14.EGL_RENDERABLE_TYPE, EGL14.EGL_OPENGL_ES2_BIT,
            EGL_RECORDABLE_ANDROID, 1,
            EGL14.EGL_NONE
        )
        val numConfigs = IntArray(1)
        if (! EGL14.eglChooseConfig(mEglDisplay, configAttribs, 0, configs, 0, configs.size, numConfigs, 0)) {
            loggerError("Choose Config")
            return false
        }
        // 4. 创建OpenGL ES对应的上下文
        // 如果传入了glContext，则使用传入的上下文，即纹理共享
        val ctxAttribs = intArrayOf(
            EGL14.EGL_CONTEXT_CLIENT_VERSION, 2,
            EGL14.EGL_NONE
        )
        mEglContext = EGL14.eglCreateContext(mEglDisplay, configs[0], curContext ?: EGL14.EGL_NO_CONTEXT , ctxAttribs, 0)
        if (mEglContext == EGL14.EGL_NO_CONTEXT) {
            loggerError("Create context")
            return false
        }
        // 5. 设置默认的上下文环境和输出缓冲区
        // 将eglSurface先设置为EGL14.EGL_NO_SURFACE
        if (! EGL14.eglMakeCurrent(mEglDisplay, EGL14.EGL_NO_SURFACE, EGL14.EGL_NO_SURFACE, mEglContext)) {
            loggerError("Bind context and window")
            return false
        }
        Logger.i(TAG, "Init EGL Success!")
        return true
    }

    fun setupSurface(surface: Surface?, surfaceWidth: Int = 0, surfaceHeight: Int = 0) {
        if (mEglDisplay == EGL14.EGL_NO_DISPLAY) {
            return
        }
        // Surface 失效时 eglCreateWindowSurface 抛 IllegalArgumentException，
        // 发生在 gl_render 线程上会直接杀掉进程。失败就退回离屏，预览线程继续活着。
        val window = surface?.takeIf { it.isValid }
        if (surface != null && window == null) {
            Logger.e(TAG, "preview surface invalid, use offscreen ${surfaceWidth}x${surfaceHeight}")
        }
        var onScreen = false
        mEglSurface = if (window == null) {
            createPbuffer(surfaceWidth, surfaceHeight)
        } else {
            val created = try {
                EGL14.eglCreateWindowSurface(
                    mEglDisplay,
                    configs[0],
                    window,
                    intArrayOf(EGL14.EGL_NONE),
                    0,
                )
            } catch (e: IllegalArgumentException) {
                Logger.e(TAG, "eglCreateWindowSurface failed: ${e.message}")
                EGL14.EGL_NO_SURFACE
            }
            if (created != EGL14.EGL_NO_SURFACE) {
                onScreen = true
                created
            } else {
                createPbuffer(surfaceWidth, surfaceHeight)
            }
        }
        if (mEglSurface == EGL14.EGL_NO_SURFACE) {
            loggerError("Create window")
        }
        mSurface = if (onScreen) window else null
        Logger.i(TAG, "setupSurface done, onScreen=$onScreen")
    }

    private fun createPbuffer(surfaceWidth: Int, surfaceHeight: Int): EGLSurface {
        val attributes = intArrayOf(
            EGL14.EGL_WIDTH, surfaceWidth.coerceAtLeast(1),
            EGL14.EGL_HEIGHT, surfaceHeight.coerceAtLeast(1),
            EGL14.EGL_NONE,
        )
        return EGL14.eglCreatePbufferSurface(mEglDisplay, configs[0], attributes, 0)
    }

    fun eglMakeCurrent() {
        if (mEglContext == EGL14.EGL_NO_CONTEXT) {
            return
        }
        if (mEglSurface == EGL14.EGL_NO_SURFACE) {
            return
        }
        if (! EGL14.eglMakeCurrent(mEglDisplay, mEglSurface, mEglSurface, mEglContext)) {
            loggerError("Bind context and window")
        }
    }

    fun setPresentationTime(nanoseconds: Long) {
        if (mEglContext == EGL14.EGL_NO_CONTEXT) {
            return
        }
        if (mSurface == null) {
            return
        }
        // 更新EGL显示时间戳
        if (! EGLExt.eglPresentationTimeANDROID(mEglDisplay, mEglSurface, nanoseconds)) {
            loggerError("Set Presentation time")
        }
    }

    fun swapBuffers() {
        if (mEglContext == EGL14.EGL_NO_CONTEXT) {
            return
        }
        // 交换双重缓冲数据
        // 即将渲染数据(后端缓冲区)输出到目标窗口(Surface)(前端缓冲区)
        if (! EGL14.eglSwapBuffers(mEglDisplay, mEglSurface)) {
            loggerError("Swap buffers")
        }
    }

    fun releaseElg() {
        if (mEglDisplay != EGL14.EGL_NO_DISPLAY) {
            EGL14.eglMakeCurrent(mEglDisplay, EGL14.EGL_NO_SURFACE, EGL14.EGL_NO_SURFACE, EGL14.EGL_NO_CONTEXT)
            EGL14.eglDestroySurface(mEglDisplay, mEglSurface)
            EGL14.eglDestroyContext(mEglDisplay, mEglContext)
            EGL14.eglReleaseThread()
            EGL14.eglTerminate(mEglDisplay)
        }
        // Surface 由预览控件持有（Flutter 的 SurfaceTexture）。这里 release 会把
        // 正在重开的窗口 Surface 拆掉，下一帧只能落到离屏缓冲，画面就一直是黑的。
        mEglDisplay = EGL14.EGL_NO_DISPLAY
        mEglSurface = EGL14.EGL_NO_SURFACE
        mEglContext = EGL14.EGL_NO_CONTEXT      
        mSurface = null
        Logger.i(TAG, "Release EGL Success!")
    }

    private fun loggerError(msg: String) {
        Logger.e(TAG, "$msg failed. error = ${EGL14.eglGetError()}")
    }

    fun getEGLContext(): EGLContext = EGL14.eglGetCurrentContext()

    companion object {
        private const val TAG = "EGLEvn"
        private const val EGL_RECORDABLE_ANDROID = 0x3142
    }
}