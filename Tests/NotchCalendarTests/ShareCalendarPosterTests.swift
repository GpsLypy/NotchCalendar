import AppKit
import XCTest
@testable import NotchCalendar

final class ShareCalendarPosterTests: XCTestCase {
    func testPosterExportsDecodablePNGInBothLanguages() async throws {
        try await MainActor.run {
            for language in [AppLanguage.simplifiedChinese, .english] {
                let image = try XCTUnwrap(ShareCalendarPoster.render(language: language))
                let tiff = try XCTUnwrap(image.tiffRepresentation)
                let bitmap = try XCTUnwrap(NSBitmapImageRep(data: tiff))
                let png = try XCTUnwrap(bitmap.representation(using: .png, properties: [:]))
                let decoded = try XCTUnwrap(NSBitmapImageRep(data: png))
                XCTAssertEqual(decoded.pixelsWide, 1200)
                XCTAssertEqual(decoded.pixelsHigh, 880)
                XCTAssertGreaterThan(png.count, 10_000)
                if let directory = ProcessInfo.processInfo.environment["NOTCH_SHARE_PREVIEW_DIR"] {
                    try png.write(to: URL(fileURLWithPath: directory)
                        .appendingPathComponent("share-\(language.rawValue).png"))
                }
            }
        }
    }
}
