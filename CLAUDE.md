# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build Commands

```bash
# Build for simulator
xcodebuild -project CyboxChat.xcodeproj -target CyboxChat -sdk iphonesimulator -configuration Debug build

# Install on booted simulator
xcrun simctl install booted build/Debug-iphonesimulator/CyboxChat.app
xcrun simctl launch booted com.cybox.cyboxchat

# Build for device (requires signing)
xcodebuild -project CyboxChat.xcodeproj -target CyboxChat -sdk iphoneos -configuration Debug build
```

## Architecture

Native iOS chat client using SwiftUI and the `@Observable` macro (iOS 17+).

### Data Flow

```
WebSocketService → ChatViewModel → Views
     ↑                   ↓
     └───── send() ──────┘
```

- **WebSocketService**: Manages URLSessionWebSocketTask connection to `wss://chat.cybox.io/ws`. Handles auto-reconnect with exponential backoff.
- **ChatViewModel**: Central state manager using `@Observable`. Owns WebSocketService and NotificationService instances. Processes incoming messages and exposes state to views.
- **NotificationService**: Singleton handling `UNUserNotificationCenter`. Acts as delegate to suppress foreground notifications.

### Protocol (JSON over WebSocket)

Outgoing messages use `OutgoingMessage` enum with custom `Encodable`. Incoming messages use `IncomingMessage` enum with type-discriminated decoding based on `type` field.

Key message types:
- `chat` / `system` / `ai` → displayed in chat
- `ackName` → confirms name change, sets `currentName`
- `listUsers` → populates Users tab
- `status` → server metrics for Settings

### UI Structure

`ContentView` contains a `TabView` with three tabs:
1. **ChatView** - Message list + input field. `/ai <prompt>` triggers AI request.
2. **UsersView** - Online users list, refreshes on appear and join/leave events.
3. **SettingsView** - Profile, notifications toggle, connection status, server stats.

## Bundle Info

- Bundle ID: `com.cybox.cyboxchat`
- Display Name: "Cybox Chat"
- Deployment Target: iOS 17.0
