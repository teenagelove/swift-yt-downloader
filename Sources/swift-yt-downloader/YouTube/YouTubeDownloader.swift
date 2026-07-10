import Foundation
import Subprocess
import Logging

enum YouTubeDownloader {

    static func isYouTubeURL(_ urlString: String) -> Bool {
        guard let url = URL(string: urlString),
              let host = url.host(percentEncoded: false) else {
            return false
        }

        if Constants.YouTube.allowedHosts.contains(host) {
            return true
        }

        if host.hasSuffix(Constants.YouTube.subdomainSuffix) {
            return true
        }

        return false
    }

    static func getTitle(url: String, logger: Logger? = nil) async throws -> String {
        let result = try await run(
            .name(Constants.YouTube.ytdlp),
            arguments: ["--print", Constants.YouTube.printTitle, url],
            output: .string(limit: 1024),
            error: .string(limit: 1024)
        )

        if let stderr = result.standardError, !stderr.isEmpty {
            logger?.error("yt-dlp getTitle stderr: \(stderr)")
        }

        guard result.terminationStatus == .exited(0),
              let title = result.standardOutput else {
            logger?.error("yt-dlp getTitle failed with status: \(result.terminationStatus)")
            throw DownloadError.titleFetchFailed
        }

        return sanitizeFilename(title.trimmingCharacters(in: .whitespacesAndNewlines))
    }

    static func downloadAudio(url: String, logger: Logger? = nil) async throws -> (title: String, data: Data) {
        let title = try await getTitle(url: url, logger: logger)

        let result = try await run(
            .name(Constants.YouTube.ytdlp),
            arguments: ["-f", Constants.YouTube.bestAudioFormat, "-o", Constants.YouTube.outputToStdout, url],
            output: .data(limit: Constants.YouTube.maxOutputBytes),
            error: .string(limit: 4096)
        )

        if let stderr = result.standardError, !stderr.isEmpty {
            logger?.error("yt-dlp download stderr: \(stderr)")
        }

        guard result.terminationStatus == .exited(0) else {
            logger?.error("yt-dlp download failed with status: \(result.terminationStatus)")
            throw DownloadError.ytDlpDownloadFailed
        }

        let audioData = result.standardOutput
        guard !audioData.isEmpty else {
            logger?.error("yt-dlp produced empty output")
            throw DownloadError.emptyOutput
        }

        return (title, audioData)
    }

    private static func sanitizeFilename(_ name: String) -> String {
        let invalidCharacters = CharacterSet(charactersIn: "/\\:?*\"<>|")
        return name.components(separatedBy: invalidCharacters).joined()
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .prefix(200).description
    }

    enum DownloadError: LocalizedError {
        case titleFetchFailed
        case ytDlpDownloadFailed
        case emptyOutput

        var errorDescription: String? {
            switch self {
            case .titleFetchFailed:
                return Constants.Errors.titleFetchFailed
            case .ytDlpDownloadFailed:
                return Constants.Errors.ytDlpDownloadFailed
            case .emptyOutput:
                return Constants.Errors.emptyOutput
            }
        }
    }
}
