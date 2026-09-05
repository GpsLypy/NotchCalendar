import AppKit
import Combine

enum MeetingJoinError: Error, LocalizedError {
    case calendarUnavailable, noMeeting, occurrenceUnavailable, openingFailed

    var messageKey: String {
        switch self {
        case .calendarUnavailable: "Allow Calendar access and show a calendar before joining a meeting."
        case .noMeeting: "No online meeting is active or starts within 15 minutes."
        case .occurrenceUnavailable: "This meeting ended, was removed, or belongs to a hidden calendar."
        case .openingFailed: "The meeting link could not be opened. Check your browser or meeting app, then try again."
        }
    }
    var errorDescription: String? { L10n.string(messageKey, language: AppLanguage.persisted()) }
}

@MainActor
final class MeetingAssistant: ObservableObject {
    let preferences: MeetingPreferences
    @Published private(set) var authorization: MeetingNotificationAuthorization = .notDetermined
    @Published private(set) var reminderMessageKey: String?
    @Published private(set) var shortcutMessageKey: String?
    @Published private(set) var scheduledReminderCount = 0
    @Published private(set) var nextMeeting: MeetingOccurrence?
    @Published private(set) var feedbackMessageKey: String?

    private let calendar: CalendarManager
    private let notifications: any MeetingNotificationScheduling
    private let hotKey: any MeetingHotKeyRegistering
    private let openURL: @MainActor (URL) -> Bool
    private let showError: @MainActor (String) -> Void
    private let now: @MainActor () -> Date
    private var subscriptions = Set<AnyCancellable>()
    private var refreshTask: Task<Void, Never>?
    private var needsRefresh = false
    private var generation = 0
    private var timer: Timer?
    private var isStarted = false
    private var registeredShortcut: String?
    private var knownPendingIdentifiers = Set<String>()
    private var isSleeping = false

    init(calendar: CalendarManager, preferences: MeetingPreferences = MeetingPreferences(),
         notifications: any MeetingNotificationScheduling = SystemMeetingNotificationClient(),
         hotKey: any MeetingHotKeyRegistering = MeetingHotKey(),
         now: @escaping @MainActor () -> Date = { Date() },
         openURL: @escaping @MainActor (URL) -> Bool = { NSWorkspace.shared.open($0) },
         showError: @escaping @MainActor (String) -> Void = { message in
             let alert = NSAlert()
             alert.messageText = L10n.string("Join meeting", language: AppLanguage.persisted())
             alert.informativeText = message
             alert.addButton(withTitle: L10n.string("OK", language: AppLanguage.persisted()))
             NSApp.activate(ignoringOtherApps: true)
             alert.runModal()
         }) {
        self.calendar = calendar; self.preferences = preferences
        self.notifications = notifications; self.hotKey = hotKey
        self.now = now; self.openURL = openURL; self.showError = showError
    }

