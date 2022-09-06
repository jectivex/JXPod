// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "JackPot",
    products: [
        .library(
            name: "JackPot",
            targets: ["JackPot"]),
    ],
    dependencies: [
        .package(url: "https://github.com/jectivex/SwiftJack.git", branch: "HEAD"),
        .package(url: "https://github.com/jectivex/Judo.git", branch: "HEAD"),
    ],
    targets: [
        .target(
            name: "JackPot",
            dependencies: [
                .product(name: "SwiftJack", package: "SwiftJack"),
                .product(name: "Judo", package: "Judo"),
            ],
            resources: [.process("Resources")]),
        .testTarget(
            name: "JackPotTests",
            dependencies: ["JackPot"],
            resources: [.copy("TestResources")]),
    ]
)
