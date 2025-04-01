// swift-tools-version: 5.7

import Foundation
import PackageDescription


let shouldInstallDepLocally: Bool = {
  let shouldInstallDepLocally =
    ProcessInfo.processInfo.environment["SHOULD_INSTALL_DEV_LIBRARIES_LOCALLY"];
    
  guard let shouldInstallDepLocally = shouldInstallDepLocally,
        shouldInstallDepLocally == "1"
  else {
    return false;
  };
  
  return true;
}();

/// `DGSwiftUtilities`
let swiftUtilitiesPackage: Package.Dependency = {
  let libPath =
    ProcessInfo.processInfo.environment["PATH_DEV_LIBRARY_SWIFT_UTILITIES"];
    
  guard let libPath = libPath,
        shouldInstallDepLocally
  else {
    return .package(
      url: "https://github.com/dominicstop/DGSwiftUtilities",
      from: "0.46.4"
    );
  };
  
  return .package(path: libPath);
}();

/// `ComputableLayout`
let computableLayoutPackage: Package.Dependency = {
  let libPath =
    ProcessInfo.processInfo.environment["PATH_DEV_LIBRARY_COMPUTABLE_LAYOUT"];
    
  guard let libPath = libPath,
        shouldInstallDepLocally
  else {
    return .package(
      url: "https://github.com/dominicstop/ComputableLayout",
      from: "0.7.0"
    );
  };
  
  return .package(path: libPath);
}();

/// `VisualEffectBlurView`
let visualEffectBlurViewPackage: Package.Dependency = {
  let libPath =
    ProcessInfo.processInfo.environment["PATH_DEV_LIBRARY_VISUAL_EFFECT_BLUR_VIEW"];
    
  guard let libPath = libPath,
        shouldInstallDepLocally
  else {
    return .package(
      url: "https://github.com/dominicstop/VisualEffectBlurView",
      from: "0.7.0"
    );
  };
  
  return .package(path: libPath);
}();

let package = Package(
  name: "AdaptiveModal",
  platforms: [
    .iOS(.v11),
  ],
  products: [
    .library(
      name: "AdaptiveModal",
      targets: ["AdaptiveModal"]
    ),
  ],
  dependencies: [
    swiftUtilitiesPackage,
    computableLayoutPackage,
    // visualEffectBlurViewPackage,
  ],
  targets: [
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
