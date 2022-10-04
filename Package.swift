// swift-tools-version:5.6
import PackageDescription

let package = Package(
    name: "JackPot",
    platforms: [ .macOS(.v12), .iOS(.v15), .tvOS(.v15) ],
    products: [
        .library(
            name: "JackPot",
            targets: ["JackPot"]),
    ],
    dependencies: [
        .package(url: "https://github.com/jectivex/Jack.git", from: "2.0.0"),
        .package(url: "https://github.com/jectivex/SQLPod.git", from: "0.0.1"),
        //.package(url: "https://github.com/jectivex/ConsolePod.git", from: "0.0.1"),
        //.package(url: "https://github.com/jectivex/UIPod.git", from: "0.0.1"),
        //.package(url: "https://github.com/jectivex/FilePod.git", from: "0.0.1"),
        //.package(url: "https://github.com/jectivex/NetPod.git", from: "0.0.1"),
        //.package(url: "https://github.com/jectivex/GeoPod.git", from: "0.0.1"),
        //.package(url: "https://github.com/jectivex/ThemePod.git", from: "0.0.1"),
        //.package(url: "https://github.com/jectivex/TimePod.git", from: "0.0.1"),
        //.package(url: "https://github.com/jectivex/CanvasPod.git", from: "0.0.1"),
        //.package(url: "https://github.com/jectivex/ChartPod.git", from: "0.0.1"),
    ],
    targets: [
        .target(
            name: "JackPot",
            dependencies: [
                .product(name: "Jack", package: "Jack"),
                .product(name: "SQLPod", package: "SQLPod"),
            ],
            resources: [.process("Resources")]),
        .testTarget(
            name: "JackPotTests",
            dependencies: ["JackPot"],
            resources: [.copy("TestResources")]),
    ]
)


