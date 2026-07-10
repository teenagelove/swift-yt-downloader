import Foundation
import SwiftTelegramBot
import Logging

guard let botId = ProcessInfo.processInfo.environment[Constants.Environment.telegramBotToken], !botId.isEmpty else {
    print(Constants.Errors.tokenNotSet)
    exit(1)
}

var logger = Logger(label: "swift-yt-downloader")
logger.logLevel = .info

// Start health check server for Railway (reads PORT env var)
if let portStr = ProcessInfo.processInfo.environment["PORT"],
   let port = UInt16(portStr) {
    Task { await startHealthCheckServer(port: port) }
}

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
