import Foundation
import SwiftTelegramBot
import ServiceLifecycle
import Logging

struct BotService: Service {
    let botId: String

    func run() async throws {
        var logger = Logger(label: "BotService")
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

        // bot.start() launches long polling in a detached Task and returns.
        // Suspend this structured task until ServiceGroup cancels it on shutdown.
        await withCheckedContinuation { (_: CheckedContinuation<Void, Never>) in }
    }
}
