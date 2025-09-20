//
//  Package.swift
//  lifehackiosapp
//
//  Created by Aleksander Blindheim on 19/09/2025.
//// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "LifehackBackendClient",
    platforms: [
        .iOS(.v17), .watchOS(.v10)
    ],
    products: [
        .library(name: "LifehackBackendClient", targets: ["LifehackBackendClient"])
    ],
    targets: [
        .target(name: "LifehackBackendClient", dependencies: []),
        .testTarget(name: "LifehackBackendClientTests", dependencies: ["LifehackBackendClient"])
    ]
)
