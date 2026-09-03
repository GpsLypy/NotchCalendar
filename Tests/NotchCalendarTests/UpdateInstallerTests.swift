import Foundation
import XCTest
@testable import NotchCalendar

final class UpdateInstallerTests: XCTestCase {
    func testAutomaticReplacementRemainsFailClosed() {
        let capability = UpdateInstaller.automaticInstallationCapability(
            currentBundleURL: URL(fileURLWithPath: "/Applications/Notch Calendar.app"),
            bundleIdentifier: "com.codex.notch-calendar"
        )

        guard case let .manualOnly(message) = capability else {
            return XCTFail("Automatic replacement must stay disabled in this release")
        }
        XCTAssertTrue(message.contains("not enabled"))
    }

    func testVersionComparisonAndEquivalentTrailingZeroes() throws {
        let current = try XCTUnwrap(AppVersion("0.2.0"))
        let update = try XCTUnwrap(AppVersion("v0.2.1"))
        let equivalent = try XCTUnwrap(AppVersion("0.2"))

        XCTAssertLessThan(current, update)
        XCTAssertEqual(current, equivalent)
        XCTAssertEqual(update.description, "0.2.1")
    }

    func testVersionParserRejectsAmbiguousOrMalformedValues() {
        for value in ["", "version-1.2.3", "1..2", "1.02.3", "1.2.3-beta", " 1.2.3"] {
            XCTAssertNil(AppVersion(value), value)
        }
    }

    func testTrustedAssetRequiresExactRepositoryTagAndFilename() throws {
        let trusted = try XCTUnwrap(
            URL(string: "https://github.com/GpsLypy/NotchCalendar/releases/download/v0.3.0/NotchCalendar-0.3.0-macos.dmg")
        )

        XCTAssertEqual(
            ReleaseAssetSelector.trustedDMGURL(
                assetName: "NotchCalendar-0.3.0-macos.dmg",
                downloadURL: trusted,
                releaseTag: "v0.3.0",
                repository: "GpsLypy/NotchCalendar"
            ),
            trusted
        )
    }

    func testTrustedAssetRejectsLookalikesAndURLMetadata() throws {
        let cases = [
            "https://github.example/GpsLypy/NotchCalendar/releases/download/v0.3.0/NotchCalendar-0.3.0-macos.dmg",
            "https://github.com/Other/NotchCalendar/releases/download/v0.3.0/NotchCalendar-0.3.0-macos.dmg",
            "https://github.com/GpsLypy/NotchCalendar/releases/download/v9.9.9/NotchCalendar-0.3.0-macos.dmg",
            "https://github.com/GpsLypy/NotchCalendar/releases/download/v0.3.0/NotchCalendar-0.3.0-macos.dmg?download=1",
            "https://attacker@github.com/GpsLypy/NotchCalendar/releases/download/v0.3.0/NotchCalendar-0.3.0-macos.dmg"
        ]

        for rawURL in cases {
            let url = try XCTUnwrap(URL(string: rawURL))
            XCTAssertNil(
                ReleaseAssetSelector.trustedDMGURL(
                    assetName: "NotchCalendar-0.3.0-macos.dmg",
                    downloadURL: url,
                    releaseTag: "v0.3.0",
                    repository: "GpsLypy/NotchCalendar"
                ),
                rawURL
            )
        }
    }

    func testGitHubDigestRequiresSHA256WithExactly64HexCharacters() {
        let digest = String(repeating: "a1", count: 32)
        XCTAssertEqual(UpdateFileDigest.parseGitHubSHA256("sha256:\(digest)"), digest)
        XCTAssertNil(UpdateFileDigest.parseGitHubSHA256(nil))
        XCTAssertNil(UpdateFileDigest.parseGitHubSHA256(digest))
        XCTAssertNil(UpdateFileDigest.parseGitHubSHA256("sha256:\(digest)0"))
        XCTAssertNil(UpdateFileDigest.parseGitHubSHA256("sha256:\(String(repeating: "z", count: 64))"))
    }

    func testFileDigestMatchesKnownSHA256() throws {
        let fileURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("NotchCalendar-digest-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: fileURL) }
        try Data("abc".utf8).write(to: fileURL)

        XCTAssertEqual(
            try UpdateFileDigest.sha256(of: fileURL),
            "ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad"
        )
    }
}
