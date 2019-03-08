// swift-tools-version:4.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AppIconResizer",
    products: [
      .executable(name: "icon-resizer", targets: ["AppIconResizer"]),
    ],
    dependencies: [
        .package(
            url: "https://github.com/kylef/Commander.git",
            from: "0.8.0"
        ),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "AppIconResizer",
            dependencies: ["AppIconResizerCore"]),
        .target(name: "AppIconResizerCore",
        dependencies: ["Commander"]),
        .testTarget(
            name: "AppIconResizerTests",
            dependencies: ["AppIconResizer", "Commander"]),
    ]
)
