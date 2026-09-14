import SwiftUI

struct FileShelfSettingsSection: View {
    @ObservedObject var store: FileShelfStore
    @Environment(\.appLanguage) private var appLanguage

    var body: some View {
        Section(t("File Shelf")) {
            Toggle(t("Enable the file shelf in the notch"), isOn: $store.isEnabled)

            if let rootURL = store.rootURL {
                LabeledContent(t("Folder")) {
                    Text(rootURL.path(percentEncoded: false))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .truncationMode(.middle)
                }
                HStack {
                    Button(t("Choose Another Folder")) { store.chooseRootDirectory() }
                    Button(t("Show in Finder")) { store.reveal(rootURL) }
                    Spacer()
                    Button(t("Remove"), role: .destructive) { store.clearRootDirectory() }
                }
            } else {
                Text(t("Choose one folder to browse from the notch."))
                    .foregroundStyle(.secondary)
                Button(t("Choose Folder")) { store.chooseRootDirectory() }
                    .disabled(!store.isEnabled)
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

    private func t(_ key: String) -> String {
        L10n.string(key, language: appLanguage)
    }
}
