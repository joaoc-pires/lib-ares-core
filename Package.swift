// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AresCore",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "AresCore",
            targets: ["AresCore"]),
    ],
    dependencies: [
        .package(url: "https://github.com/nmdias/FeedKit.git", from: "9.1.2"),
        .package(url: "https://github.com/brightdigit/SyndiKit.git", from: "0.3.4"),
        .package(url: "https://github.com/joaoc-pires/SimpleNetwork", from: "1.0.0"),
        .package(url: "https://github.com/scinfu/SwiftSoup", from: "2.6.1"),
        
    ],
    targets: [
        .target(name: "AresCore",
                dependencies: [
                    .product(name: "FeedKit",       package: "FeedKit"),
                    .product(name: "SyndiKit",      package: "SyndiKit"),
                    .product(name: "SimpleNetwork", package: "SimpleNetwork"),
                    .product(name: "SwiftSoup",     package: "SwiftSoup"),
                ])
    ]
)
