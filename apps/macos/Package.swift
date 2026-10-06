// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Mole",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "Mole", targets: ["Mole"])
    ],
    targets: [
        .executableTarget(
            name: "Mole",
            path: "Sources"
        )
    ]
)
