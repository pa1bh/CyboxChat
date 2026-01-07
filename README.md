# Cybox Chat

A native iOS chat client for [cbxchat](https://github.com/pa1bh/chatserver), built with SwiftUI.

## Features

- **Real-time messaging** via WebSocket connection
- **AI integration** - Ask questions using `/ai <prompt>`
- **User list** - See who's online
- **Server status** - View uptime, user count, and performance metrics
- **Ping latency** - Test connection with color-coded latency display
- **Configurable server** - Connect to any compatible WebSocket server
- **Auto-reconnect** - Automatically reconnects on connection loss
- **Tab navigation** - Clean UI with Chat, Users, and Settings tabs
- **Push notifications** - Get notified of new messages (configurable)

## Screenshots

```
┌─────────────────────────────┐
│       Cybox Chat            │
├─────────────────────────────┤
│  [System] User joined       │
│  [Bob] Hello everyone!      │
│  [You] Hi Bob!              │
│  [AI] Response to question  │
├─────────────────────────────┤
│  [ Type message...    ]  ➤  │
├─────────────────────────────┤
│  💬 Chat │ 👥 Users │ ⚙️    │
└─────────────────────────────┘
```

## Requirements

- macOS with Xcode 15+
- iOS 17.0+ (deployment target)
- iOS Simulator or physical device

## Building

### Option 1: Xcode

1. Open `CyboxChat.xcodeproj`
2. Select a simulator (e.g., iPhone 16 Pro)
3. Press `Cmd + R` to build and run

### Option 2: Command Line

```bash
# Build
xcodebuild -project CyboxChat.xcodeproj \
  -target CyboxChat \
  -sdk iphonesimulator \
  -configuration Debug build

# Install and run on booted simulator
xcrun simctl install booted build/Debug-iphonesimulator/CyboxChat.app
xcrun simctl launch booted com.cybox.cyboxchat
```

## Project Structure

```
CyboxChat/
├── CyboxChat.xcodeproj/
├── README.md
├── .gitignore
└── CyboxChat/
    ├── CyboxChatApp.swift         # App entry point
    ├── ContentView.swift          # TabView container
    ├── Models/
    │   └── ChatModels.swift       # Protocol message types
    ├── Services/
    │   ├── WebSocketService.swift # WebSocket connection
    │   └── NotificationService.swift # Local notifications
    ├── ViewModels/
    │   └── ChatViewModel.swift    # State management
    └── Views/
        ├── ChatView.swift         # Chat interface
        ├── MessageView.swift      # Message bubbles
        ├── UsersView.swift        # Online users list
        └── SettingsView.swift     # Settings & status
```

## Protocol

Connects to `wss://chat.cybox.io/ws` by default (configurable in Settings). Uses JSON messages:

### Client → Server

| Type | Description |
|------|-------------|
| `chat` | Send a message |
| `setName` | Change display name |
| `listUsers` | Request user list |
| `status` | Request server status |
| `ai` | Ask AI a question |
| `ping` | Test connection latency |

### Server → Client

| Type | Description |
|------|-------------|
| `chat` | Incoming message |
| `system` | Join/leave notifications |
| `ackName` | Name change confirmation |
| `listUsers` | User list response |
| `status` | Server metrics |
| `ai` | AI response |
| `pong` | Ping response |
| `error` | Error message |

## Usage

- **Send message**: Type in the text field and tap send
- **Ask AI**: Type `/ai <your question>`
- **Change name**: Go to Settings → Change Name
- **Change server**: Settings → Change Server
- **Test latency**: Settings → Ping (when connected)
- **View users**: Tap the Users tab
- **Server status**: Settings → Refresh Status
- **Notifications**: Settings → Enable Notifications

## License

MIT
