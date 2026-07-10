import Foundation
import ServiceLifecycle
import Logging

@main
struct App {
    static func main() async throws {
        LoggingSystem.bootstrap { label in
            var handler = StreamLogHandler.standardOutput(label: label)
            handler.logLevel = .info
            return handler
        }

        guard let botId = ProcessInfo.processInfo.environment[Constants.Environment.telegramBotToken], !botId.isEmpty else {
            print(Constants.Errors.tokenNotSet)
            exit(1)
        }

        let serviceGroup = ServiceGroup(
            services: [BotService(botId: botId)],
            gracefulShutdownSignals: [.sigterm, .sigint],
            logger: Logger(label: "swift-yt-downloader")
        )

        try await serviceGroup.run()
    }
}
