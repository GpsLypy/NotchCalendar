import Foundation

struct WorkspaceCommand: Identifiable {
    enum Action {
        case navigate(WorkspaceDestination)
        case inspectEvent(CalendarEvent)
        case toggleFocus
    }
    let id: String
    let title: String
    let detail: String
    let symbol: String
    let searchTerms: String
    let action: Action
}

enum WorkspaceCommandCatalog {
    static func commands(events: [CalendarEvent], language: AppLanguage, hasSession: Bool, isRunning: Bool) -> [WorkspaceCommand] {
        var result = WorkspaceDestination.allCases.map { destination in
            WorkspaceCommand(id: "page:\(destination.id)",
                             title: L10n.string(destination.titleKey, language: language),
                             detail: L10n.string("Open page", language: language),
                             symbol: destination.systemImage,
                             searchTerms: "\(destination.titleKey) \(L10n.string(destination.titleKey, language: .simplifiedChinese))",
                             action: .navigate(destination))
        }
        if hasSession {
            result.insert(WorkspaceCommand(id: "focus:toggle",
                                           title: L10n.string(isRunning ? "Pause timer" : "Resume timer", language: language),
                                           detail: L10n.string("Current session", language: language),
                                           symbol: isRunning ? "pause.circle" : "play.circle",
                                           searchTerms: "focus break timer pause resume 专注 休息 计时 暂停 继续",
                                           action: .toggleFocus), at: 0)
        }
        var seen: Set<String> = []
        for event in events.sorted(by: { $0.startDate < $1.startDate }) where seen.insert(event.occurrenceStableID).inserted {
            result.append(WorkspaceCommand(id: "event:\(event.occurrenceStableID)",
                                           title: event.displayTitle(language: language),
                                           detail: "\(event.isAllDay ? L10n.string("All day", language: language) : event.startDate.shortTime(locale: language.locale)) · \(event.calendarName)",
                                           symbol: "calendar.badge.clock",
                                           searchTerms: "\(event.calendarName) \(event.location ?? "")",
                                           action: .inspectEvent(event)))
        }
        return result
    }

    static func matching(_ query: String, in commands: [WorkspaceCommand]) -> [WorkspaceCommand] {
        let terms = query.split(whereSeparator: \.isWhitespace).map(String.init)
        return commands.filter { command in
            let text = "\(command.title) \(command.detail) \(command.searchTerms)"
            return terms.allSatisfy { text.localizedStandardContains($0) }
        }
    }
}
