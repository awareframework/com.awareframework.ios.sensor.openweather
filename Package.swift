// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "com.awareframework.ios.sensor.openweather",
    platforms: [.iOS(.v13)],
    products: [
        .library(
            name: "com.awareframework.ios.sensor.openweather",
            targets: [
                "com.awareframework.ios.sensor.openweather"
            ]
        ),
    ],
    dependencies: [
        .package(url: "git@github.com:awareframework/com.awareframework.ios.sensor.core.git", from: "0.7.7"),
        .package(url: "git@github.com:awareframework/com.awareframework.ios.sensor.locations.git", from: "0.7.2")
    ],
    targets: [
        .target(
            name: "com.awareframework.ios.sensor.openweather",
            dependencies: [
                .product(name: "com.awareframework.ios.sensor.core", package: "com.awareframework.ios.sensor.core", condition: .when(platforms: [.iOS])),
                .product(name: "com.awareframework.ios.sensor.locations", package: "com.awareframework.ios.sensor.locations", condition: .when(platforms: [.iOS]))
            ],
            path: "com.awareframework.ios.sensor.openweather/Classes"
        )
    ],
    swiftLanguageModes: [.v5]
)
