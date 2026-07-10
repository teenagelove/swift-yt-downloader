import Foundation
import SwiftTelegramBot
import Logging

guard let botId = ProcessInfo.processInfo.environment[Constants.Environment.telegramBotToken], !botId.isEmpty else {
    print(Constants.Errors.tokenNotSet)
    exit(1)
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

// long polling runs in a detached Task, keep the process alive
try await withCheckedThrowingContinuation { (_: CheckedContinuation<Void, any Error>) in }
