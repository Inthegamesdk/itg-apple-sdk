// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Inthegametv",
    platforms: [
       .tvOS(.v15),
       .iOS(.v15)
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
        .library(name: "ITGGoogleIMAPlugin", targets: ["ITGGoogleIMAPlugin"])
    ], dependencies: [
        .package(
            url: "https://gitlab.com/datazoom/apple/libraries-release/apple_dz_mediatailor_adapter",
            from: "1.9.1"
        )
    ],
    targets: [
        .binaryTarget(name: "Inthegametv", path: "Sources/Inthegametv.xcframework"),
        .binaryTarget(name: "InthegametviOS", path: "Sources/InthegametviOS.xcframework"),
        .binaryTarget(name: "Storket", path: "Sources/Storket.xcframework"),
        .target(name: "ITGPlayerViewController", path: "Sources/SupportingFiles/", sources: ["ITGAVPlayerAdapter.swift", "ITGPlayerAdapter.swift", "ITGPlayerViewController.swift"]),
        .target(name: "ITGBitmovinPlayerAdapter", dependencies: ["ITGPlayerViewController"], path: "Sources/SupportingFiles/", sources: ["ITGBitmovinPlayerAdapter.swift"]),
        .target(name: "ITGPlayerViewControllerSwiftUI", dependencies: ["ITGPlayerViewController"], path: "Sources/SupportingFiles/", sources: ["ITGPlayerViewControllerSwiftUI.swift"]),
        .target(name: "ITGOverlayViewSwiftUI", path: "Sources/SupportingFiles/", sources: ["ITGOverlayViewSwiftUI.swift"]),
        .target(name: "ITGMediatailorPlugin", path: "Sources/SupportingFiles/", sources: ["ITGMediatailorPlugin.swift"]),
        .target(name: "ITGDatazoomPlugin", dependencies: [
            .target(name: "Storket"),
            .target(name: "Inthegametv", condition: .when(platforms: [.tvOS])),
            .target(name: "InthegametviOS", condition: .when(platforms: [.iOS])),
            .product(name: "DzMediaTailorAdapter", package: "apple_dz_mediatailor_adapter")
        ], path: "Sources/SupportingFiles/", sources: ["ITGDatazoomPlugin.swift"]),
        .target(name: "ITGGoogleIMAPlugin", path: "Sources/SupportingFiles/", sources: ["ITGGoogleIMAPlugin.swift"])
    ]
)