    /// Call once after the application has acquired its single-instance lock.
    func start() {
        guard !isStarted else { return }
        isStarted = true
        if let client = notifications as? SystemMeetingNotificationClient {
            client.setDelegate(MeetingNotificationDelegate(action: { [weak self] key, action in
                await self?.handleNotificationAction(key: key, action: action)
            }, mayPresent: { [weak self] key, fireAt in
                self?.mayPresent(key: key, fireAt: fireAt) ?? false
            }))
        }
        calendar.$contentRevision.dropFirst().receive(on: RunLoop.main).sink { [weak self] _ in
            self?.requestReconciliation()
        }.store(in: &subscriptions)
        preferences.objectWillChange.receive(on: RunLoop.main).sink { [weak self] _ in
            self?.configureHotKey()
            self?.requestReconciliation()
        }.store(in: &subscriptions)
        NSWorkspace.shared.notificationCenter.publisher(for: NSWorkspace.willSleepNotification)
            .sink { [weak self] _ in self?.prepareForSleep() }.store(in: &subscriptions)
        NSWorkspace.shared.notificationCenter.publisher(for: NSWorkspace.didWakeNotification)
            .sink { [weak self] _ in self?.resumeAfterSleep() }.store(in: &subscriptions)
        let changes = [
            NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification),
            NotificationCenter.default.publisher(for: .NSSystemClockDidChange),
            NotificationCenter.default.publisher(for: .NSSystemTimeZoneDidChange),
            NotificationCenter.default.publisher(for: NSLocale.currentLocaleDidChangeNotification),
            NotificationCenter.default.publisher(for: UserDefaults.didChangeNotification)
        ]
        Publishers.MergeMany(changes).debounce(for: .milliseconds(150), scheduler: RunLoop.main)
            .sink { [weak self] _ in self?.requestReconciliation() }.store(in: &subscriptions)
        timer = .scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.requestReconciliation() }
        }
        configureHotKey()
        requestReconciliation()
    }

    /// Scheduled system reminders survive normal app termination; hotkeys do not.
    func stop() {
        isStarted = false
        timer?.invalidate(); timer = nil
        subscriptions.removeAll()
        refreshTask?.cancel(); refreshTask = nil
        hotKey.unregister(); registeredShortcut = nil
        (notifications as? SystemMeetingNotificationClient)?.setDelegate(nil)
    }

    func reloadPreferences() {
        preferences.reload()
        configureHotKey()
        requestReconciliation()
    }

    /// Only this explicit settings action is allowed to request system permission.
    func setRemindersEnabled(_ enabled: Bool) async {
        preferences.remindersEnabled = enabled
        if enabled {
            let current = await notifications.authorization()
            if current == .notDetermined {
                do { _ = try await notifications.requestAuthorization() }
                catch { reminderMessageKey = "Notification permission could not be requested. Open System Settings to allow notifications." }
            }
        }
        await refreshNow()
    }

    @discardableResult
    func joinNextMeeting() async throws -> MeetingOccurrence {
        guard calendar.isCalendarAccessGranted else { throw MeetingJoinError.calendarUnavailable }
        calendar.refresh(now: now())
        guard let meeting = MeetingReminderEngine.nextToJoin(meetings: currentMeetings(), now: now()) else {
            throw MeetingJoinError.noMeeting
        }
        try open(meeting)
        return meeting
    }

    /// For a user-facing button or the registered hotkey. App Intents can call
    /// joinNextMeeting directly and return its thrown, localized error.
    func joinFromUserAction() {
        Task { @MainActor in
            do { _ = try await joinNextMeeting() }
            catch { present(error) }
        }
    }

    func snooze(_ meeting: MeetingOccurrence, minutes: Int) async {
        guard preferences.remindersEnabled else { return }
        let current = currentMeetings().first { $0.key == meeting.key }
        guard let current, let value = MeetingReminderEngine.snooze(meeting: current, minutes: minutes, now: now()) else {
            feedbackMessageKey = "This meeting ends before the delayed reminder."
            return
        }
        for key in current.allKeys { preferences.setOverride(value, for: key) }
        feedbackMessageKey = minutes == 5 ? "Reminder delayed by 5 minutes." : "Reminder delayed by 10 minutes."
        await refreshNow()
    }

    func ignore(_ meeting: MeetingOccurrence) async {
        for key in meeting.allKeys {
            preferences.setOverride(MeetingReminderOverride(kind: .dismissed, fireAt: nil,
                                                           expiresAt: meeting.end.addingTimeInterval(MeetingReminderEngine.overrideRetention)), for: key)
        }
        feedbackMessageKey = "This occurrence will not remind you again."
        await refreshNow()
    }

    func openNotificationSettings() {
        guard let url = URL(string: "x-apple.systempreferences:com.apple.Notifications-Settings.extension") else { return }
        if !openURL(url) { reminderMessageKey = "Open System Settings → Notifications → Notch Calendar to allow notifications." }
    }

    func refreshNow() async {
        requestReconciliation()
        await refreshTask?.value
    }

    /// Remove known requests synchronously before suspension so waking cannot
    /// release a queue of missed alerts. Future deadlines are rebuilt on wake.
    func prepareForSleep() {
        isSleeping = true
        generation &+= 1
        notifications.removePending(Array(knownPendingIdentifiers))
        knownPendingIdentifiers.removeAll()
        scheduledReminderCount = 0
    }

    func resumeAfterSleep() {
        isSleeping = false
        calendar.refresh(now: now())
        requestReconciliation()
    }

    private func requestReconciliation() {
        generation &+= 1
        needsRefresh = true
        guard refreshTask == nil else { return }
        refreshTask = Task { @MainActor [weak self] in
            guard let self else { return }
            while self.needsRefresh && !Task.isCancelled {
                self.needsRefresh = false
                await self.reconcile(generation: self.generation)
            }
            self.refreshTask = nil
        }
    }

    private func currentMeetings() -> [MeetingOccurrence] {
        let date = now()
        return MeetingReminderEngine.unique(calendar.events(from: date.addingTimeInterval(-24 * 60 * 60),
                                                           to: date.addingTimeInterval(MeetingReminderEngine.horizon))
            .compactMap(MeetingOccurrence.init(event:)))
    }

    private func reconcile(generation expectedGeneration: Int) async {
        guard !isSleeping else { return }
        let date = now()
        preferences.pruneOverrides(now: date)
        let meetings = currentMeetings()
        nextMeeting = MeetingReminderEngine.nextToJoin(meetings: meetings, now: date)
            ?? meetings.first(where: { $0.start > date })
        let language = AppLanguage.persisted()
        notifications.prepare(language: language)
        authorization = await notifications.authorization()
        let pending = await notifications.pending()
        let delivered = await notifications.delivered()
        guard expectedGeneration == generation, !Task.isCancelled else { return }
        knownPendingIdentifiers = Set(pending.keys.filter { $0.hasPrefix(MeetingReminderPlan.identifierPrefix) })
        let enabled = preferences.remindersEnabled && authorization == .allowed && calendar.isCalendarAccessGranted
        let plans = enabled ? MeetingReminderEngine.plans(meetings: meetings, now: now(), leadMinutes: preferences.leadMinutes,
                                                         overrides: preferences.overrides) : []
        let changes = MeetingReminderEngine.reconciliation(pending: pending, desired: plans)
        notifications.removePending(changes.remove)
        knownPendingIdentifiers.subtract(changes.remove)
        let currentByKey = Dictionary(uniqueKeysWithValues: meetings.map { ($0.key, $0) })
        let staleDelivered = delivered.filter { reminder in
            guard enabled, let meeting = currentByKey[reminder.occurrenceKey],
                  meeting.end > date, reminder.eventEnd == meeting.end else { return true }
            let decisions = meeting.allKeys.compactMap { preferences.overrides[$0] }
            if decisions.contains(where: { $0.kind == .dismissed }) { return true }
            if let snooze = decisions.filter({ $0.kind == .snoozed }).max(by: { ($0.fireAt ?? .distantPast) < ($1.fireAt ?? .distantPast) }) {
                return reminder.fireAt != snooze.fireAt
            }
            return false
        }.map(\.identifier)
        notifications.removeDelivered(staleDelivered)
        reminderMessageKey = reminderStatus()
        var successful = plans.count - changes.add.count
        for plan in changes.add {
            guard expectedGeneration == generation, !Task.isCancelled else { return }
            // Time can advance during asynchronous notification operations.
            guard plan.fireAt > now() else { continue }
            do {
                try await notifications.add(plan, language: language)
                if isSleeping || Task.isCancelled {
                    notifications.removePending([plan.identifier])
                    return
                }
                knownPendingIdentifiers.insert(plan.identifier)
                successful += 1
            }
            catch { reminderMessageKey = "Some reminders could not be scheduled. Refresh to retry." }
        }
        scheduledReminderCount = successful
    }

    private func reminderStatus() -> String? {
        guard preferences.remindersEnabled else { return nil }
        if authorization == .denied { return "Notifications are disabled in System Settings. Allow them to receive meeting reminders." }
        if authorization == .notDetermined { return "Turn reminders off and on to allow notifications on this Mac." }
        if !calendar.isCalendarAccessGranted { return "Allow Calendar access and show a calendar before scheduling reminders." }
        if calendar.selectedCalendarCount == 0 { return "Show a calendar to schedule meeting reminders." }
        return nil
    }

    private func configureHotKey() {
        guard preferences.hotKeyEnabled, isStarted else {
            hotKey.unregister(); registeredShortcut = nil; shortcutMessageKey = nil
            return
        }
        let descriptor = preferences.hotKeyModifiers.rawValue + preferences.hotKeyLetter
        guard registeredShortcut != descriptor else { return }
        let success = hotKey.register(letter: preferences.hotKeyLetter, modifiers: preferences.hotKeyModifiers) { [weak self] in
            self?.joinFromUserAction()
        }
        registeredShortcut = success ? descriptor : nil
        shortcutMessageKey = success ? nil : "This shortcut is unavailable or used by another app. Choose another combination."
    }

    private func mayPresent(key: String, fireAt: Date) -> Bool {
        guard !isSleeping, preferences.remindersEnabled, now().timeIntervalSince(fireAt) < 60,
              let meeting = currentMeetings().first(where: { $0.key == key }), meeting.end > now() else { return false }
        if let override = preferences.overrides[key] {
            return override.kind == .snoozed && override.fireAt == fireAt
        }
        return true
    }

    private func handleNotificationAction(key: String, action: MeetingNotificationAction) async {
        calendar.refresh(now: now())
        guard let meeting = currentMeetings().first(where: { $0.key == key }), meeting.end > now() else {
            if action == .join { present(MeetingJoinError.occurrenceUnavailable) }
            await refreshNow()
            return
        }
        switch action {
        case .join:
            do { try open(meeting); await ignore(meeting) }
            catch { present(error) }
        case .snooze5: await snooze(meeting, minutes: 5)
        case .snooze10: await snooze(meeting, minutes: 10)
        case .dismiss: await ignore(meeting)
        }
    }

    private func open(_ meeting: MeetingOccurrence) throws {
        guard openURL(meeting.url) else { throw MeetingJoinError.openingFailed }
        feedbackMessageKey = nil
    }

    private func present(_ error: Error) {
        if let error = error as? MeetingJoinError { feedbackMessageKey = error.messageKey }
        showError(error.localizedDescription)
    }
}
