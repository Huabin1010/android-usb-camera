package com.jiangdg.demo.ui.camera

import com.jiangdg.ausbc.camera.bean.CameraRequest
import com.jiangdg.ausbc.render.env.RotateType
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test

class CameraUiStateTest {
    @Test
    fun selectModeChangesPhotoToVideoWhenIdle() {
        val updated = CameraUiState(mode = CaptureMode.Photo).selectMode(CaptureMode.Video)

        assertEquals(CaptureMode.Video, updated.mode)
    }

    @Test
    fun selectModeKeepsCurrentModeWhileRecording() {
        val recording = CameraUiState(mode = CaptureMode.Video, isRecording = true)

        val updated = recording.selectMode(CaptureMode.Photo)

        assertEquals(CaptureMode.Video, updated.mode)
        assertTrue(updated.isRecording)
    }

    @Test
    fun selectResolutionUpdatesSizeWhenCameraIsOpen() {
        val opened = CameraUiState(connection = Connection.Opened, previewWidth = 640, previewHeight = 480)

        val updated = opened.selectResolution(1920, 1080)

        assertEquals(1920, updated.previewWidth)
        assertEquals(1080, updated.previewHeight)
    }

    @Test
    fun selectResolutionIgnoresSameSizeAndRecording() {
        val opened = CameraUiState(connection = Connection.Opened, previewWidth = 1280, previewHeight = 720)
        assertEquals(opened, opened.selectResolution(1280, 720))

        val recording = opened.copy(isRecording = true)
        assertEquals(recording, recording.selectResolution(1920, 1080))
        assertFalse(CameraUiState().selectResolution(800, 600).previewWidth == 800)
    }

    @Test
    fun sidePanelTogglesOpenAndClosed() {
        val opened = CameraUiState().toggleSide(SideSection.Settings)

        assertEquals(SideSection.Settings, opened.sidePanel)
        assertNull(opened.toggleSide(SideSection.Settings).sidePanel)
        assertEquals(SideSection.About, opened.toggleSide(SideSection.About).sidePanel)
    }

    @Test
    fun formatRotateAndSegmentStayPutWhileRecording() {
        val recording = CameraUiState(isRecording = true)

        assertEquals(
            CameraRequest.PreviewFormat.FORMAT_MJPEG,
            recording.selectPreviewFormat(CameraRequest.PreviewFormat.FORMAT_YUYV).previewFormat,
        )
        assertEquals(RotateType.ANGLE_0, recording.selectRotate(RotateType.FLIP_LEFT_RIGHT).rotate)
        assertEquals(0, recording.selectSegmentMinutes(5).segmentMinutes)
        assertEquals(
            CameraRequest.AudioSource.SOURCE_SYS_MIC,
            recording.selectAudioSource(CameraRequest.AudioSource.SOURCE_DEV_MIC).audioSource,
        )
    }

    @Test
    fun formatAndSegmentChangeWhenIdle() {
        val idle = CameraUiState(connection = Connection.Opened)

        assertEquals(
            CameraRequest.PreviewFormat.FORMAT_YUYV,
            idle.selectPreviewFormat(CameraRequest.PreviewFormat.FORMAT_YUYV).previewFormat,
        )
        assertEquals(10, idle.selectSegmentMinutes(10).segmentMinutes)
        assertEquals(RotateType.ANGLE_90, idle.selectRotate(RotateType.ANGLE_90).rotate)
    }
}

class CaptureTimerTest {
    @Test
    fun formatCoversZeroMinuteHourAndNegative() {
        assertEquals("00:00", CaptureTimer.format(0))
        assertEquals("00:59", CaptureTimer.format(59))
        assertEquals("01:00", CaptureTimer.format(60))
        assertEquals("01:00:00", CaptureTimer.format(3600))
        assertEquals("01:01:01", CaptureTimer.format(3661))
        assertEquals("00:00", CaptureTimer.format(-5))
    }
}
