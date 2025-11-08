// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "CapacitorWatchBridge",
    platforms: [.iOS(.v14)],
    products: [
        .library(
            name: "CapacitorWatchBridge",
            targets: ["WatchBridgePlugin"])
    ],
    dependencies: [
        .package(url: "https://github.com/ionic-team/capacitor-swift-pm.git", from: "7.0.0")
    ],
    targets: [
        .target(
            name: "WatchBridgePlugin",
            dependencies: [
                .product(name: "Capacitor", package: "capacitor-swift-pm"),
                .product(name: "Cordova", package: "capacitor-swift-pm"),
            ],
            path: "ios/Sources/WatchBridgePlugin"),
        .testTarget(
            name: "WatchBridgePluginTests",
            dependencies: ["WatchBridgePlugin"],
            path: "ios/Tests/WatchBridgePluginTests"),
    ]
)
