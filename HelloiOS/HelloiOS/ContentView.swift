import SwiftUI

struct ContentView: View {
    @State private var viewModel = ChatViewModel()

    var body: some View {
        TabView {
            ChatView(viewModel: viewModel)
                .tabItem {
                    Label("Chat", systemImage: "bubble.left.fill")
                }

            UsersView(viewModel: viewModel)
                .tabItem {
                    Label("Users", systemImage: "person.2.fill")
                }

            SettingsView(viewModel: viewModel)
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
        .onAppear {
            viewModel.connect()
        }
    }
}

#Preview {
    ContentView()
}
