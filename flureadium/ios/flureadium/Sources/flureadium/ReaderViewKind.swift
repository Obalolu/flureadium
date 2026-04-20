import ReadiumShared

enum ReaderViewKind {
  case epub
  case pdf
  case image
}

func readerViewKind(for publication: Publication) -> ReaderViewKind {
  let conformsTo = publication.metadata.conformsTo

  if conformsTo.contains(.pdf) || publication.conforms(to: .pdf) {
    return .pdf
  }

  if conformsTo.contains(.divina) || publication.conforms(to: .divina) ||
    (!publication.readingOrder.isEmpty && publication.readingOrder.allAreBitmap)
  {
    return .image
  }

  return .epub
}
