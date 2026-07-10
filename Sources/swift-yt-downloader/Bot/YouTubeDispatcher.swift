import Foundation
import SwiftTelegramBot
import Logging

class YouTubeDispatcher: TGDefaultDispatcher, @unchecked Sendable {

    override init(bot: TGBot, logger: Logger) {
        super.init(bot: bot, logger: logger)
    }

    override func handle() async {
        await add(TGCommandHandler(commands: [Constants.Bot.start, Constants.Bot.help]) { [weak self] update in
            guard let bot = self?.bot,
                  let user = update.message?.from,
                  let chatId = update.message?.chat.id else { return }

            let command = update.message?.text ?? "unknown"
            print("[Command] \(command) from user \(user.id) (\(user.firstName) \(user.lastName ?? "")) in chat \(chatId)")

            let params = TGSendMessageParams(
                chatId: .chat(chatId),
                text: Constants.Messages.help
            )
            try await bot.sendMessage(params: params)
        })

        await add(TGMessageHandler({ [weak self] update in
            guard let bot = self?.bot,
                  let text = update.message?.text,
                  let chatId = update.message?.chat.id,
                  let user = update.message?.from else { return }

            print("[Message] \"\(text)\" from user \(user.id) (\(user.firstName) \(user.lastName ?? "")) in chat \(chatId)")

            guard YouTubeDownloader.isYouTubeURL(text) else {
                print("[Message] Not a YouTube URL, sending notALink")
                let params = TGSendMessageParams(chatId: .chat(chatId), text: Constants.Messages.notALink)
                try await bot.sendMessage(params: params)
                return
            }

            print("[YouTube] Starting download for: \(text)")
            let waitParams = TGSendMessageParams(chatId: .chat(chatId), text: Constants.Messages.wait)
            try await bot.sendMessage(params: waitParams)

            do {
                let (title, audioData) = try await YouTubeDownloader.downloadAudio(url: text)
                print("[YouTube] Downloaded: \"\(title)\" (\(audioData.count) bytes)")

                let inputFile = TGInputFile(filename: title, data: audioData)
                let params = TGSendAudioParams(
                    chatId: .chat(chatId),
                    audio: .file(inputFile)
                )
                try await bot.sendAudio(params: params)
                print("[YouTube] Audio sent to chat \(chatId)")
            } catch {
                print("[YouTube] Download failed: \(error)")
                let params = TGSendMessageParams(chatId: .chat(chatId), text: Constants.Messages.oops)
                try await bot.sendMessage(params: params)
            }
        }))
    }
}
