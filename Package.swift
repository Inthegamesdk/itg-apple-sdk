// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Inthegametv",
    platforms: [
        .iOS(.v14), .tvOS(.v14)
    ],
    products: [
        .library(name: "Inthegametv", targets: ["Inthegametv", "Storket"]),
        .library(name: "InthegametviOS", targets: ["InthegametviOS", "Storket"]),
        .library(name: "ITGPlayerViewController", targets: ["ITGPlayerViewController"]),
    ],
    targets: [
        .binaryTarget(name: "Inthegametv", path: "Sources/Inthegametv/Inthegametv.xcframework"),
        .binaryTarget(name: "InthegametviOS", path: "Sources/InthegametviOS/InthegametviOS.xcframework"),
        .binaryTarget(name: "Storket", path: "Sources/Storket/Storket.xcframework"),
        .target(name: "ITGPlayerViewController", path: "Sources/SupportingFiles/PlayerControllerAndAdapters/", exclude: ["ITGKalturaPlayerAdapter.swift"]),
    ]
)
