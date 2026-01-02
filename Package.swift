// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Inthegametv",
    platforms: [
       .tvOS(.v12),
       .iOS(.v12)
    ],
    products: [
        .library(name: "InthegametviOS", targets: ["InthegametviOS", "Storket"]),
        .library(name: "Inthegametv", targets: ["Inthegametv", "Storket"]),
        .library(name: "ITGPlayerViewController", targets: ["ITGPlayerViewController"]),
        .library(name: "ITGBitmovinPlayerAdapter", targets: ["ITGBitmovinPlayerAdapter"]),
        .library(name: "ITGPlayerViewControllerSwiftUI", targets: ["ITGPlayerViewControllerSwiftUI"]),
        .library(name: "ITGOverlayViewSwiftUI", targets: ["ITGOverlayViewSwiftUI"]),
        .library(name: "ITGMediatailorPlugin", targets: ["ITGMediatailorPlugin"])
    ],
    targets: [
        .binaryTarget(name: "Inthegametv", path: "Sources/Inthegametv/Inthegametv.xcframework"),
        .binaryTarget(name: "InthegametviOS", path: "Sources/InthegametviOS/InthegametviOS.xcframework"),
        .binaryTarget(name: "Storket", path: "Sources/Storket/Storket.xcframework"),
        .target(name: "ITGPlayerViewController", path: "Sources/SupportingFiles/", sources: ["ITGAVPlayerAdapter.swift", "ITGPlayerAdapter.swift", "ITGPlayerViewController.swift"]),
        .target(name: "ITGBitmovinPlayerAdapter", dependencies: ["ITGPlayerViewController"], path: "Sources/SupportingFiles/", sources: ["ITGBitmovinPlayerAdapter.swift"]),
        .target(name: "ITGPlayerViewControllerSwiftUI", dependencies: ["ITGPlayerViewController"], path: "Sources/SupportingFiles/", sources: ["ITGPlayerViewControllerSwiftUI.swift"]),
        .target(name: "ITGOverlayViewSwiftUI", path: "Sources/SupportingFiles/", sources: ["ITGOverlayViewSwiftUI.swift"]),
        .target(name: "ITGMediatailorPlugin", path: "Sources/SupportingFiles/", sources: ["ITGMediatailorPlugin.swift"])
    ]
)
