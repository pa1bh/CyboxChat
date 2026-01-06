# HelloiOS

A native iOS chat client for [cbxchat](https://github.com/pa1bh/chatserver), built with SwiftUI.

## Features

- **Real-time messaging** via WebSocket connection
- **AI integration** - Ask questions using `/ai <prompt>`
- **User list** - See who's online
- **Server status** - View uptime, user count, and performance metrics
- **Auto-reconnect** - Automatically reconnects on connection loss
- **Tab navigation** - Clean UI with Chat, Users, and Settings tabs

## Screenshots

```
┌─────────────────────────────┐
│         Chat                │
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

1. Open `HelloiOS/HelloiOS.xcodeproj`
2. Select a simulator (e.g., iPhone 16 Pro)
3. Press `Cmd + R` to build and run

### Option 2: Command Line

```bash
# Build
xcodebuild -project HelloiOS/HelloiOS.xcodeproj \
  -target HelloiOS \
  -sdk iphonesimulator \
  -configuration Debug build

# Install and run on booted simulator
xcrun simctl install booted HelloiOS/build/Debug-iphonesimulator/HelloiOS.app
xcrun simctl launch booted com.example.HelloiOS
```

## Project Structure

```
HelloiOS/
├── HelloiOS.xcodeproj/
└── HelloiOS/
    ├── HelloiOSApp.swift          # App entry point
    ├── ContentView.swift          # TabView container
    ├── Models/
    │   └── ChatModels.swift       # Protocol message types
    ├── Services/
    │   └── WebSocketService.swift # WebSocket connection
    ├── ViewModels/
    │   └── ChatViewModel.swift    # State management
    └── Views/
        ├── ChatView.swift         # Chat interface
        ├── MessageView.swift      # Message bubbles
        ├── UsersView.swift        # Online users list
        └── SettingsView.swift     # Settings & status
```

## Protocol

Connects to `wss://chat.cybox.io/ws` using JSON messages:

### Client → Server

| Type | Description |
|------|-------------|
| `chat` | Send a message |
| `setName` | Change display name |
| `listUsers` | Request user list |
| `status` | Request server status |
| `ai` | Ask AI a question |

### Server → Client

| Type | Description |
|------|-------------|
| `chat` | Incoming message |
| `system` | Join/leave notifications |
| `ackName` | Name change confirmation |
| `listUsers` | User list response |
| `status` | Server metrics |
| `ai` | AI response |
| `error` | Error message |

## Usage

- **Send message**: Type in the text field and tap send
- **Ask AI**: Type `/ai <your question>`
- **Change name**: Go to Settings → Change Name
- **View users**: Tap the Users tab
- **Server status**: Settings → Refresh Status

## License

MIT
