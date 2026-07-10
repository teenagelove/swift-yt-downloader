# YouTube Downloader Bot

A lightweight Swift-based Telegram bot that extracts and downloads audio from YouTube links.

<p align="left">
  <img src="https://img.shields.io/badge/Swift-6.1-F05138?logo=swift&logoColor=white" alt="Swift 6.1"/>
  <img src="https://img.shields.io/badge/Async_Await-5856D6?logo=swift&logoColor=white" alt="Async/Await"/>
  <img src="https://img.shields.io/badge/TelegramBot-4.6-26A5E4?logo=telegram&logoColor=white" alt="Telegram Bot"/>
  <img src="https://img.shields.io/badge/Subprocess-0.5-FF6B35?logo=apple&logoColor=white" alt="Subprocess"/>
  <img src="https://img.shields.io/badge/yt--dlp-latest-FF1D15?logo=youtube&logoColor=white" alt="yt-dlp"/>
  <img src="https://img.shields.io/badge/Docker-Multi--Stage-2496ED?logo=docker&logoColor=white" alt="Docker"/>
  <img src="https://img.shields.io/badge/Conventional_Commits-FE5196?logo=git&logoColor=white" alt="Conventional Commits"/>
</p>

## Features

- Paste a YouTube URL in Telegram → receive an audio file with the video title.
- Native async/await throughout — no GCD, no callbacks.
- Streaming download via `yt-dlp` — no temp files, no FFmpeg dependency.
- Production-ready multi-stage Docker build.

## Architecture

- Language: Swift 6.1 (100%)
- Entry point: `main.swift` — bot initialization and update loop
- Bot routing: `Bot/YouTubeDispatcher.swift` — command registration and message handling
- YouTube logic: `YouTube/YouTubeDownloader.swift` — URL validation and audio download
- Constants: `Constants/Constants.swift` — centralized configuration and text constants
- Build: `Package.swift` (SPM) + `Dockerfile` for containerized deployment

## Prerequisites

- Swift 6.1+
- [yt-dlp](https://github.com/yt-dlp/yt-dlp) installed and available in PATH
- Telegram Bot Token from [@BotFather](https://t.me/BotFather)
- Docker (optional, for containerized deployment)

## Configuration

Set environment variables:

- `TELEGRAM_BOT_TOKEN` — token from @BotFather

## Local Development

1. Clone the repository:
```
git clone https://github.com/danilkazakov/swift-yt-downloader.git
cd swift-yt-downloader
```

2. Ensure `yt-dlp` is installed:
```
# macOS
brew install yt-dlp

# Linux
pip3 install yt-dlp
```

3. Build and run:
```
swift build -c release
export TELEGRAM_BOT_TOKEN="your-token-here"
.build/release/swift-yt-downloader
```

4. Send a YouTube link to your bot in Telegram and receive audio back.

## Docker

Build and run with Docker:
```
docker build -t swift-yt-downloader .
docker run -e TELEGRAM_BOT_TOKEN="your-token-here" swift-yt-downloader
```

## Bot Usage

- Send a message containing a YouTube URL. The bot:
  - Validates the link
  - Fetches the video title
  - Downloads audio stream via `yt-dlp`
  - Sends the audio file back with the title as filename
- Commands:
  - `/start` — greeting and usage info
  - `/help` — show usage info

## Project Structure

```
.
├── Sources/swift-yt-downloader/
│   ├── main.swift                 # Entry point
│   ├── Bot/
│   │   └── YouTubeDispatcher.swift # Command routing & handlers
│   ├── YouTube/
│   │   └── YouTubeDownloader.swift # URL validation & audio download
│   └── Constants/
│       └── Constants.swift        # Centralized constants
├── Package.swift                  # SPM package definition
├── Dockerfile                     # Multi-stage container build
├── .gitignore
├── LICENSE
└── README.md
```
