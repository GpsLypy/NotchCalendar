@preconcurrency import UserNotifications
import Foundation

enum MeetingNotificationAuthorization: Equatable, Sendable { case notDetermined, allowed, denied }

struct MeetingDeliveredReminder: Sendable {
    let identifier: String
    let occurrenceKey: String
    let eventEnd: Date
    let fireAt: Date
}

@MainActor
protocol MeetingNotificationScheduling: AnyObject {
    func authorization() async -> MeetingNotificationAuthorization
    func requestAuthorization() async throws -> Bool
    func prepare(language: AppLanguage)
    func pending() async -> [String: String]
    func delivered() async -> [MeetingDeliveredReminder]
    func removePending(_ identifiers: [String])
    func removeDelivered(_ identifiers: [String])
    func add(_ plan: MeetingReminderPlan, language: AppLanguage) async throws
}

enum MeetingNotificationAction: String, Sendable {
    case join = "meetings.join", snooze5 = "meetings.snooze5", snooze10 = "meetings.snooze10", dismiss = "meetings.dismiss"
}

/// All delegate callbacks are explicitly nonisolated and carry only Sendable values
/// into the assistant. UserNotifications may invoke them on its background queue.
final class MeetingNotificationDelegate: NSObject, UNUserNotificationCenterDelegate, Sendable {
    let action: @MainActor @Sendable (String, MeetingNotificationAction) async -> Void
    let mayPresent: @MainActor @Sendable (String, Date) -> Bool

    init(action: @escaping @MainActor @Sendable (String, MeetingNotificationAction) async -> Void,
         mayPresent: @escaping @MainActor @Sendable (String, Date) -> Bool) {
        self.action = action
        self.mayPresent = mayPresent
    }

    nonisolated func userNotificationCenter(_ center: UNUserNotificationCenter,
                                           didReceive response: UNNotificationResponse) async {
        let info = response.notification.request.content.userInfo
        guard let key = info["occurrence"] as? String else { return }
        let actionID = response.actionIdentifier
        // Clicking the body is an explicit request to join this occurrence.
        let selected = actionID == UNNotificationDefaultActionIdentifier ? MeetingNotificationAction.join
            : MeetingNotificationAction(rawValue: actionID)
        guard let selected else { return }
        await action(key, selected)
    }

    nonisolated func userNotificationCenter(_ center: UNUserNotificationCenter,
                                           willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        let info = notification.request.content.userInfo
        guard let key = info["occurrence"] as? String,
              let fire = info["fireAt"] as? Double,
              await mayPresent(key, Date(timeIntervalSince1970: fire)) else { return [] }
        return [.banner, .list, .sound]
    }
}

@MainActor
final class SystemMeetingNotificationClient: MeetingNotificationScheduling {
    private let center: UNUserNotificationCenter
    // The center holds its delegate weakly.
    private var retainedDelegate: MeetingNotificationDelegate?
    static let category = "meetings.reminder"

    init(center: UNUserNotificationCenter = .current()) { self.center = center }

    func setDelegate(_ delegate: MeetingNotificationDelegate?) {
        retainedDelegate = delegate
        center.delegate = delegate
    }

    func authorization() async -> MeetingNotificationAuthorization {
        let settings = await center.notificationSettings()
        switch settings.authorizationStatus {
        case .authorized, .provisional, .ephemeral: return .allowed
        case .notDetermined: return .notDetermined
        default: return .denied
        }
    }

    func requestAuthorization() async throws -> Bool {
        try await center.requestAuthorization(options: [.alert, .sound])
    }

    func prepare(language: AppLanguage) {
        let actions = [
            UNNotificationAction(identifier: MeetingNotificationAction.join.rawValue,
                                 title: L10n.string("Join meeting", language: language), options: [.foreground]),
            UNNotificationAction(identifier: MeetingNotificationAction.snooze5.rawValue,
                                 title: L10n.string("Remind in 5 minutes", language: language)),
            UNNotificationAction(identifier: MeetingNotificationAction.snooze10.rawValue,
                                 title: L10n.string("Remind in 10 minutes", language: language)),
            UNNotificationAction(identifier: MeetingNotificationAction.dismiss.rawValue,
                                 title: L10n.string("Ignore this occurrence", language: language))
        ]
        center.setNotificationCategories([UNNotificationCategory(identifier: Self.category, actions: actions, intentIdentifiers: [])])
    }

    func pending() async -> [String: String] {
        let requests = await center.pendingNotificationRequests()
        return Dictionary(uniqueKeysWithValues: requests.filter { $0.identifier.hasPrefix(MeetingReminderPlan.identifierPrefix) }.map {
            ($0.identifier, $0.content.userInfo["fingerprint"] as? String ?? "")
        })
    }

    func delivered() async -> [MeetingDeliveredReminder] {
        await center.deliveredNotifications().compactMap { notification in
            let request = notification.request
            guard request.identifier.hasPrefix(MeetingReminderPlan.identifierPrefix) else { return nil }
            let info = request.content.userInfo
            return MeetingDeliveredReminder(identifier: request.identifier, occurrenceKey: info["occurrence"] as? String ?? "",
                                            eventEnd: Date(timeIntervalSince1970: info["end"] as? Double ?? 0),
                                            fireAt: Date(timeIntervalSince1970: info["fireAt"] as? Double ?? 0))
        }
    }

    func removePending(_ identifiers: [String]) { center.removePendingNotificationRequests(withIdentifiers: identifiers) }
    func removeDelivered(_ identifiers: [String]) { center.removeDeliveredNotifications(withIdentifiers: identifiers) }

    func add(_ plan: MeetingReminderPlan, language: AppLanguage) async throws {
        let content = UNMutableNotificationContent()
        content.title = plan.meeting.title.isEmpty ? L10n.string("Untitled event", language: language) : plan.meeting.title
        let date = DateFormatter()
        date.locale = language.locale
        date.dateStyle = .none
        date.timeStyle = .short
        content.body = L10n.string("Meeting at %@ · Click to join", language: language, date.string(from: plan.meeting.start))
        content.sound = .default
        content.categoryIdentifier = Self.category
        content.userInfo = ["occurrence": plan.meeting.key, "fingerprint": plan.fingerprint,
                            "end": plan.meeting.end.timeIntervalSince1970, "fireAt": plan.fireAt.timeIntervalSince1970]
        // An absolute date survives clock changes; the assistant also reconciles on wake.
        var components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: plan.fireAt)
        components.timeZone = .current
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        try await center.add(UNNotificationRequest(identifier: plan.identifier, content: content, trigger: trigger))
    }
}
