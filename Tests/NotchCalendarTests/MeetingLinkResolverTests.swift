import Foundation
import XCTest
@testable import NotchCalendar

final class MeetingLinkResolverTests: XCTestCase {
    func testStructuredEventURLTakesPriorityOverFreeFormLinks() throws {
        let eventURL = try XCTUnwrap(URL(string: "https://calendar.example.com/rooms/weekly"))

        let link = MeetingLinkResolver.resolve(
            eventURL: eventURL,
            location: "https://zoom.us/j/111111111",
            notes: "Backup: https://meet.google.com/abc-defg-hij"
        )

        XCTAssertEqual(link, MeetingLink(url: eventURL, provider: .other))
    }

    func testRecognisesCommonMeetingProviders() throws {
        let examples: [(String, MeetingProvider)] = [
            ("https://acme.zoom.us/j/123456789", .zoom),
            ("https://meet.google.com/abc-defg-hij", .googleMeet),
            ("https://teams.microsoft.com/l/meetup-join/19%3ameeting", .microsoftTeams),
            ("https://company.webex.com/meet/alex", .webex),
            ("https://around.co/r/team-sync", .around),
            ("https://whereby.com/design-review", .whereby)
        ]

        for (rawURL, expectedProvider) in examples {
            let link = MeetingLinkResolver.resolve(
                eventURL: nil,
                location: nil,
                notes: "Join here: \(rawURL)"
            )

            XCTAssertEqual(link?.provider, expectedProvider, rawURL)
            XCTAssertEqual(link?.url.absoluteString, rawURL, rawURL)
        }
    }

    func testRejectsOrdinaryLinksInFreeFormText() {
        let link = MeetingLinkResolver.resolve(
            eventURL: nil,
            location: "Project page: https://example.com/roadmap",
            notes: "Read https://docs.example.org/brief before the meeting"
        )

        XCTAssertNil(link)
    }

    func testAcceptsGenericHTTPSLinkFromStructuredEventURL() throws {
        let eventURL = try XCTUnwrap(URL(string: "https://events.example.org/session/42"))

        let link = MeetingLinkResolver.resolve(
            eventURL: eventURL,
            location: nil,
            notes: nil
        )

        XCTAssertEqual(link?.url, eventURL)
        XCTAssertEqual(link?.provider, .other)
    }

    func testLocationTakesPriorityOverNotes() {
        let locationURL = "https://zoom.us/j/222222222"

        let link = MeetingLinkResolver.resolve(
            eventURL: nil,
            location: locationURL,
            notes: "Alternative: https://whereby.com/backup-room"
        )

        XCTAssertEqual(link?.url.absoluteString, locationURL)
        XCTAssertEqual(link?.provider, .zoom)
    }

    func testRejectsLookalikeMeetingDomains() {
        let link = MeetingLinkResolver.resolve(
            eventURL: nil,
            location: nil,
            notes: "Suspicious: https://zoom.us.attacker.example/j/123"
        )

        XCTAssertNil(link)
    }

    func testRejectsNonMeetingPagesOnKnownProviderDomains() {
        let ordinaryPages = [
            "https://zoom.us/download",
            "https://meet.google.com/landing",
            "https://teams.microsoft.com/downloads",
            "https://www.webex.com/pricing/index.html",
            "https://whereby.com/pricing"
        ]

        for page in ordinaryPages {
            let link = MeetingLinkResolver.resolve(
                eventURL: nil,
                location: nil,
                notes: "Reference: \(page)"
            )
            XCTAssertNil(link, page)
        }
    }

    func testPhysicalLocationPreservesRoomAndRemovesMeetingLink() {
        XCTAssertEqual(
            MeetingLinkResolver.physicalLocation(
                from: "Room 301 — https://zoom.us/j/123456789"
            ),
            "Room 301"
        )
        XCTAssertNil(
            MeetingLinkResolver.physicalLocation(
                from: "https://meet.google.com/abc-defg-hij"
            )
        )
    }
}
