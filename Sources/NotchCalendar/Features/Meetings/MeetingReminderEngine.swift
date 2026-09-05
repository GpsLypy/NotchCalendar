import Foundation
import CryptoKit

/// A value snapshot prevents EventKit objects from crossing notification queues.
struct MeetingOccurrence: Equatable, Sendable {
    let key: String
    let title: String
    let start: Date
    let end: Date
    let url: URL
    let provider: String
    let relatedKeys: [String]

    var allKeys: [String] { Array(Set([key] + relatedKeys)).sorted() }

    init?(event: CalendarEvent) {
        guard event.isEligibleForMeeting, !event.isAllDay,
              event.endDate > event.startDate, let link = event.meetingLink else { return nil }
        key = event.occurrenceStableID
        title = event.title
        start = event.startDate
        end = event.endDate
        url = link.url
        provider = link.provider.rawValue
        relatedKeys = event.relatedOccurrenceIDs
    }

    init(key: String, title: String, start: Date, end: Date, url: URL, provider: String = "other", relatedKeys: [String] = []) {
        self.key = key; self.title = title; self.start = start; self.end = end
        self.url = url; self.provider = provider
        self.relatedKeys = relatedKeys
    }
}

struct MeetingReminderOverride: Codable, Equatable, Sendable {
    enum Kind: String, Codable, Sendable { case snoozed, dismissed }
    var kind: Kind
    var fireAt: Date?
    var expiresAt: Date
}

struct MeetingReminderPlan: Equatable, Sendable {
    static let identifierPrefix = "meetings.reminder."
    let meeting: MeetingOccurrence
    let fireAt: Date

    var identifier: String { Self.identifierPrefix + Self.digest(meeting.key) }
    var fingerprint: String {
        Self.digest("\(meeting.key)|\(meeting.title)|\(meeting.start.timeIntervalSince1970)|\(meeting.end.timeIntervalSince1970)|\(meeting.url.absoluteString)|\(fireAt.timeIntervalSince1970)")
    }
    private static func digest(_ text: String) -> String {
        SHA256.hash(data: Data(text.utf8)).map { String(format: "%02x", $0) }.joined()
    }
}

enum MeetingReminderEngine {
    static let horizon: TimeInterval = 24 * 60 * 60
    static let requestLimit = 32
    // Retain occurrence decisions beyond the original end so a reschedule does
    // not silently revive a dismissed occurrence. This stores no event content.
    static let overrideRetention: TimeInterval = 30 * 24 * 60 * 60

    static func unique(_ meetings: [MeetingOccurrence]) -> [MeetingOccurrence] {
        var keys = Set<String>()
        return meetings.sorted {
            $0.start == $1.start ? $0.key < $1.key : $0.start < $1.start
        }.filter { keys.insert($0.key).inserted }
    }

    static func plans(meetings: [MeetingOccurrence], now: Date, leadMinutes: Int,
                      overrides: [String: MeetingReminderOverride]) -> [MeetingReminderPlan] {
        unique(meetings).compactMap { meeting -> MeetingReminderPlan? in
            guard meeting.end > meeting.start, meeting.end > now, meeting.start < now.addingTimeInterval(horizon) else { return nil }
            let applicable = meeting.allKeys.compactMap { overrides[$0] }.filter { $0.expiresAt > now }
            let override = applicable.first(where: { $0.kind == .dismissed })
                ?? applicable.max(by: { ($0.fireAt ?? .distantPast) < ($1.fireAt ?? .distantPast) })
            if override?.kind == .dismissed { return nil }
            let fireAt = override?.kind == .snoozed
                ? override?.fireAt
                : meeting.start.addingTimeInterval(-Double(min(max(leadMinutes, 1), 60)) * 60)
            // Never replay reminders whose deadline passed while sleeping or quit.
            guard let fireAt, fireAt > now, fireAt < meeting.end else { return nil }
            return MeetingReminderPlan(meeting: meeting, fireAt: fireAt)
        }.sorted { $0.fireAt == $1.fireAt ? $0.identifier < $1.identifier : $0.fireAt < $1.fireAt }
            .prefix(requestLimit).map { $0 }
    }

    static func snooze(meeting: MeetingOccurrence, minutes: Int, now: Date) -> MeetingReminderOverride? {
        guard [5, 10].contains(minutes) else { return nil }
        let fireAt = now.addingTimeInterval(Double(minutes) * 60)
        guard fireAt < meeting.end else { return nil }
        return MeetingReminderOverride(kind: .snoozed, fireAt: fireAt, expiresAt: meeting.end.addingTimeInterval(overrideRetention))
    }

    static func nextToJoin(meetings: [MeetingOccurrence], now: Date) -> MeetingOccurrence? {
        let available = unique(meetings).filter { $0.end > now }
        // With overlapping meetings, the most recently started occurrence wins.
        if let active = available.filter({ $0.start <= now }).max(by: { $0.start < $1.start }) { return active }
        return available.first { $0.start <= now.addingTimeInterval(15 * 60) }
    }

    static func reconciliation(pending: [String: String], desired: [MeetingReminderPlan])
        -> (remove: [String], add: [MeetingReminderPlan]) {
        let desiredByID = Dictionary(uniqueKeysWithValues: desired.map { ($0.identifier, $0.fingerprint) })
        let remove = pending.keys.filter {
            $0.hasPrefix(MeetingReminderPlan.identifierPrefix) && pending[$0] != desiredByID[$0]
        }.sorted()
        return (remove, desired.filter { pending[$0.identifier] != $0.fingerprint })
    }
}
