// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "AdaptiveModal",
  platforms: [
    .iOS(.v11),
  ],
  products: [
    // Products define the executables and libraries a package produces, and make them visible to other packages.
    .library(
      name: "AdaptiveModal",
      targets: ["AdaptiveModal"]
    ),
  ],
  dependencies: [
    .package(
      url: "https://github.com/dominicstop/ComputableLayout",
      .upToNextMajor(from: "0.7.0")
    ),
    .package(
      url: "https://github.com/dominicstop/DGSwiftUtilities",
      .upToNextMajor(from: "0.11.0")
    ),
  ],
  targets: [
    // Targets are the basic building blocks of a package. A target can define a module or a test suite.
    // Targets can depend on other targets in this package, and on products in packages this package depends on.
    .target(
      name: "AdaptiveModal",
      dependencies: [
        "ComputableLayout",
        "DGSwiftUtilities",
      ],
      path: "Sources",
      linkerSettings: [
				.linkedFramework("UIKit"),
			]
    ),
  ]
)
