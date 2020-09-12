// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

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
            path: "./Aquaman/Aquaman")
    ]
)
