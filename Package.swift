// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "ShadhinMusicSDK",
    platforms: [.iOS(.v13)],
    products: [
        .library(
            name: "ShadhinMusicSDK",
            targets: ["ShadhinMusicSDK"]
        )
    ],
    targets: [
        .binaryTarget(
            name: "ShadhinMusicSDK",
            url: "https://github.com/shadhin-music/MyGpShadhinMusicSPM/raw/main/Shadhin_GP.xcframework.zip",
            checksum: "f6f3edc7f5d7caec690d914b5cf6ebac1042931439c3bbbca60f0dd09e719d43"
        )
    ]
)
