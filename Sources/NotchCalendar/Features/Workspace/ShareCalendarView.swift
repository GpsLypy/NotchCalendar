import AppKit
import SwiftUI
import UniformTypeIdentifiers

struct ShareCalendarView: View {
    @Environment(\.appLanguage) private var appLanguage
    @Environment(\.dismiss) private var dismiss
    @State private var feedback: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(t("Share Notch Calendar")).font(.title3.bold())
                    Text(t("A little space. A clearer day."))
                        .font(.callout).foregroundStyle(.secondary)
                }
                Spacer()
                Button(t("Done")) { dismiss() }
                    .keyboardShortcut(.cancelAction)
            }

            ShareCalendarPoster(language: appLanguage)
                .clipShape(RoundedRectangle(cornerRadius: 16))

            HStack(spacing: 10) {
                Button { copyImage() } label: {
                    Label(t("Copy Image"), systemImage: "doc.on.doc")
                }
                .buttonStyle(.borderedProminent)
                Button { saveImage() } label: {
                    Label(t("Save Image…"), systemImage: "square.and.arrow.down")
                }
                Spacer()
                if let url = UpdateConfiguration.githubURL {
                    Button(t("Copy Link")) {
                        NSPasteboard.general.clearContents()
                        feedback = NSPasteboard.general.setString(url.absoluteString, forType: .string)
                            ? "Link copied" : "Could not copy. Try again."
                    }
                }
            }
            Text(feedback.map(t) ?? t("Share the image with friends to introduce Notch Calendar."))
                .font(.caption).foregroundStyle(.secondary)
        }
        .padding(24)
        .background(WorkspacePalette.canvas)
        .preferredColorScheme(.dark)
    }

    @MainActor private func copyImage() {
        guard let image = ShareCalendarPoster.render(language: appLanguage) else {
            feedback = "Could not create the image. Try again."
            return
        }
        NSPasteboard.general.clearContents()
        feedback = NSPasteboard.general.writeObjects([image])
            ? "Image copied" : "Could not copy. Try again."
    }

    @MainActor private func saveImage() {
        guard let image = ShareCalendarPoster.render(language: appLanguage),
              let tiff = image.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiff),
              let data = bitmap.representation(using: .png, properties: [:]) else {
            feedback = "Could not create the image. Try again."
            return
        }
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.png]
        panel.nameFieldStringValue = "NotchCalendar.png"
        guard panel.runModal() == .OK, let url = panel.url else { return }
        do {
            try data.write(to: url, options: .atomic)
            feedback = "Image saved"
        } catch {
            feedback = "Could not save the image. Choose another location."
        }
    }

    private func t(_ key: String) -> String { L10n.string(key, language: appLanguage) }
}

/// A self-contained illustration: sharing never includes personal calendar data.
struct ShareCalendarPoster: View {
    let language: AppLanguage
    private let blue = Color(red: 0.40, green: 0.66, blue: 1)
    private let ink = Color(red: 0.06, green: 0.09, blue: 0.16)

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 7) {
                Image(systemName: "calendar")
                Text(t("Notch Calendar")).fontWeight(.semibold)
                Spacer()
                Text("macOS").font(.system(size: 11, weight: .medium, design: .monospaced))
            }
            .font(.system(size: 13)).foregroundStyle(.white.opacity(0.8))
            .padding(.horizontal, 30).padding(.top, 24)

            Text(t("Your day, right at the notch."))
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundStyle(.white).padding(.top, 22)
            Text(t("Calendar · Meetings · Focus"))
                .font(.system(size: 13)).foregroundStyle(blue).padding(.top, 8)

            screen.padding(.horizontal, 38).padding(.top, 24)

            HStack {
                Text(t("A little space. A clearer day."))
                Spacer()
                Text(UpdateConfiguration.githubRepository ?? "Notch Calendar")
                    .font(.system(size: 10, design: .monospaced))
            }
            .font(.system(size: 11)).foregroundStyle(.white.opacity(0.65))
            .padding(.horizontal, 30).padding(.vertical, 20)
        }
        .frame(width: 600, height: 440)
        .background(LinearGradient(colors: [ink, Color(red: 0.12, green: 0.22, blue: 0.36)], startPoint: .topLeading, endPoint: .bottomTrailing))
    }

    private var screen: some View {
        ZStack(alignment: .top) {
            RoundedRectangle(cornerRadius: 14)
                .fill(LinearGradient(colors: [blue.opacity(0.55), ink], startPoint: .topLeading, endPoint: .bottomTrailing))
            VStack(spacing: 0) {
                HStack {
                    Text("9:41")
                    Spacer()
                    Image(systemName: "wifi")
                    Image(systemName: "battery.100percent")
                }
                .font(.system(size: 9, weight: .medium)).padding(.horizontal, 15).frame(height: 24)
                Spacer()
            }
            VStack(spacing: 0) {
                HStack {
                    Text("09:41").foregroundStyle(blue)
                    Spacer()
                    Circle().fill(.gray.opacity(0.35)).frame(width: 5, height: 5)
                }
                .font(.system(size: 10, weight: .medium, design: .monospaced))
                .padding(.horizontal, 16).frame(width: 150, height: 24)
                .background(.black, in: UnevenRoundedRectangle(bottomLeadingRadius: 9, bottomTrailingRadius: 9))

                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text(t("Today")).font(.system(size: 14, weight: .semibold))
                        Spacer()
                        Image(systemName: "calendar").foregroundStyle(blue)
                    }
                    HStack(spacing: 12) {
                        ForEach(12..<19) { day in
                            Text("\(day)")
                                .font(.system(size: 11, weight: .medium, design: .rounded))
                                .frame(width: 25, height: 25)
                                .background(day == 15 ? blue : .clear, in: Circle())
                                .foregroundStyle(day == 15 ? ink : .white.opacity(0.7))
                        }
                    }
                    Divider().overlay(.white.opacity(0.12))
                    HStack(spacing: 10) {
                        RoundedRectangle(cornerRadius: 2).fill(blue).frame(width: 3, height: 28)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(t("Make time for what matters")).font(.system(size: 11, weight: .medium))
                            Text("10:00 – 10:30").font(.system(size: 9, design: .monospaced)).foregroundStyle(.gray)
                        }
                        Spacer()
                        Image(systemName: "video.fill").foregroundStyle(blue)
                    }
                }
                .padding(16).frame(width: 292)
                .background(.black, in: UnevenRoundedRectangle(bottomLeadingRadius: 20, bottomTrailingRadius: 20))
            }
        }
        .foregroundStyle(.white)
        .frame(height: 222)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(.white.opacity(0.18), lineWidth: 1))
    }

    @MainActor static func render(language: AppLanguage) -> NSImage? {
        let renderer = ImageRenderer(content: ShareCalendarPoster(language: language).environment(\.colorScheme, .dark))
        renderer.scale = 2
        return renderer.nsImage
    }

    private func t(_ key: String) -> String { L10n.string(key, language: language) }
}
