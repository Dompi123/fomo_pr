// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "FOMO_PR",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "FOMO_PR",
            targets: ["FOMO_PR"]),
        .library(
            name: "Models",
            targets: ["Models"]),
        .library(
            name: "Network",
            targets: ["Network"]),
        .library(
            name: "Core",
            targets: ["Core"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Models",
            dependencies: [],
            path: "Models/Sources/Models"),
        .target(
            name: "Network",
            dependencies: ["Models"],
            path: "Network/Sources/Network"),
        .target(
            name: "Core",
            dependencies: ["Models", "Network"],
            path: "Core/Sources/Core"),
        .target(
            name: "FOMO_PR",
            dependencies: ["Models", "Network", "Core"],
            path: "FOMO_PR")
    ]
)
