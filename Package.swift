// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "NotchCalendar",
    defaultLocalization: "en",
    platforms: [.macOS(.v15)],
    products: [
        .executable(name: "NotchCalendar", targets: ["NotchCalendar"]),
        .executable(name: "NotchCalendarUpdater", targets: ["NotchCalendarUpdater"]),
        .executable(name: "NotchCalendarWidgets", targets: ["NotchCalendarWidgets"])
    ],
    targets: [
        .executableTarget(
            name: "NotchCalendar",
            dependencies: ["NotchCalendarShared"],
            resources: [
                .process("Resources")
            ],
            linkerSettings: [
                .unsafeFlags([
                    "-Xlinker", "-sectcreate",
                    "-Xlinker", "__TEXT",
                    "-Xlinker", "__info_plist",
                    "-Xlinker", "Support/Info.plist"
                ])
            ]
        ),
        .executableTarget(
            name: "NotchCalendarUpdater"
        ),
        .target(
            name: "NotchCalendarShared"
        ),
        .executableTarget(
            name: "NotchCalendarWidgets",
            dependencies: ["NotchCalendarShared"],
            swiftSettings: [
                .unsafeFlags(["-application-extension"])
            ],
            linkerSettings: [
                .unsafeFlags([
                    "-Xlinker", "-e",
                    "-Xlinker", "_NSExtensionMain",
                    "-Xlinker", "-u",
                    "-Xlinker", "_main"
                ])
            ]
        ),
        .testTarget(
            name: "NotchCalendarTests",
            dependencies: ["NotchCalendar", "NotchCalendarShared"]
        )
    ]
)
