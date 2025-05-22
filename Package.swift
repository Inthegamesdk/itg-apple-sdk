// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Inthegametv",
    platforms: [
       .tvOS(.v14)
    ],
    products: [
        .library(name: "Inthegametv", targets: ["Inthegametv", "Storket"]),
        .library(name: "ITGPlayerViewController", targets: ["ITGPlayerViewController"]),
        .library(name: "ITGBitmovinPlayerAdapter", targets: ["ITGBitmovinPlayerAdapter"])
    ],
    targets: [
        .binaryTarget(name: "Inthegametv", path: "Sources/Inthegametv/Inthegametv.xcframework"),
        .binaryTarget(name: "Storket", path: "Sources/Storket/Storket.xcframework"),
        .target(name: "ITGPlayerViewController", path: "Sources/SupportingFiles/PlayerControllerAndAdapters/", sources: ["ITGAVPlayerAdapter.swift", "ITGPlayerAdapter.swift", "ITGPlayerViewController.swift"]),
        .target(name: "ITGBitmovinPlayerAdapter", dependencies: ["ITGPlayerViewController"], path: "Sources/SupportingFiles/PlayerControllerAndAdapters/", sources: ["ITGBitmovinPlayerAdapter.swift"])
    ]
)
