import Foundation
import ServiceLifecycle
import Logging

@main
struct App {
    static func main() async throws {
        guard let botId = ProcessInfo.processInfo.environment[Constants.Environment.telegramBotToken], !botId.isEmpty else {
            print(Constants.Errors.tokenNotSet)
            exit(1)
        }

        let botService = BotService(botId: botId)

        let serviceGroup = ServiceGroup(
            services: [botService],
            gracefulShutdownSignals: [.sigterm, .sigint],
            logger: Logger(label: "Application")
        )

        try await serviceGroup.run()
    }
}
