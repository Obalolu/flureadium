package dev.mulev.flureadium

import android.graphics.Color
import android.os.Build
import android.os.Bundle
import android.os.Parcel
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlin.test.AfterTest
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertIs
import kotlin.test.assertNotNull
import org.junit.runner.RunWith
import org.readium.r2.navigator.Decoration
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config

@RunWith(RobolectricTestRunner::class)
@Config(sdk = [Build.VERSION_CODES.P], manifest = Config.NONE)
@OptIn(ExperimentalCoroutinesApi::class)
internal class ReadiumReaderSavedStateTest {

    @AfterTest
    fun tearDown() {
        ReadiumReader.currentPublicationUrl = null
        ReadiumReader.decorationStyle = FlutterDecorationPreferences()
    }

    @Test
    fun storeState_persistsDecorationStyleAsBundle() {
        ReadiumReader.currentPublicationUrl = "https://example.com/book.epub"
        ReadiumReader.decorationStyle = FlutterDecorationPreferences(
            utteranceStyle = Decoration.Style.Underline(tint = Color.GREEN),
            currentRangeStyle = Decoration.Style.Highlight(tint = Color.BLUE)
        )

        val parcel = Parcel.obtain()

        try {
            val savedState = invokeStoreState()
            parcel.writeBundle(savedState)
            parcel.setDataPosition(0)

            val restoredState = parcel.readBundle(javaClass.classLoader)
            val decorationStyleBundle = restoredState?.getBundle("decorationStyle")
            val restoredPreferences = FlutterDecorationPreferences.fromBundle(decorationStyleBundle)

            assertNotNull(decorationStyleBundle)
            assertEquals(
                Color.GREEN,
                assertIs<Decoration.Style.Underline>(restoredPreferences.utteranceStyle).tint
            )
            assertEquals(
                Color.BLUE,
                assertIs<Decoration.Style.Highlight>(restoredPreferences.currentRangeStyle).tint
            )
        } finally {
            parcel.recycle()
        }
    }

    private fun invokeStoreState(): Bundle {
        val storeState = ReadiumReader::class.java.getDeclaredMethod("storeState")
        storeState.isAccessible = true
        return storeState.invoke(ReadiumReader) as Bundle
    }
}
