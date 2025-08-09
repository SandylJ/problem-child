// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ProjectChimera",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "ProjectChimera",
            targets: ["ProjectChimera"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "ProjectChimera",
            dependencies: [],
            path: "ProjectChimera",
            resources: [
                .process("Assets.xcassets")
            ])
    ]
)
