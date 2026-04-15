package dev.mulev.flureadium

import android.graphics.Color
import android.os.Build
import android.os.Bundle
import android.os.Parcel
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
internal class FlutterDecorationPreferencesTest {

    @Test
    fun toBundle_roundTripsCustomStyles() {
        val original = FlutterDecorationPreferences(
            utteranceStyle = Decoration.Style.Underline(tint = Color.GREEN),
            currentRangeStyle = Decoration.Style.Highlight(tint = Color.BLUE)
        )

        val restored = FlutterDecorationPreferences.fromBundle(original.toBundle())

        val utteranceStyle = assertIs<Decoration.Style.Underline>(restored.utteranceStyle)
        val currentRangeStyle = assertIs<Decoration.Style.Highlight>(restored.currentRangeStyle)
        assertEquals(Color.GREEN, utteranceStyle.tint)
        assertEquals(Color.BLUE, currentRangeStyle.tint)
    }

    @Test
    fun toBundle_canBeWrittenToParcel() {
        val preferences = FlutterDecorationPreferences()
        val parcel = Parcel.obtain()

        try {
            parcel.writeBundle(Bundle().apply {
                putBundle("decorationStyle", preferences.toBundle())
            })
            parcel.setDataPosition(0)

            val restored = parcel.readBundle(javaClass.classLoader)?.getBundle("decorationStyle")

            assertNotNull(restored)
        } finally {
            parcel.recycle()
        }
    }
}
