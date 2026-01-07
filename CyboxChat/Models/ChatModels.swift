import Foundation

// MARK: - Outgoing Messages (Client → Server)

enum OutgoingMessage: Encodable {
    case chat(text: String)
    case setName(name: String)
    case listUsers
    case status
    case ping(token: String?)
    case ai(prompt: String)

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case .chat(let text):
            try container.encode("chat", forKey: .type)
            try container.encode(text, forKey: .text)
        case .setName(let name):
            try container.encode("setName", forKey: .type)
            try container.encode(name, forKey: .name)
        case .listUsers:
            try container.encode("listUsers", forKey: .type)
        case .status:
            try container.encode("status", forKey: .type)
        case .ping(let token):
            try container.encode("ping", forKey: .type)
            try container.encodeIfPresent(token, forKey: .token)
        case .ai(let prompt):
            try container.encode("ai", forKey: .type)
            try container.encode(prompt, forKey: .prompt)
        }
    }

    private enum CodingKeys: String, CodingKey {
        case type, text, name, token, prompt
    }
}

// MARK: - Incoming Messages (Server → Client)

enum IncomingMessage: Decodable {
    case chat(ChatMessage)
    case system(SystemMessage)
    case ackName(AckNameMessage)
    case status(StatusMessage)
    case listUsers(UserListMessage)
    case pong(PongMessage)
    case ai(AIMessage)
    case error(ErrorMessage)

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: TypeKey.self)
        let type = try container.decode(String.self, forKey: .type)

        switch type {
        case "chat":
            self = .chat(try ChatMessage(from: decoder))
        case "system":
            self = .system(try SystemMessage(from: decoder))
        case "ackName":
            self = .ackName(try AckNameMessage(from: decoder))
        case "status":
            self = .status(try StatusMessage(from: decoder))
        case "listUsers":
            self = .listUsers(try UserListMessage(from: decoder))
        case "pong":
            self = .pong(try PongMessage(from: decoder))
        case "ai":
            self = .ai(try AIMessage(from: decoder))
        case "error":
            self = .error(try ErrorMessage(from: decoder))
        default:
            throw DecodingError.dataCorrupted(
                DecodingError.Context(codingPath: [TypeKey.type], debugDescription: "Unknown message type: \(type)")
            )
        }
    }

    private enum TypeKey: String, CodingKey {
        case type
    }
}

// MARK: - Message Types

struct ChatMessage: Decodable, Identifiable {
    let id = UUID()
    let from: String
    let text: String
    let at: Date

    private enum CodingKeys: String, CodingKey {
        case from, text, at
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        from = try container.decode(String.self, forKey: .from)
        text = try container.decode(String.self, forKey: .text)
        let timestamp = try container.decode(Double.self, forKey: .at)
        at = Date(timeIntervalSince1970: timestamp / 1000)
    }
}

struct SystemMessage: Decodable, Identifiable {
    let id = UUID()
    let text: String
    let at: Date

    private enum CodingKeys: String, CodingKey {
        case text, at
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        text = try container.decode(String.self, forKey: .text)
        let timestamp = try container.decode(Double.self, forKey: .at)
        at = Date(timeIntervalSince1970: timestamp / 1000)
    }
}

struct AckNameMessage: Decodable {
    let name: String
    let at: Date

    private enum CodingKeys: String, CodingKey {
        case name, at
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        let timestamp = try container.decode(Double.self, forKey: .at)
        at = Date(timeIntervalSince1970: timestamp / 1000)
    }
}

struct StatusMessage: Decodable {
    let uptimeSeconds: Double
    let userCount: Int
    let messagesSent: Int
    let messagesPerSecond: Double
    let memoryMb: Double
}

struct UserListMessage: Decodable {
    let users: [User]
}

struct User: Decodable, Identifiable {
    let id: String
    let name: String
    let ip: String
}

struct PongMessage: Decodable {
    let token: String?
    let at: Date

    private enum CodingKeys: String, CodingKey {
        case token, at
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        token = try container.decodeIfPresent(String.self, forKey: .token)
        let timestamp = try container.decode(Double.self, forKey: .at)
        at = Date(timeIntervalSince1970: timestamp / 1000)
    }
}

struct AIMessage: Decodable, Identifiable {
    let id = UUID()
    let from: String
    let prompt: String
    let response: String
    let at: Date

    private enum CodingKeys: String, CodingKey {
        case from, prompt, response, at
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        from = try container.decode(String.self, forKey: .from)
        prompt = try container.decode(String.self, forKey: .prompt)
        response = try container.decode(String.self, forKey: .response)
        let timestamp = try container.decode(Double.self, forKey: .at)
        at = Date(timeIntervalSince1970: timestamp / 1000)
    }
}

struct ErrorMessage: Decodable {
    let message: String
}

// MARK: - Display Message (unified for UI)

enum DisplayMessage: Identifiable {
    case chat(ChatMessage)
    case system(SystemMessage)
    case ai(AIMessage)

    var id: UUID {
        switch self {
        case .chat(let msg): return msg.id
        case .system(let msg): return msg.id
        case .ai(let msg): return msg.id
        }
    }

    var timestamp: Date {
        switch self {
        case .chat(let msg): return msg.at
        case .system(let msg): return msg.at
        case .ai(let msg): return msg.at
        }
    }
}
