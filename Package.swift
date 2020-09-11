// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "Aquaman",
    platforms: [.iOS(.v9)],
    products: [
        .library(
            name: "Aquaman",
            targets: ["Aquaman"]),
    ],
    targets: [
        .target(
            name: "Aquaman",
            dependencies: [], path: "Aquaman/Aquaman")
    ]
)
