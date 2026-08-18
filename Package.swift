// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "ExercisesPackage",
    platforms: [
        .iOS(.v16),
        .watchOS(.v9),
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "ExercisesPackage",
            targets: ["ExercisesPackage"]
        ),
    ],
    targets: [
        .target(
            name: "ExercisesPackage"
        ),
    ]
)
