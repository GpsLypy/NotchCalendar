import XCTest
@testable import NotchCalendar

final class UpdateReleaseNotesTests: XCTestCase {
    func testParsesAddedImprovedAndFixedSections() {
        let markdown = """
        Manual installation release.

        ## Added / 新增功能
        - Added the workspace sidebar / 新增工作区侧栏
        - **Added language selection**

        ## Improved / 改进
        - Faster calendar refresh

        ## Fixed / 修复功能
        - Fixed Chinese input method composition

        **Full Changelog:** v0.2.2...v0.3.0
        """

        let sections = UpdateReleaseNotesParser.sections(from: markdown)

        XCTAssertEqual(sections.map(\.category), [.added, .improved, .fixed])
        XCTAssertEqual(
            sections.first?.items,
            ["Added the workspace sidebar / 新增工作区侧栏", "Added language selection"]
        )
        XCTAssertEqual(sections.last?.items, ["Fixed Chinese input method composition"])
        XCTAssertFalse(sections.flatMap(\.items).contains(where: { $0.contains("Full Changelog") }))
    }

    func testIgnoresUnstructuredReleaseText() {
        let markdown = """
        Manual installation release: open the DMG.
        **Full Changelog:** [v0.2.1...v0.2.2](https://example.com/compare)
        """

        XCTAssertTrue(UpdateReleaseNotesParser.sections(from: markdown).isEmpty)
        XCTAssertEqual(
            UpdateReleaseNotesParser.fallbackText(from: markdown),
            "Manual installation release: open the DMG."
        )
    }

    func testAcceptsChineseOnlyHeadings() {
        let markdown = """
        ### 新增功能
        - 支持自动检查更新

        ### 修复
        - 修复输入法问题
        """

        let sections = UpdateReleaseNotesParser.sections(from: markdown)

        XCTAssertEqual(sections.map(\.category), [.added, .fixed])
        XCTAssertEqual(sections[0].items, ["支持自动检查更新"])
        XCTAssertEqual(sections[1].items, ["修复输入法问题"])
    }

    func testAcceptsNumberedAndPlusListItemsUsedByReleaseValidation() {
        let markdown = """
        ### Added
        1. Added automatic update checks

        ### Fixed
        + Fixed release-note parsing
        """

        let sections = UpdateReleaseNotesParser.sections(from: markdown)

        XCTAssertEqual(sections.map(\.category), [.added, .fixed])
        XCTAssertEqual(sections[0].items, ["Added automatic update checks"])
        XCTAssertEqual(sections[1].items, ["Fixed release-note parsing"])
    }

    func testFallbackRemovesBasicMarkdownAndGeneratedChangelog() {
        let markdown = """
        ## Version 0.2.2

        **A useful update** with `safer` downloads.

        Full Changelog: v0.2.1...v0.2.2
        """

        XCTAssertEqual(
            UpdateReleaseNotesParser.fallbackText(from: markdown),
            "Version 0.2.2\n\nA useful update with safer downloads."
        )
    }
}
