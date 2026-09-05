import SwiftUI

/// Uses IANA identifiers and actual dates, so summer/winter offsets are never
/// inferred from the current clock or a fixed UTC offset.
struct CalendarTimeZonePicker: View {
    @Binding var selection: String
    var allowsNone = false
    @Environment(\.appLanguage) private var language
    @State private var query = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(t("Time zone")).font(.system(size: 15, weight: .semibold))
            TextField(t("Search city or time zone"), text: $query)
                .textFieldStyle(.roundedBorder)
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 3) {
                    if allowsNone {
                        zoneButton(identifier: "", title: t("Off"))
                    }
                    ForEach(CalendarTimeZoneTools.search(query, locale: language.locale), id: \.self) { identifier in
                        zoneButton(identifier: identifier, title: CalendarTimeZoneTools.label(identifier, at: Date(), locale: language.locale))
                    }
                }
            }
            .frame(height: 270)
            Text(t("Offsets follow each event's date, including daylight saving time."))
                .font(.system(size: 11))
                .foregroundStyle(WorkspacePalette.secondaryText)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(18)
        .frame(width: 340)
        .foregroundStyle(WorkspacePalette.primaryText)
        .background(WorkspacePalette.elevated)
    }

    private func zoneButton(identifier: String, title: String) -> some View {
        Button {
            selection = identifier
        } label: {
            HStack(spacing: 10) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(title).font(.system(size: 12, weight: .medium))
                    if !identifier.isEmpty {
                        Text(identifier).font(.system(size: 10)).foregroundStyle(WorkspacePalette.secondaryText)
                    }
                }
                Spacer(minLength: 4)
                if selection == identifier { Image(systemName: "checkmark").foregroundStyle(WorkspacePalette.accent) }
            }
            .padding(9)
            .contentShape(Rectangle())
            .background(selection == identifier ? WorkspacePalette.hover : .clear, in: RoundedRectangle(cornerRadius: 7))
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(selection == identifier ? .isSelected : [])
    }

    private func t(_ key: String) -> String { L10n.string(key, language: language) }
}

struct CalendarToolsSettingsView: View {
    @ObservedObject var calendar: CalendarManager
    @Environment(\.appLanguage) private var language

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Toggle(L10n.string("Combine exact duplicates across calendars", language: language), isOn: Binding(
                get: { calendar.deduplicatesEvents }, set: { calendar.setDeduplicatesEvents($0) }
            ))
            Text(L10n.string("Matching title, time, location and meeting link appear once. Source events are never deleted; recurring dates stay separate.", language: language))
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
