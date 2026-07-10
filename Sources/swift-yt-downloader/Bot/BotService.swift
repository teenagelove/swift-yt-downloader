import Foundation
import SwiftTelegramBot
import ServiceLifecycle
import Logging

struct BotService: Service {
    let botId: String

    func run() async throws {
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

        // Service.run() must not return — this keeps the process alive
        // until ServiceGroup receives a shutdown signal
        try await withCheckedThrowingContinuation { (_: CheckedContinuation<Void, any Error>) in }
    }
}
