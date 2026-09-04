import SwiftUI

enum NotchWidgetPalette {
    static let canvas = Color(red: 19 / 255, green: 19 / 255, blue: 22 / 255)
    static let coral = Color(red: 244 / 255, green: 59 / 255, blue: 91 / 255)
    static let primary = Color.white.opacity(0.94)
    static let secondary = Color.white.opacity(0.55)
    static let subdued = Color.white.opacity(0.16)
}

enum NotchWidgetDestination {
    static let calendar = URL(string: "notchcalendar://calendar")!
    static let focus = URL(string: "notchcalendar://focus")!
    static let today = URL(string: "notchcalendar://today")!
}

struct NotchWidgetCanvas<Content: View>: View {
    private let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(14)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .containerBackground(for: .widget) {
                NotchWidgetPalette.canvas
            }
    }
}

struct NotchWidgetRingProgressStyle: ProgressViewStyle {
    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            Circle()
                .stroke(NotchWidgetPalette.subdued, lineWidth: 7)

            Circle()
                .trim(from: 0, to: clampedProgress(configuration.fractionCompleted))
                .stroke(
                    NotchWidgetPalette.coral,
                    style: StrokeStyle(lineWidth: 7, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
        }
    }

    private func clampedProgress(_ progress: Double?) -> Double {
        min(1, max(0, progress ?? 0))
    }
}

struct NotchWidgetHeader<Trailing: View>: View {
    let title: String
    private let trailing: Trailing

    init(
        title: String,
        @ViewBuilder trailing: () -> Trailing
    ) {
        self.title = title
        self.trailing = trailing()
    }

    var body: some View {
        HStack(spacing: 7) {
            Capsule()
                .fill(NotchWidgetPalette.coral)
                .frame(width: 24, height: 3)

            Text(title)
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundStyle(NotchWidgetPalette.primary)
                .lineLimit(1)

            Spacer(minLength: 4)
            trailing
        }
    }
}

extension NotchWidgetHeader where Trailing == EmptyView {
    init(title: String) {
        self.init(title: title) {
            EmptyView()
        }
    }
}

struct NotchWidgetGuidance: View {
    let symbol: String
    let title: String
    let detail: String

    var body: some View {
        VStack(alignment: .leading, spacing: 9) {
            Image(systemName: symbol)
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(NotchWidgetPalette.coral)

            Spacer(minLength: 0)

            Text(title)
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundStyle(NotchWidgetPalette.primary)
                .lineLimit(2)

            Text(detail)
                .font(.system(size: 10, weight: .medium, design: .rounded))
                .foregroundStyle(NotchWidgetPalette.secondary)
                .fixedSize(horizontal: false, vertical: true)
                .lineLimit(3)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
    }
}

struct NotchWidgetCopy {
    let isChinese: Bool

    init(localizationIdentifier: String?) {
        let identifier = localizationIdentifier ?? Locale.current.identifier
        isChinese = identifier.lowercased().hasPrefix("zh")
    }

    var monthWidgetName: String { isChinese ? "月历" : "Month" }
    var agendaWidgetName: String { isChinese ? "今日日程" : "Today" }
    var focusWidgetName: String { isChinese ? "专注" : "Focus" }
    var allDay: String { isChinese ? "全天" : "All day" }
    var noEventsTitle: String { isChinese ? "今天暂无日程" : "A clear day" }
    var noEventsDetail: String { isChinese ? "留一点时间给自己" : "Keep a little time for yourself" }
    var untitledEvent: String { isChinese ? "未命名日程" : "Untitled event" }
    var calendarSetupTitle: String { isChinese ? "等待日历同步" : "Waiting for calendar" }
    var calendarSetupDetail: String {
        isChinese ? "打开 Notch Calendar 完成组件同步" : "Open Notch Calendar to sync this widget"
    }
    var calendarPermissionTitle: String { isChinese ? "需要日历权限" : "Calendar access needed" }
    var calendarPermissionDetail: String {
        isChinese ? "在 Notch Calendar 中允许日历访问" : "Allow calendar access in Notch Calendar"
    }
    var focusSetupTitle: String { isChinese ? "等待专注同步" : "Waiting for Focus" }
    var focusSetupDetail: String {
        isChinese ? "打开 Notch Calendar 设置专注时长" : "Open Notch Calendar to set a focus timer"
    }
    var ready: String { isChinese ? "准备开始" : "Ready" }
    var running: String { isChinese ? "专注中" : "In focus" }
    var paused: String { isChinese ? "已暂停" : "Paused" }
    var complete: String { isChinese ? "本轮完成" : "Complete" }
    var sessions: String { isChinese ? "轮" : "sessions" }
}
