// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "ImagePlaceholder",
    platforms: [
        .macOS(.v10_11), .iOS(.v9), .tvOS(.v9), .watchOS(.v2)
    ],
    products: [
        .library(
            name: "ImagePlaceholder",
            targets: ["ImagePlaceholder"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "ImagePlaceholder",
            dependencies: []),
        .testTarget(
            name: "ImagePlaceholderTests",
            dependencies: ["ImagePlaceholder"]),
    ]
)
