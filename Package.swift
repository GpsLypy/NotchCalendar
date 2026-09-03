// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "NotchCalendar",
    platforms: [.macOS(.v15)],
    products: [
        .executable(name: "NotchCalendar", targets: ["NotchCalendar"]),
        .executable(name: "NotchCalendarUpdater", targets: ["NotchCalendarUpdater"])
    ],
    targets: [
        .executableTarget(
            name: "NotchCalendar",
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
        .testTarget(
            name: "NotchCalendarTests",
            dependencies: ["NotchCalendar"]
        )
    ]
)
