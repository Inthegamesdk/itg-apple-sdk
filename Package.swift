// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Inthegametv",
    platforms: [
        .iOS(.v14), .tvOS(.v14)
    ],
    products: [
        .library(name: "Inthegametv", targets: ["Inthegametv", "StorketService"]),
        .library(name: "InthegametviOS", targets: ["InthegametviOS", "StorketService"]),
        .library(name: "ITGAVPlayerAdapter", targets: ["ITGAVPlayerAdapter"])
    ],
    targets: [
        .binaryTarget(name: "Inthegametv", path: "Sources/Inthegametv/Inthegametv.xcframework"),
        .binaryTarget(name: "InthegametviOS", path: "Sources/InthegametviOS/InthegametviOS.xcframework"),
        .binaryTarget(name: "StorketService", path: "Sources/StorketService/StorketService.xcframework"),
        .target(name: "ITGAVPlayerAdapter", path: "Sources/SupportingFiles/PlayerAdapters/ITGAVPlayerAdapter")
    ]
)
