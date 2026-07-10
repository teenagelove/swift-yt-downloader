import Foundation
import SwiftTelegramBot
import Logging

class YouTubeDispatcher: TGDefaultDispatcher, @unchecked Sendable {
    private let logger: Logger

    override init(bot: TGBot, logger: Logger) {
        self.logger = logger
        super.init(bot: bot, logger: logger)
    }

    override func handle() async {
        await add(TGCommandHandler(commands: [Constants.Bot.start, Constants.Bot.help]) { [weak self] update in
            guard let bot = self?.bot,
                  let logger = self?.logger,
                  let user = update.message?.from,
                  let chatId = update.message?.chat.id
            else { return }

            let command = update.message?.text ?? "unknown"
            logger.info("[Command] \(command) from user \(user.id) (\(user.firstName) \(user.lastName ?? "")) in chat \(chatId)")

            let params = TGSendMessageParams(
                chatId: .chat(chatId),
                text: Constants.Messages.help
            )
            try await bot.sendMessage(params: params)
        })

        await add(TGMessageHandler({ [weak self] update in
            guard let bot = self?.bot,
                  let logger = self?.logger,
                  let text = update.message?.text,
                  let chatId = update.message?.chat.id,
                  let user = update.message?.from,
                  !text.hasPrefix("/")
            else { return }

            logger.info("[Message] \"\(text)\" from user \(user.id) (\(user.firstName) \(user.lastName ?? "")) in chat \(chatId)")

            guard YouTubeDownloader.isYouTubeURL(text) else {
                logger.info("[Message] Not a YouTube URL, sending notALink")
                let params = TGSendMessageParams(chatId: .chat(chatId), text: Constants.Messages.notALink)
                try await bot.sendMessage(params: params)
                return
            }

            logger.info("[YouTube] Starting download for: \(text)")
            let waitParams = TGSendMessageParams(chatId: .chat(chatId), text: Constants.Messages.wait)
            try await bot.sendMessage(params: waitParams)

            do {
                let (title, audioData) = try await YouTubeDownloader.downloadAudio(url: text, logger: logger)
                logger.info("[YouTube] Downloaded: \"\(title)\" (\(audioData.count) bytes)")

                let inputFile = TGInputFile(filename: title, data: audioData)
                let params = TGSendAudioParams(
                    chatId: .chat(chatId),
                    audio: .file(inputFile)
                )
                try await bot.sendAudio(params: params)
                logger.info("[YouTube] Audio sent to chat \(chatId)")
            } catch {
                logger.error("[YouTube] Download failed: \(error)")
                let params = TGSendMessageParams(chatId: .chat(chatId), text: Constants.Messages.oops)
                try await bot.sendMessage(params: params)
            }
        }))
    }
}
