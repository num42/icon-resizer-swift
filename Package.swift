// swift-tools-version:5.0

import PackageDescription

let package = Package(
  name: "AppIconResizer",
  platforms: [.macOS(.v10_13)],
  products: [
    .executable(name: "icon-resizer-swift", targets: ["AppIconResizer"])
  ],
  dependencies: [
    .package(
      url: "https://github.com/kylef/Commander.git",
      from: "0.9.1"
    )
  ],
  targets: [
    .target(
      name: "AppIconResizerCore",
      dependencies: ["Commander"]
    ),
    .target(
      name: "AppIconResizer",
      dependencies: ["AppIconResizerCore"]
    ),
    .testTarget(
      name: "AppIconResizerTests",
      dependencies: ["AppIconResizer", "Commander"]
    )
  ]
)
