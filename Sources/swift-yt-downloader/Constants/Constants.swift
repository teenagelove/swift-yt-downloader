enum Constants {

    enum Bot {
        static let start = "/start"
        static let help = "/help"
    }

    enum Environment {
        static let telegramBotToken = "TELEGRAM_BOT_TOKEN"
    }

    enum Messages {
        static let help = "I can save audio from YouTube videos 🎬. Just send me a link to the YouTube video and after a few moments i will send you the audio."
        static let hello = "Hi there! 👾\n\n\(Constants.Messages.help)"
        static let wait = "Just a moment 👻!"
        static let oops = "Oops! Something went wrong!"
        static let notALink = "Send me a YouTube link 🔗"
    }

    enum Errors {
        static let tokenNotSet = "Error: \(Constants.Environment.telegramBotToken) environment variable is not set.\n"
        static let titleFetchFailed = "Failed to fetch video title"
        static let ytDlpDownloadFailed = "yt-dlp download failed"
        static let emptyOutput = "yt-dlp produced no output"
    }

    enum YouTube {
        static let allowedHosts = [
            "youtube.com",
            "www.youtube.com",
            "m.youtube.com",
            "youtu.be"
        ]

        static let subdomainSuffix = ".youtube.com"
        static let ytdlp = "yt-dlp"
        static let bestAudioFormat = "bestaudio"
        static let outputToStdout = "-"
        static let printTitle = "title"
        static let maxOutputBytes = 50 * 1024 * 1024
    }
}
