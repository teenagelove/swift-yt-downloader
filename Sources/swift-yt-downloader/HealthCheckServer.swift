import Foundation

func startHealthCheckServer(port: UInt16) async {
    let serverFd = socket(AF_INET, SOCK_STREAM, 0)
    guard serverFd >= 0 else { return }

    var reuse: Int32 = 1
    setsockopt(serverFd, SOL_SOCKET, SO_REUSEADDR, &reuse, socklen_t(MemoryLayout<Int32>.size))

    var addr = sockaddr_in()
    addr.sin_family = sa_family_t(AF_INET)
    addr.sin_port = port.bigEndian
    addr.sin_addr.s_addr = INADDR_ANY

    let bindResult = withUnsafePointer(to: &addr) { ptr in
        ptr.withMemoryRebound(to: sockaddr.self, capacity: 1) { bind(serverFd, $0, socklen_t(MemoryLayout<sockaddr_in>.size)) }
    }

    guard bindResult == 0, listen(serverFd, 5) == 0 else { return }

    print("Health check server listening on port \(port)")

    while true {
        var clientAddr = sockaddr_in()
        var clientLen = socklen_t(MemoryLayout<sockaddr_in>.size)

        let clientFd = withUnsafeMutablePointer(to: &clientAddr) { ptr in
            ptr.withMemoryRebound(to: sockaddr.self, capacity: 1) { accept(serverFd, $0, &clientLen) }
        }

        guard clientFd >= 0 else { continue }

        let response = "HTTP/1.1 200 OK\r\nContent-Length: 2\r\n\r\nOK"
        let _ = response.withCString { write(clientFd, $0, strlen($0)) }
        close(clientFd)
    }
}
