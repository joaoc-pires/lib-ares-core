// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AresCore",
    products: [
        .library(
            name: "AresCore",
            targets: ["AresCore"]),
    ],
    dependencies: [
        .package(url: "https://github.com/nmdias/FeedKit.git", from: "9.1.2"),
        .package(url: "https://github.com/brightdigit/SyndiKit.git", from: "0.3.4"),
        .package(url: "https://github.com/joaoc-pires/opml.git", branch: "master"),
    ],
    targets: [
        .target(
            name: "AresCore"),
    ]
)
