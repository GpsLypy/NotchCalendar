// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "NotchCalendar",
    platforms: [.macOS(.v15)],
    products: [.executable(name: "NotchCalendar", targets: ["NotchCalendar"])],
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
        .testTarget(
            name: "NotchCalendarTests",
            dependencies: ["NotchCalendar"]
        )
    ]
)
