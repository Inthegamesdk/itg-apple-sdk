// swift-tools-version: 5.6
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
        .library(name: "ITGMediatailorPlugin", targets: ["ITGMediatailorPlugin"]),
        .library(name: "ITGDatazoomPlugin", targets: ["ITGDatazoomPlugin"]),
        .library(name: "ITGGoogleIMAPlugin", targets: ["ITGGoogleIMAPlugin"]),
        .library(name: "ITGMediastreamPlatformAdapter", targets: ["ITGMediastreamPlatformAdapter"])
    ],
    targets: [
        .binaryTarget(name: "Inthegametv", path: "Sources/Inthegametv.xcframework"),
        .binaryTarget(name: "InthegametviOS", path: "Sources/InthegametviOS.xcframework"),
        .binaryTarget(name: "Storket", path: "Sources/Storket.xcframework"),
        .binaryTarget(name: "ITGPlayerViewController", path: "Sources/Plugins/ItgPlayerViewController.xcframework"),
        .binaryTarget(name: "ITGBitmovinPlayerAdapter", path: "Sources/Plugins/ItgBitmovinPlayerAdapter.xcframework"),
        .binaryTarget(name: "ITGPlayerViewControllerSwiftUI", path: "Sources/Plugins/ItgPlayerViewControllerSwiftUI.xcframework"),
        .binaryTarget(name: "ITGOverlayViewSwiftUI", path: "Sources/Plugins/ItgOverlayViewSwiftUI.xcframework"),
        .binaryTarget(name: "ITGMediatailorPlugin", path: "Sources/Plugins/ItgMediatailorPlugin.xcframework"),
        .binaryTarget(name: "ITGDatazoomPlugin", path: "Sources/Plugins/ItgDatazoomPlugin.xcframework"),
        .binaryTarget(name: "ITGGoogleIMAPlugin", path: "Sources/Plugins/ItgGoogleIMAPlugin.xcframework"),
        .binaryTarget(name: "ITGMediastreamPlatformAdapter", path: "Sources/Plugins/ITGMediastreamPlatformAdapter.xcframework")
    ]
)
