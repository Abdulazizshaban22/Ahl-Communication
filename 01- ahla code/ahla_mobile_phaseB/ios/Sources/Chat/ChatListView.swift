import SwiftUI

struct ChatListView: View {
    @StateObject var vm = ChatListViewModel()

    var body: some View {
        NavigationStack {
            List(vm.items) { chat in
                NavigationLink(value: chat) {
                    VStack(alignment: .leading) {
                        Text(chat.title).font(.headline)
                        Text(chat.last).font(.subheadline).foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("أهلا شات")
            .navigationDestination(for: Chat.self) { chat in
                ChatView(title: chat.title)
            }
        }
    }
}
