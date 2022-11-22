// swift-tools-version:5.6
import PackageDescription

let package = Package(
    name: "JXPod",
    platforms: [ .macOS(.v12), .iOS(.v15), .tvOS(.v15) ],
    products: [
        .library(
            name: "JXPod",
            targets: ["JXPod"]),
    ],
    dependencies: [
        .package(url: "https://github.com/jectivex/JXBridge.git", from: "0.1.0"),
        .package(url: "https://github.com/jectivex/Jack.git", from: "2.3.0"),
    ],
    targets: [
        .target(
            name: "JXPod",
            dependencies: [
                .product(name: "JXBridge", package: "JXBridge"),
                .product(name: "Jack", package: "Jack"),
            ],
            resources: [.process("Resources")]),
        .testTarget(
            name: "JXPodTests",
            dependencies: ["JXPod"],
            resources: [.copy("TestResources")]),
    ]
)


