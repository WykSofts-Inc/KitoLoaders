// swift-tools-version: 5.9
//
//  Package.swift
//  KitoLoaders
//
//  Created by Wycliff on 2/10/26.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//


import PackageDescription

let package = Package(
    name: "KitoLoaders",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "KitoLoaders", targets: ["KitoLoaders"]),
    ],
    dependencies: [
        .package(url: "https://github.com/WykSofts-Inc/KitoCore.git", from: "1.1.0"),
    ],
    targets: [
        .target(
            name: "KitoLoaders",
            dependencies: [
                .product(name: "KitoCore", package: "KitoCore"),
            ]
        ),
        .testTarget(name: "KitoLoadersTests", dependencies: ["KitoLoaders"]),
    ]
)
