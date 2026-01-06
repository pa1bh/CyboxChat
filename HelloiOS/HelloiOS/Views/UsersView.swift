import SwiftUI

struct UsersView: View {
    @Bindable var viewModel: ChatViewModel

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(viewModel.users) { user in
                        UserRow(user: user, isCurrentUser: user.name == viewModel.currentName)
                    }
                } header: {
                    Text("\(viewModel.users.count) online")
                }
            }
            .navigationTitle("Users")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.requestUsers()
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .refreshable {
                viewModel.requestUsers()
            }
            .overlay {
                if viewModel.users.isEmpty {
                    ContentUnavailableView(
                        "No Users",
                        systemImage: "person.slash",
                        description: Text(viewModel.isConnected ? "No one else is online" : "Connect to see users")
                    )
                }
            }
        }
    }
}

struct UserRow: View {
    let user: User
    let isCurrentUser: Bool

    var body: some View {
        HStack {
            Image(systemName: "person.circle.fill")
                .font(.title2)
                .foregroundStyle(isCurrentUser ? .blue : .secondary)

            VStack(alignment: .leading) {
                HStack {
                    Text(user.name)
                        .fontWeight(isCurrentUser ? .semibold : .regular)
                    if isCurrentUser {
                        Text("(you)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Spacer()

            Circle()
                .fill(.green)
                .frame(width: 10, height: 10)
        }
    }
}

#Preview {
    UsersView(viewModel: ChatViewModel())
}
