import SwiftUI

struct SettingsView: View {
    @Bindable var viewModel: ChatViewModel
    @State private var newName = ""
    @State private var showingNameAlert = false

    var body: some View {
        NavigationStack {
            List {
                // Profile Section
                Section("Profile") {
                    HStack {
                        Text("Current Name")
                        Spacer()
                        Text(viewModel.currentName)
                            .foregroundStyle(.secondary)
                    }

                    Button("Change Name") {
                        newName = viewModel.currentName
                        showingNameAlert = true
                    }
                }

                // Notifications Section
                Section("Notifications") {
                    Toggle("Enable Notifications", isOn: Binding(
                        get: { viewModel.notificationsEnabled },
                        set: { viewModel.notificationsEnabled = $0 }
                    ))

                    if !viewModel.notificationsAuthorized {
                        Button("Allow Notifications") {
                            viewModel.requestNotificationPermission()
                        }
                        Text("Permission required to receive notifications")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    } else {
                        Button("Send Test Notification") {
                            NotificationService.shared.sendNotification(
                                title: "Test",
                                body: "Als je dit ziet werken notificaties!"
                            )
                        }
                    }
                }

                // Connection Section
                Section("Connection") {
                    HStack {
                        Text("Status")
                        Spacer()
                        HStack(spacing: 4) {
                            Circle()
                                .fill(viewModel.isConnected ? .green : .red)
                                .frame(width: 8, height: 8)
                            Text(viewModel.isConnected ? "Connected" : "Disconnected")
                                .foregroundStyle(.secondary)
                        }
                    }

                    if viewModel.isConnected {
                        Button("Disconnect", role: .destructive) {
                            viewModel.disconnect()
                        }
                    } else {
                        Button("Connect") {
                            viewModel.connect()
                        }
                    }
                }

                // Server Status Section
                Section("Server Status") {
                    if let status = viewModel.serverStatus {
                        StatusRow(label: "Uptime", value: formatUptime(status.uptimeSeconds))
                        StatusRow(label: "Users Online", value: "\(status.userCount)")
                        StatusRow(label: "Messages Sent", value: "\(status.messagesSent)")
                        StatusRow(label: "Messages/sec", value: String(format: "%.1f", status.messagesPerSecond))
                        StatusRow(label: "Memory", value: String(format: "%.1f MB", status.memoryMb))
                    } else {
                        Text("No status available")
                            .foregroundStyle(.secondary)
                    }

                    Button("Refresh Status") {
                        viewModel.requestStatus()
                    }
                    .disabled(!viewModel.isConnected)
                }

                // Help Section
                Section("Help") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Commands")
                            .font(.headline)
                        Text("/ai <question> - Ask AI a question")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                }

                // About Section
                Section("About") {
                    HStack {
                        Text("Server")
                        Spacer()
                        Text("chat.cybox.io")
                            .foregroundStyle(.secondary)
                    }
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .alert("Change Name", isPresented: $showingNameAlert) {
                TextField("Enter new name", text: $newName)
                Button("Cancel", role: .cancel) {}
                Button("Save") {
                    viewModel.setName(newName)
                }
            } message: {
                Text("Enter your new display name (2-32 characters)")
            }
        }
    }

    private func formatUptime(_ seconds: Double) -> String {
        let hours = Int(seconds) / 3600
        let minutes = (Int(seconds) % 3600) / 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        }
        return "\(minutes)m"
    }
}

struct StatusRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
            Spacer()
            Text(value)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    SettingsView(viewModel: ChatViewModel())
}
