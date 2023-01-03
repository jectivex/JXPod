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
    dependencies: [ .package(name: "swift-docc-plugin", url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0"), 
        .package(url: "https://github.com/jectivex/JXBridge.git", from: "0.1.14"),
        .package(url: "https://github.com/fair-ground/Fair.git", from: "0.8.26"),
    ],
    targets: [
        .target(
            name: "JXPod",
            dependencies: [
                .product(name: "JXBridge", package: "JXBridge"),
                .product(name: "FairCore", package: "Fair"),
            ],
            resources: [.process("Resources")]),
        .testTarget(
            name: "JXPodTests",
            dependencies: ["JXPod"],
            resources: [.copy("TestResources")]),
    ]
)
