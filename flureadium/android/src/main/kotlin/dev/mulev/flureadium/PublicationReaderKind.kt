package dev.mulev.flureadium

import org.readium.r2.shared.ExperimentalReadiumApi
import org.readium.r2.shared.publication.Publication

@OptIn(ExperimentalReadiumApi::class)
internal enum class PublicationReaderKind {
    EPUB,
    PDF,
    IMAGE,
}

@OptIn(ExperimentalReadiumApi::class)
internal fun Publication.readerKind(): PublicationReaderKind {
    if (conformsTo(Publication.Profile.PDF)) {
        return PublicationReaderKind.PDF
    }

    val isImagePublication =
        conformsTo(Publication.Profile.DIVINA) ||
            (readingOrder.isNotEmpty() && readingOrder.all { it.mediaType?.isBitmap == true })
    if (isImagePublication) {
        return PublicationReaderKind.IMAGE
    }

    return PublicationReaderKind.EPUB
}
