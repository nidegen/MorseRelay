// swift-tools-version: 6.0

import PackageDescription

let package = Package(
  name: "Morse Relay",
  platforms: [.iOS(.v18)],
  products: [
    .library(
      name: "App",
      targets: ["App"]
    )
  ],
  dependencies: [
    .package(
      url: "https://github.com/yeatse/opencv-spm",
      exact: "4.10.0+4"
    )
  ],
  targets: [
    .target(
      name: "App",
      dependencies: [
        "CameraKit",
        "MorseVision",
      ]
    ),
    .target(name: "CameraKit"),
    .target(
      name: "MorseVision",
      dependencies: [
        .product(name: "OpenCV", package: "opencv-spm")
      ],
      cxxSettings: [
        .unsafeFlags(["-std=c++20"])
      ],
      linkerSettings: [
        .linkedFramework("AVFoundation"),
        .linkedFramework("CoreImage"),
        .linkedFramework("CoreMedia"),
        .linkedFramework("CoreVideo", .when(platforms: [.iOS, .visionOS])),
        .linkedFramework("Accelerate", .when(platforms: [.iOS, .macOS, .visionOS])),
        .linkedFramework("OpenCL", .when(platforms: [.macOS])),
        .linkedLibrary("c++"),
      ]
    ),
    .testTarget(
      name: "AppTests",
      dependencies: ["App"]
    ),
  ],
  cxxLanguageStandard: .cxx20
)
