import XCTest
@testable import flureadium

final class EpubEditingActionsTests: XCTestCase {

    func testEpubEditingActionsContainsCopy() {
        XCTAssertTrue(
            ReadiumReaderView.epubEditingActions.contains(.copy),
            "editingActions must include .copy so users can copy selected text"
        )
    }

    func testEpubEditingActionsContainsLookup() {
        XCTAssertTrue(
            ReadiumReaderView.epubEditingActions.contains(.lookup),
            "editingActions must retain .lookup (regression)"
        )
    }

    func testEpubEditingActionsContainsTranslate() {
        XCTAssertTrue(
            ReadiumReaderView.epubEditingActions.contains(.translate),
            "editingActions must retain .translate (regression)"
        )
    }

    func testEpubEditingActionsCountIsThree() {
        XCTAssertEqual(
            ReadiumReaderView.epubEditingActions.count,
            3,
            "editingActions must have exactly 3 items: copy, lookup, translate"
        )
    }
}
