import Foundation
import SwiftUI

@Observable
final class ChatViewModel {
    private let webSocket = WebSocketService()

    var messages: [DisplayMessage] = []
    var users: [User] = []
    var currentName: String = "Anonymous"
    var isConnected: Bool = false
    var serverStatus: StatusMessage?
    var errorMessage: String?

    init() {
        setupWebSocket()
    }

    private func setupWebSocket() {
        webSocket.onMessage = { [weak self] message in
            self?.handleMessage(message)
        }

        webSocket.onConnectionChange = { [weak self] connected in
            self?.isConnected = connected
            if connected {
                self?.requestUsers()
            }
        }
    }

    func connect() {
        webSocket.connect()
    }

    func disconnect() {
        webSocket.disconnect()
    }

    // MARK: - Send Messages

    func sendMessage(_ text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        // Check for AI command
        if trimmed.lowercased().hasPrefix("/ai ") {
            let prompt = String(trimmed.dropFirst(4))
            sendAIPrompt(prompt)
        } else {
            webSocket.send(.chat(text: trimmed))
        }
    }

    func setName(_ name: String) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        webSocket.send(.setName(name: trimmed))
    }

    func requestUsers() {
        webSocket.send(.listUsers)
    }

    func requestStatus() {
        webSocket.send(.status)
    }

    func sendAIPrompt(_ prompt: String) {
        webSocket.send(.ai(prompt: prompt))
    }

    func ping() {
        webSocket.send(.ping(token: UUID().uuidString))
    }

    // MARK: - Handle Incoming Messages

    private func handleMessage(_ message: IncomingMessage) {
        switch message {
        case .chat(let chatMsg):
            messages.append(.chat(chatMsg))

        case .system(let sysMsg):
            messages.append(.system(sysMsg))
            // Refresh user list on join/leave
            requestUsers()

        case .ackName(let ackMsg):
            currentName = ackMsg.name

        case .status(let statusMsg):
            serverStatus = statusMsg

        case .listUsers(let userList):
            users = userList.users

        case .pong:
            // Could calculate latency here
            break

        case .ai(let aiMsg):
            messages.append(.ai(aiMsg))

        case .error(let errMsg):
            errorMessage = errMsg.message
            // Clear error after a few seconds
            Task { @MainActor in
                try? await Task.sleep(nanoseconds: 3_000_000_000)
                self.errorMessage = nil
            }
        }
    }
}
