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
    ],
    targets: [
        .target(
            name: "JackPot",
            dependencies: [
                .product(name: "Jack", package: "Jack"),
            ],
            resources: [.process("Resources")]),
        .testTarget(
            name: "JackPotTests",
            dependencies: ["JackPot"],
            resources: [.copy("TestResources")]),
    ]
)