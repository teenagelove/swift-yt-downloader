// swift-tools-version: 6.1

import PackageDescription

let package = Package(
    name: "swift-yt-downloader",
    platforms: [
        .macOS(.v13)
    ],
    dependencies: [
        .package(url: "https://github.com/nerzh/swift-telegram-bot.git", from: "4.0.0"),
        .package(url: "https://github.com/swiftlang/swift-subprocess.git", "0.4.0"..<"0.5.0")
    ],
    targets: [
        .executableTarget(
            name: "swift-yt-downloader",
            dependencies: [
                .product(name: "SwiftTelegramBot", package: "swift-telegram-bot"),
                .product(name: "Subprocess", package: "swift-subprocess")
            ]
        )
    ]
)
