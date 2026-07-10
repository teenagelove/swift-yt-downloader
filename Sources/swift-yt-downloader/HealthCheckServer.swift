import Foundation

func startHealthCheckServer(port: UInt16) {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
    process.arguments = [
        "python3", "-m", "http.server", "\(port)",
        "--bind", "0.0.0.0"
    ]
    try? process.run()
}
