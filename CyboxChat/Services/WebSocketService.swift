import Foundation

@Observable
final class WebSocketService: NSObject {
    private var webSocket: URLSessionWebSocketTask?
    private var session: URLSession!
    private let serverURL = URL(string: "wss://chat.cybox.io/ws")!

    var isConnected = false
    var onMessage: ((IncomingMessage) -> Void)?
    var onConnectionChange: ((Bool) -> Void)?

    private var reconnectAttempts = 0
    private let maxReconnectAttempts = 5
    private var reconnectTask: Task<Void, Never>?
    private var intentionalDisconnect = false
    private var hasConnectedOnce = false

    override init() {
        super.init()
        session = URLSession(configuration: .default, delegate: self, delegateQueue: .main)
    }

    func connect() {
        guard webSocket == nil else { return }

        intentionalDisconnect = false
        webSocket = session.webSocketTask(with: serverURL)
        webSocket?.resume()
        // Don't set isConnected here - wait for delegate callback
        receiveMessage()
    }

    func disconnect() {
        intentionalDisconnect = true
        reconnectTask?.cancel()
        reconnectAttempts = maxReconnectAttempts // Prevent auto-reconnect
        webSocket?.cancel(with: .normalClosure, reason: nil)
        webSocket = nil
        isConnected = false
        hasConnectedOnce = false
        onConnectionChange?(false)
    }

    func send(_ message: OutgoingMessage) {
        guard let webSocket = webSocket else { return }

        do {
            let data = try JSONEncoder().encode(message)
            let string = String(data: data, encoding: .utf8) ?? ""
            webSocket.send(.string(string)) { error in
                if let error = error {
                    print("Send error: \(error)")
                }
            }
        } catch {
            print("Encode error: \(error)")
        }
    }

    private func receiveMessage() {
        webSocket?.receive { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let message):
                switch message {
                case .string(let text):
                    self.handleMessage(text)
                case .data(let data):
                    if let text = String(data: data, encoding: .utf8) {
                        self.handleMessage(text)
                    }
                @unknown default:
                    break
                }
                self.receiveMessage()

            case .failure(let error):
                print("Receive error: \(error)")
                self.handleDisconnect()
            }
        }
    }

    private func handleMessage(_ text: String) {
        guard let data = text.data(using: .utf8) else { return }

        do {
            let message = try JSONDecoder().decode(IncomingMessage.self, from: data)
            onMessage?(message)
        } catch {
            print("Decode error: \(error)")
            print("Raw message: \(text)")
        }
    }

    private func handleDisconnect() {
        webSocket = nil
        isConnected = false
        onConnectionChange?(false)
        attemptReconnect()
    }

    private func attemptReconnect() {
        // Don't reconnect if user intentionally disconnected or never connected
        guard !intentionalDisconnect, hasConnectedOnce else {
            print("Skipping reconnect: intentional=\(intentionalDisconnect), hasConnected=\(hasConnectedOnce)")
            return
        }

        guard reconnectAttempts < maxReconnectAttempts else {
            print("Max reconnect attempts reached")
            return
        }

        reconnectAttempts += 1
        let delay = Double(reconnectAttempts) * 2.0
        print("Attempting reconnect #\(reconnectAttempts) in \(delay)s")

        reconnectTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            if !Task.isCancelled {
                self.connect()
            }
        }
    }
}

extension WebSocketService: URLSessionWebSocketDelegate {
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        print("WebSocket connected")
        isConnected = true
        hasConnectedOnce = true
        reconnectAttempts = 0
        onConnectionChange?(true)
    }

    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        print("WebSocket closed: \(closeCode)")
        handleDisconnect()
    }
}
