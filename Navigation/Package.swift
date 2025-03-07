// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "Navigation",
    platforms: [.iOS(.v16)],
    products: [
        .library(
            name: "Navigation",
            targets: ["Navigation"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Navigation",
            dependencies: [],
            path: ".",
            exclude: ["Package.swift"])
    ]
) 