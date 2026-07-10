import Foundation
import SwiftTelegramBot
import Logging

// Debug: print all environment variables at startup
print("=== Environment Debug ===")
for (key, value) in ProcessInfo.processInfo.environment {
    if key == Constants.Environment.telegramBotToken {
        print("\(key): \(value.prefix(10))...")  // mask token
    } else {
        print("\(key): \(value)")
    }
}
print("========================")

guard let botId = ProcessInfo.processInfo.environment[Constants.Environment.telegramBotToken], !botId.isEmpty else {
    print(Constants.Errors.tokenNotSet)
    exit(1)
}

// Start health check server for Railway
if let portStr = ProcessInfo.processInfo.environment["PORT"], !portStr.isEmpty {
    startHealthCheckServer(port: UInt16(portStr) ?? 8080)
    print("Health check server starting on port \(portStr)")
} else {
    print("No PORT variable found, skipping health check server")
}

var logger = Logger(label: "swift-yt-downloader")
logger.logLevel = .info

let bot = try await TGBot(
    connectionType: .longpolling(),
    tgClient: TGClientDefault(),
    tgURI: TGBot.standardTGURL,
    botId: botId,
    log: logger
)

try await bot.add(dispatcher: YouTubeDispatcher(bot: bot, logger: logger))

print("Starting swift-yt-downloader bot...")
try await bot.start()
