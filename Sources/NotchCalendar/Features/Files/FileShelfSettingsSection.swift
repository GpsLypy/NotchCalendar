import SwiftUI

struct FileShelfSettingsSection: View {
    @ObservedObject var store: FileShelfStore
    @Environment(\.appLanguage) private var appLanguage

    var body: some View {
        Section(t("File Shelf")) {
            Toggle(t("Enable the file shelf in the notch"), isOn: $store.isEnabled)

            if store.locations.isEmpty {
                Text(t("Add folders that should appear in the file shelf sidebar."))
                    .foregroundStyle(.secondary)
            } else {
                ForEach(store.locations) { location in
                    HStack(spacing: 10) {
                        Image(systemName: "folder.fill")
                            .foregroundStyle(.blue)
                            .frame(width: 18)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(location.name)
                                .lineLimit(1)
                            Text(location.url.path(percentEncoded: false))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                                .truncationMode(.middle)
                        }
                        Spacer(minLength: 8)
                        Button { store.moveLocation(location.id, by: -1) } label: {
                            Image(systemName: "chevron.up")
                        }
                        .disabled(!store.canMoveLocation(location.id, by: -1))
                        .help(t("Move Up"))
                        Button { store.moveLocation(location.id, by: 1) } label: {
                            Image(systemName: "chevron.down")
                        }
                        .disabled(!store.canMoveLocation(location.id, by: 1))
                        .help(t("Move Down"))
                        Button { store.reveal(location.url) } label: {
                            Image(systemName: "magnifyingglass")
                        }
                        .help(t("Show in Finder"))
                        Button(role: .destructive) { store.removeLocation(location.id) } label: {
                            Image(systemName: "trash")
                        }
                        .help(t("Remove"))
                    }
                }
            }

            HStack {
                Button { store.chooseRootDirectories() } label: {
                    Label(t("Add Folders"), systemImage: "plus")
                }
                .disabled(store.locations.count >= FileShelfStore.maximumLocations)
                Spacer()
                Text(t("%@ of %@ folders", "\(store.locations.count)", "\(FileShelfStore.maximumLocations)"))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Toggle(t("Show hidden files"), isOn: $store.showsHiddenFiles)
                .disabled(!store.isEnabled)

            Picker(t("Sort files by"), selection: $store.sort) {
                ForEach(FileShelfSort.allCases) { sort in
                    Text(t(sort.titleKey)).tag(sort)
                }
            }
            .pickerStyle(.menu)
            .disabled(!store.isEnabled)

            Text(t("Drag files out to other apps. Dragging files over the compact notch opens the shelf without moving them."))
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private func t(_ key: String, _ arguments: CVarArg...) -> String {
        L10n.string(key, language: appLanguage, arguments: arguments)
    }
}
