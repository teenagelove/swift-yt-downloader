import Foundation
import SwiftTelegramBot
import Logging

class YouTubeDispatcher: TGDefaultDispatcher, @unchecked Sendable {

    override init(bot: TGBot, logger: Logger) {
        super.init(bot: bot, logger: logger)
    }

    override func handle() async {
        await add(TGCommandHandler(commands: [Constants.Bot.start, Constants.Bot.help]) { [weak self] update in
            guard let bot = self?.bot else { return }
            let params = TGSendMessageParams(
                chatId: .chat(update.message?.chat.id ?? 0),
                text: Constants.Messages.help
            )
            try await bot.sendMessage(params: params)
        })

        await add(TGBaseHandler({ [weak self] update in
            guard let bot = self?.bot,
                  let text = update.message?.text,
                  let chatId = update.message?.chat.id else { return }

            guard YouTubeDownloader.isYouTubeURL(text) else {
                let params = TGSendMessageParams(chatId: .chat(chatId), text: Constants.Messages.notALink)
                try await bot.sendMessage(params: params)
                return
            }

            let waitParams = TGSendMessageParams(chatId: .chat(chatId), text: Constants.Messages.wait)
            try await bot.sendMessage(params: waitParams)

            do {
                let (title, audioData) = try await YouTubeDownloader.downloadAudio(url: text)
                let inputFile = TGInputFile(filename: "\(title).\(Constants.YouTube.audioExtension)", data: audioData)
                let params = TGSendAudioParams(
                    chatId: .chat(chatId),
                    audio: .file(inputFile)
                )
                try await bot.sendAudio(params: params)
            } catch {
                print("Error downloading audio: \(error)")
                let params = TGSendMessageParams(chatId: .chat(chatId), text: Constants.Messages.oops)
                try await bot.sendMessage(params: params)
            }
        }))
    }
}
