package dev.mulev.flureadium

import android.app.Application
import android.content.Intent
import android.os.Build
import androidx.media3.session.DefaultMediaNotificationProvider
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlin.test.assertEquals
import kotlin.test.assertNotNull
import kotlin.test.Test
import org.junit.runner.RunWith
import org.mockito.ArgumentMatchers.any
import org.mockito.Mockito.mock
import org.mockito.Mockito.never
import org.mockito.Mockito.verify
import org.robolectric.Robolectric
import org.robolectric.Shadows.shadowOf
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config

@RunWith(RobolectricTestRunner::class)
@Config(sdk = [Build.VERSION_CODES.P])
@OptIn(ExperimentalCoroutinesApi::class)
internal class PluginMediaServiceStartTest {

    @Test
    fun start_callsStartForegroundService_notStartService() {
        val application = mock(Application::class.java)

        PluginMediaService.start(application)

        verify(application).startForegroundService(any(Intent::class.java))
        verify(application, never()).startService(any(Intent::class.java))
    }

    @Test
    @Config(sdk = [Build.VERSION_CODES.Q])
    fun onStartCommand_entersForegroundImmediately() {
        val controller = Robolectric.buildService(PluginMediaService::class.java).create()
        val service = controller.get()

        service.onStartCommand(Intent(service, PluginMediaService::class.java), 0, 1)

        val shadowService = shadowOf(service)
        assertEquals(
            DefaultMediaNotificationProvider.DEFAULT_NOTIFICATION_ID,
            shadowService.lastForegroundNotificationId
        )
        assertNotNull(shadowService.lastForegroundNotification)
    }
}
