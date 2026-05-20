// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "AhlaiOS",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "AhlaAuthKit", targets: ["AhlaAuthKit"]),
        .library(name: "AhlaChatKit", targets: ["AhlaChatKit"]),
        .library(name: "AhlaDriveKit", targets: ["AhlaDriveKit"]),
        .library(name: "AhlaMeetKit", targets: ["AhlaMeetKit"]),
        .library(name: "AhlaNotificationsKit", targets: ["AhlaNotificationsKit"]),
        .library(name: "AhlaTelemetryKit", targets: ["AhlaTelemetryKit"]),
    ],
    targets: [
        .target(name: "AhlaAuthKit", path: "Sources/AhlaAuthKit"),
        .target(name: "AhlaChatKit", path: "Sources/AhlaChatKit"),
        .target(name: "AhlaDriveKit", path: "Sources/AhlaDriveKit"),
        .target(name: "AhlaMeetKit", path: "Sources/AhlaMeetKit"),
        .target(name: "AhlaNotificationsKit", path: "Sources/AhlaNotificationsKit"),
        .target(name: "AhlaTelemetryKit", path: "Sources/AhlaTelemetryKit"),
    ]
)
