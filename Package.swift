//
//  Package.swift
//  
//
//  Created by Shadhin Music on 26/4/26.
//

// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "MyGpShadhinMusicSPM",
    platforms: [
        .iOS(.v12)
    ],
    products: [
        .library(
            name: "ShadhinGP",
            targets: ["ShadhinGP"]
        ),
    ],
    targets: [
        .binaryTarget(
            name: "ShadhinGP",
            path: "Sources/ShadhinGP/Shadhin_Gp.xcframework"
        )
    ]
)
