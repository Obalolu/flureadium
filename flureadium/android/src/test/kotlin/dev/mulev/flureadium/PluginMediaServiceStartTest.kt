package dev.mulev.flureadium

import android.app.Application
import android.content.Intent
import android.os.Build
import kotlin.test.Test
import org.junit.runner.RunWith
import org.mockito.ArgumentMatchers.any
import org.mockito.Mockito.mock
import org.mockito.Mockito.never
import org.mockito.Mockito.verify
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config

@RunWith(RobolectricTestRunner::class)
@Config(sdk = [Build.VERSION_CODES.P])
internal class PluginMediaServiceStartTest {

    @Test
    fun start_callsStartForegroundService_notStartService() {
        val application = mock(Application::class.java)

        PluginMediaService.start(application)

        verify(application).startForegroundService(any(Intent::class.java))
        verify(application, never()).startService(any(Intent::class.java))
    }
}
