// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "CapacitorWatchBridge",
    platforms: [
        .iOS(.v14),
        .watchOS(.v10),
    ],
    products: [
        .library(
            name: "CapacitorWatchBridge",
            targets: ["WatchBridgePlugin"]
        ),
        .library(
            name: "WatchBridgeKit",
            targets: ["WatchBridgeKit"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/ionic-team/capacitor-swift-pm.git", from: "7.0.0")
    ],
    targets: [
        // --- Dummy Cordova Stub ---
        .target(
            name: "CordovaStub",
            path: "ios/Sources/CordovaStub",
            publicHeadersPath: "."
        ),

        // --- iOS Plugin ---
        .target(
            name: "WatchBridgePlugin",
            dependencies: [
                "CordovaStub",
                .product(name: "Capacitor", package: "capacitor-swift-pm"),
            ],
            path: "ios/Sources/WatchBridgePlugin"
        ),

        // --- watchOS Helper ---
        .target(
            name: "WatchBridgeKit",
            dependencies: [],
            path: "watchos/Sources/WatchBridgeKit"
        ),

        .testTarget(
            name: "WatchBridgePluginTests",
            dependencies: ["WatchBridgePlugin"],
            path: "ios/Tests/WatchBridgePluginTests"
        ),
    ]
)
