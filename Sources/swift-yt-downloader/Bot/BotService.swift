import Foundation
import SwiftTelegramBot
import ServiceLifecycle
import Logging

struct BotService: Service {
    let botId: String

    func run() async throws {
        var logger = Logger(label: "BotService")
        logger.logLevel = .info
        logger[metadataKey: "service"] = "bot"

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

        await withTaskCancellationHandler {
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(3600))
            }
        } onCancel: {
            Task {
                try? await bot.stop()
            }
        }
    }
}
