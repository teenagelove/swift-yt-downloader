FROM swift:6.1 AS builder

WORKDIR /app
COPY . .
RUN swift build -c release

FROM swift:6.1-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 \
    python3-pip \
    libcurl4-openssl-dev \
    ca-certificates \
    && pip3 install --no-cache-dir --break-system-packages yt-dlp \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY --from=builder /app/.build/release/swift-yt-downloader .

CMD ["./swift-yt-downloader"]
