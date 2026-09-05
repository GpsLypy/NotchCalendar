import AppKit
import SwiftUI
import UniformTypeIdentifiers

struct FocusWeeklyReviewView: View {
    let records: [FocusHistoryRecord]
    let now: Date
    @Environment(\.appLanguage) private var appLanguage
    @State private var weekOffset = 0
    @State private var exportFeedback: String?
    @State private var exportFailed = false

    private var review: FocusWeeklyReview {
        FocusWeeklyReview(records: records, weekContaining: Calendar.current.date(byAdding: .weekOfYear, value: weekOffset, to: now) ?? now, now: now)
    }

    var body: some View {
        WorkspaceCard {
            VStack(alignment: .leading, spacing: 18) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(t("Weekly review")).font(.system(size: 17, weight: .semibold, design: .rounded))
                        Text(dateRange).font(.system(size: 11)).foregroundStyle(WorkspacePalette.secondaryText)
                    }
                    Spacer()
                    Button { weekOffset -= 1 } label: { Image(systemName: "chevron.left") }
                        .help(t("Previous week"))
                        .disabled(weekOffset <= -520)
                    Button(t("This week")) { weekOffset = 0 }.disabled(weekOffset == 0)
                    Button { weekOffset += 1 } label: { Image(systemName: "chevron.right") }
                        .help(t("Next week"))
                        .disabled(weekOffset >= 0)
                    Button(action: export) { Image(systemName: "square.and.arrow.up") }.help(t("Export weekly review"))
                }
                .buttonStyle(.bordered).controlSize(.small)

                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(t("%@ min", "\(review.minutes)")).font(.system(size: 30, weight: .semibold, design: .rounded)).monospacedDigit()
                    Text(t("%@ focus sessions", "\(review.sessions)")).font(.system(size: 12)).foregroundStyle(WorkspacePalette.secondaryText)
                }

                HStack(alignment: .bottom, spacing: 12) {
                    ForEach(review.days) { day in
                        VStack(spacing: 7) {
                            Text("\(day.minutes)").font(.system(size: 10, design: .monospaced)).foregroundStyle(WorkspacePalette.secondaryText)
                            RoundedRectangle(cornerRadius: 5)
                                .fill(day.minutes > 0 ? WorkspacePalette.accent : WorkspacePalette.stroke)
                                .frame(height: max(3, 72 * Double(day.minutes) / Double(max(1, review.days.map(\.minutes).max() ?? 1))))
                            Text(day.date.formatted(.dateTime.weekday(.abbreviated).locale(appLanguage.locale)))
                                .font(.system(size: 10)).foregroundStyle(WorkspacePalette.secondaryText)
                        }
                        .frame(maxWidth: .infinity, alignment: .bottom)
                        .accessibilityElement(children: .ignore)
                        .accessibilityLabel("\(day.date.formatted(.dateTime.month().day().locale(appLanguage.locale))), \(t("%@ min", "\(day.minutes)"))")
                    }
                }
                .frame(height: 110, alignment: .bottom)

                Divider().overlay(WorkspacePalette.stroke)
                if review.tasks.isEmpty {
                    Text(t("No completed focus sessions this week.")).font(.system(size: 12)).foregroundStyle(WorkspacePalette.secondaryText)
                } else {
                    Text(t("Task labels")).font(.system(size: 11, weight: .semibold)).foregroundStyle(WorkspacePalette.secondaryText)
                    ForEach(review.tasks.prefix(8)) { task in
                        HStack {
                            Label(task.label ?? t("Unlabeled"), systemImage: "tag").lineLimit(2)
                            Spacer()
                            Text(t("%@ min", "\(task.minutes)")).monospacedDigit()
                        }.font(.system(size: 12))
                    }
                    if review.tasks.count > 8 {
                        Text(t("%@ more labels are included in the export.", "\(review.tasks.count - 8)")).font(.system(size: 10))
                    }
                }
                Text(t("This review uses retained local completions only. Breaks and unfinished sessions are excluded."))
                    .font(.system(size: 10.5)).foregroundStyle(WorkspacePalette.secondaryText)
                if let exportFeedback {
                    Label(exportFeedback, systemImage: exportFailed ? "exclamationmark.triangle" : "checkmark.circle")
                        .font(.system(size: 11)).foregroundStyle(exportFailed ? .orange : WorkspacePalette.success)
                }
            }
            .foregroundStyle(WorkspacePalette.primaryText)
            .padding(20)
        }
    }

    private var dateRange: String {
        let end = Calendar.current.date(byAdding: .day, value: -1, to: review.interval.end) ?? review.interval.start
        let style = Date.FormatStyle.dateTime.year().month().day().locale(appLanguage.locale)
        return "\(review.interval.start.formatted(style)) – \(end.formatted(style))"
    }

    private func export() {
        let content = review.markdown(language: appLanguage)
        let panel = NSSavePanel()
        panel.allowedContentTypes = [UTType(filenameExtension: "md") ?? .plainText]
        panel.nameFieldStringValue = "Notch-weekly-review.md"
        panel.title = t("Export weekly review")
        panel.begin { response in
            Task { @MainActor in
                guard response == .OK, let url = panel.url else { return }
                do {
                    try content.write(to: url, atomically: true, encoding: .utf8)
                    exportFailed = false
                    exportFeedback = t("Saved %@", url.lastPathComponent)
                } catch {
                    exportFailed = true
                    exportFeedback = error.localizedDescription
                }
            }
        }
    }
    private func t(_ key: String, _ arguments: CVarArg...) -> String { L10n.string(key, language: appLanguage, arguments: arguments) }
}
