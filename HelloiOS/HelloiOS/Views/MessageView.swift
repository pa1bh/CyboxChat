import SwiftUI

struct MessageView: View {
    let message: DisplayMessage
    let currentUser: String

    var body: some View {
        switch message {
        case .chat(let msg):
            ChatBubble(message: msg, isOwnMessage: msg.from == currentUser)
        case .system(let msg):
            SystemBubble(message: msg)
        case .ai(let msg):
            AIBubble(message: msg)
        }
    }
}

struct ChatBubble: View {
    let message: ChatMessage
    let isOwnMessage: Bool

    var body: some View {
        HStack {
            if isOwnMessage { Spacer() }

            VStack(alignment: isOwnMessage ? .trailing : .leading, spacing: 4) {
                if !isOwnMessage {
                    Text(message.from)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Text(message.text)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(isOwnMessage ? Color.blue : Color(.systemGray5))
                    .foregroundStyle(isOwnMessage ? .white : .primary)
                    .clipShape(RoundedRectangle(cornerRadius: 16))

                Text(message.at, style: .time)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }

            if !isOwnMessage { Spacer() }
        }
        .padding(.horizontal)
    }
}

struct SystemBubble: View {
    let message: SystemMessage

    var body: some View {
        HStack {
            Spacer()
            Text(message.text)
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color(.systemGray6))
                .clipShape(Capsule())
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

struct AIBubble: View {
    let message: AIMessage

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "sparkles")
                    .foregroundStyle(.purple)
                Text("AI")
                    .font(.caption.bold())
                    .foregroundStyle(.purple)
                Spacer()
                Text(message.at, style: .time)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }

            Text("Q: \(message.prompt)")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text(message.response)
                .font(.body)
        }
        .padding()
        .background(Color.purple.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal)
    }
}

#Preview {
    VStack(spacing: 16) {
        MessageView(
            message: .chat(ChatMessage.preview(from: "Bob", text: "Hello everyone!")),
            currentUser: "Alice"
        )
        MessageView(
            message: .chat(ChatMessage.preview(from: "Alice", text: "Hi Bob!")),
            currentUser: "Alice"
        )
        MessageView(
            message: .system(SystemMessage.preview(text: "Charlie joined the chat")),
            currentUser: "Alice"
        )
    }
}

// Preview helpers
extension ChatMessage {
    static func preview(from: String, text: String) -> ChatMessage {
        let json = """
        {"type": "chat", "from": "\(from)", "text": "\(text)", "at": \(Date().timeIntervalSince1970 * 1000)}
        """
        return try! JSONDecoder().decode(ChatMessage.self, from: json.data(using: .utf8)!)
    }
}

extension SystemMessage {
    static func preview(text: String) -> SystemMessage {
        let json = """
        {"type": "system", "text": "\(text)", "at": \(Date().timeIntervalSince1970 * 1000)}
        """
        return try! JSONDecoder().decode(SystemMessage.self, from: json.data(using: .utf8)!)
    }
}
