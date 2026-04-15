package dev.mulev.flureadium

import android.graphics.Color
import android.os.Bundle
import org.readium.r2.navigator.Decoration

// TODO: Decision on appropriate defaults
// TODO: Can this be made configurable at built time?
// TODO: More complex styles? Like bold or italic plus background and text colors?
private val defaultUtteranceStyle = Decoration.Style.Highlight(tint = Color.YELLOW)
private val defaultCurrentRangeStyle = Decoration.Style.Underline(tint = Color.RED)
private const val utteranceStyleKey = "utteranceStyle"
private const val currentRangeStyleKey = "currentRangeStyle"
private const val decorationTypeKey = "type"
private const val decorationTintKey = "tint"
private const val decorationTypeHighlight = "highlight"
private const val decorationTypeUnderline = "underline"

/**
 * Decoration preferences used in the Flutter Readium plugin.
 */
data class FlutterDecorationPreferences(
    /**
     * Style for utterance decoration.
     */
    var utteranceStyle: Decoration.Style? = defaultUtteranceStyle,

    /**
     * Style for current reading range decoration.
     */
    var currentRangeStyle: Decoration.Style? = defaultCurrentRangeStyle
) {
    fun toBundle(): Bundle =
        Bundle().apply {
            putBundle(utteranceStyleKey, utteranceStyle.toBundle())
            putBundle(currentRangeStyleKey, currentRangeStyle.toBundle())
        }

    companion object {
        fun fromBundle(bundle: Bundle?): FlutterDecorationPreferences {
            if (bundle == null) {
                return FlutterDecorationPreferences()
            }

            return FlutterDecorationPreferences(
                utteranceStyle = decorationStyleFromBundle(bundle.getBundle(utteranceStyleKey))
                    ?: defaultUtteranceStyle,
                currentRangeStyle = decorationStyleFromBundle(bundle.getBundle(currentRangeStyleKey))
                    ?: defaultCurrentRangeStyle,
            )
        }

        /**
         * Create Decoration.Style from map.
         */
        fun fromMap(
            uttDecoMap: Map<*, *>?,
            rangeDecoMap: Map<*, *>?
        ): FlutterDecorationPreferences {
            return FlutterDecorationPreferences(
                decorationStyleFromMap(uttDecoMap) ?: defaultUtteranceStyle,
                decorationStyleFromMap(rangeDecoMap) ?: defaultCurrentRangeStyle,
            )
        }
    }
}

private fun Decoration.Style?.toBundle(): Bundle? {
    if (this == null) {
        return null
    }

    return Bundle().apply {
        when (this@toBundle) {
            is Decoration.Style.Highlight -> putString(decorationTypeKey, decorationTypeHighlight)
            is Decoration.Style.Underline -> putString(decorationTypeKey, decorationTypeUnderline)
        }

        decorationStyleTint(this@toBundle)?.let { putInt(decorationTintKey, it) }
    }
}

private fun decorationStyleFromBundle(bundle: Bundle?): Decoration.Style? {
    if (bundle == null || !bundle.containsKey(decorationTintKey)) {
        return null
    }

    val tint = bundle.getInt(decorationTintKey)
    return when (bundle.getString(decorationTypeKey)) {
        decorationTypeUnderline -> Decoration.Style.Underline(tint = tint)
        decorationTypeHighlight -> Decoration.Style.Highlight(tint = tint)
        else -> null
    }
}

private fun decorationStyleTint(style: Decoration.Style): Int? =
    when (style) {
        is Decoration.Style.Highlight -> style.tint
        is Decoration.Style.Underline -> style.tint
        else -> null
    }
