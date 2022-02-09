// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "AppIconResizer",
    products: [
      .executable(name: "icon-resizer-swift", targets: ["AppIconResizer"]),
    ],
    dependencies: [
        .package(
            url: "https://github.com/kylef/Commander.git",
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
  platforms: [.macOS(.v10_13)],
      from: "0.9.1"
)
