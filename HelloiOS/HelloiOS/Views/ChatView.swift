import SwiftUI

struct ChatView: View {
    @Bindable var viewModel: ChatViewModel
    @State private var messageText = ""
    @FocusState private var isInputFocused: Bool

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Messages list
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 8) {
                            ForEach(viewModel.messages) { message in
                                MessageView(message: message, currentUser: viewModel.currentName)
                                    .id(message.id)
                            }
                        }
                        .padding(.vertical)
                    }
                    .onChange(of: viewModel.messages.count) { _, _ in
                        if let lastMessage = viewModel.messages.last {
                            withAnimation {
                                proxy.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                        }
                    }
                }

                Divider()

                // Input area
                HStack(spacing: 12) {
                    TextField("Type a message...", text: $messageText)
                        .textFieldStyle(.plain)
                        .padding(12)
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .focused($isInputFocused)
                        .onSubmit {
                            sendMessage()
                        }

                    Button(action: sendMessage) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.title)
                            .foregroundStyle(messageText.isEmpty ? .gray : .blue)
                    }
                    .disabled(messageText.isEmpty)
                }
                .padding()
                .background(Color(.systemBackground))
            }
            .navigationTitle("Chat")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    ConnectionIndicator(isConnected: viewModel.isConnected)
                }
            }
            .overlay {
                if let error = viewModel.errorMessage {
                    ErrorBanner(message: error)
                }
            }
        }
    }

    private func sendMessage() {
        let text = messageText
        messageText = ""
        viewModel.sendMessage(text)
    }
}

struct ConnectionIndicator: View {
    let isConnected: Bool

    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(isConnected ? .green : .red)
                .frame(width: 8, height: 8)
            Text(isConnected ? "Online" : "Offline")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

struct ErrorBanner: View {
    let message: String

    var body: some View {
        VStack {
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.white)
                .padding()
                .background(Color.red)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .padding()
            Spacer()
        }
    }
}

#Preview {
    ChatView(viewModel: ChatViewModel())
}
