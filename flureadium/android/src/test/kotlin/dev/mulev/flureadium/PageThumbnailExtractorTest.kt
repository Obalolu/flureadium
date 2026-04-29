package dev.mulev.flureadium

import android.graphics.Bitmap
import android.graphics.BitmapFactory
import java.io.ByteArrayOutputStream
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config
import org.robolectric.annotation.GraphicsMode

@RunWith(RobolectricTestRunner::class)
@GraphicsMode(GraphicsMode.Mode.NATIVE)
@Config(sdk = [33])
internal class PageThumbnailExtractorTest {

    @Test
    fun extract_validJpeg_returnsSmallerJpeg() {
        val src = fixtureJpeg(width = 200, height = 300)
        val result = PageThumbnailExtractor.extract(src, maxHeight = 80, quality = 70)
        assertNotNull(result)
        assertTrue(
            "expected output (${result!!.size}) < input (${src.size})",
            result.size < src.size,
        )
    }

    @Test
    fun extract_capsLongestSideAtMaxHeight() {
        val src = fixtureJpeg(width = 200, height = 300)
        val result = PageThumbnailExtractor.extract(src, maxHeight = 80, quality = 70)
        val out = BitmapFactory.decodeByteArray(result!!, 0, result.size)
        assertTrue(
            "longest side must be ≤ 80, was ${maxOf(out.width, out.height)}",
            maxOf(out.width, out.height) <= 80,
        )
    }

    @Test
    fun extract_returnsNullForInvalidBytes() {
        assertNull(
            PageThumbnailExtractor.extract(byteArrayOf(0, 1, 2, 3), maxHeight = 80, quality = 70),
        )
    }

    @Test
    fun extract_returnsNullForEmptyBytes() {
        assertNull(PageThumbnailExtractor.extract(ByteArray(0), maxHeight = 80, quality = 70))
    }

    @Test
    fun extract_returnsNullForZeroMaxHeight() {
        val src = fixtureJpeg(width = 200, height = 300)
        assertNull(PageThumbnailExtractor.extract(src, maxHeight = 0, quality = 70))
    }

    private fun fixtureJpeg(width: Int, height: Int): ByteArray {
        val bmp = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888)
        bmp.eraseColor(android.graphics.Color.GRAY)
        val baos = ByteArrayOutputStream()
        bmp.compress(Bitmap.CompressFormat.JPEG, 90, baos)
        bmp.recycle()
        return baos.toByteArray()
    }
}
