import Foundation
import SwiftUI

@Observable
final class ChatViewModel {
    private let webSocket = WebSocketService()
    private let notificationService = NotificationService.shared

    var messages: [DisplayMessage] = []
    var users: [User] = []
    var currentName: String = "Anonymous"
    var isConnected: Bool = false
    var serverStatus: StatusMessage?
    var errorMessage: String?
    var connectionError: String?
    var pingLatency: Int?  // in milliseconds
    private var pingStartTime: Date?
    var notificationsEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: "notificationsEnabled") }
        set { UserDefaults.standard.set(newValue, forKey: "notificationsEnabled") }
    }

    init() {
        setupWebSocket()
        notificationService.checkPermission()
    }

    func requestNotificationPermission() {
        notificationService.requestPermission()
    }

    var notificationsAuthorized: Bool {
        notificationService.isAuthorized
    }

    private func setupWebSocket() {
        webSocket.onMessage = { [weak self] message in
            self?.handleMessage(message)
        }

        webSocket.onConnectionChange = { [weak self] connected in
            self?.isConnected = connected
            if connected {
                self?.connectionError = nil
                // Set initial name to get ackName with our identity
                self?.webSocket.send(.setName(name: self?.currentName ?? "Anonymous"))
                self?.requestUsers()
            } else {
                // Clear users on disconnect
                self?.users = []
            }
        }

        webSocket.onConnectionError = { [weak self] host in
            self?.connectionError = "Could not connect to server \(host)"
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
        pingStartTime = Date()
        pingLatency = nil
        webSocket.send(.ping(token: UUID().uuidString))
    }

    // MARK: - Handle Incoming Messages

    private func handleMessage(_ message: IncomingMessage) {
        switch message {
        case .chat(let chatMsg):
            messages.append(.chat(chatMsg))
            // Send notification for messages from others
            if notificationsEnabled && chatMsg.from != currentName {
                notificationService.sendNotification(
                    title: chatMsg.from,
                    body: chatMsg.text
                )
            }

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
            if let startTime = pingStartTime {
                let latency = Date().timeIntervalSince(startTime) * 1000
                pingLatency = Int(latency)
                pingStartTime = nil
            }

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
