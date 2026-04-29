package dev.mulev.flureadium

import android.graphics.Bitmap
import android.graphics.BitmapFactory
import java.io.ByteArrayOutputStream

/**
 * Decodes raw image bytes into a downscaled JPEG using BitmapFactory's
 * inSampleSize-based downsampling. The first pass measures source dimensions;
 * the second pass decodes at the largest power-of-two scale that keeps the
 * longest side ≥ maxHeight, then a final scale-to-fit if needed.
 */
internal object PageThumbnailExtractor {
    fun extract(bytes: ByteArray, maxHeight: Int, quality: Int): ByteArray? {
        if (bytes.isEmpty() || maxHeight <= 0) return null

        val measureOpts = BitmapFactory.Options().apply { inJustDecodeBounds = true }
        BitmapFactory.decodeByteArray(bytes, 0, bytes.size, measureOpts)
        if (measureOpts.outWidth <= 0 || measureOpts.outHeight <= 0) return null

        val decodeOpts = BitmapFactory.Options().apply {
            inSampleSize = computeInSampleSize(
                srcWidth = measureOpts.outWidth,
                srcHeight = measureOpts.outHeight,
                target = maxHeight,
            )
        }
        val decoded = BitmapFactory.decodeByteArray(bytes, 0, bytes.size, decodeOpts) ?: return null
        val scaled = scaleToFit(decoded, maxHeight)

        val output = ByteArrayOutputStream()
        val q = quality.coerceIn(0, 100)
        val ok = scaled.compress(Bitmap.CompressFormat.JPEG, q, output)
        if (scaled !== decoded) decoded.recycle()
        scaled.recycle()
        return if (ok) output.toByteArray() else null
    }

    private fun computeInSampleSize(srcWidth: Int, srcHeight: Int, target: Int): Int {
        val largest = maxOf(srcWidth, srcHeight)
        var sample = 1
        while (largest / (sample * 2) >= target) {
            sample *= 2
        }
        return sample
    }

    private fun scaleToFit(src: Bitmap, maxHeight: Int): Bitmap {
        val largest = maxOf(src.width, src.height)
        if (largest <= maxHeight) return src
        val ratio = maxHeight.toFloat() / largest
        val w = (src.width * ratio).toInt().coerceAtLeast(1)
        val h = (src.height * ratio).toInt().coerceAtLeast(1)
        return Bitmap.createScaledBitmap(src, w, h, true)
    }
}
