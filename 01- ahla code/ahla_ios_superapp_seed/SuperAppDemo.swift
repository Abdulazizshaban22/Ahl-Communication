import SwiftUI
import AhlaChatKit

@main
struct SuperAppDemo: App {
    @StateObject var chat = ChatWSClient(url: URL(string: "wss://mobile-gateway.ahla.com/ws/chat")!)
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(chat)
        }
    }
}

struct ContentView: View {
    @EnvironmentObject var chat: ChatWSClient
    @State var room = "general"
    @State var user = "you@ahla.com"
    @State var text = ""
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    TextField("room", text: $room).textFieldStyle(.roundedBorder)
                    TextField("you@ahla.com", text: $user).textFieldStyle(.roundedBorder)
                }
                HStack {
                    TextField("message", text: $text).textFieldStyle(.roundedBorder)
                    Button("Send") { chat.send(room: room, user: user, text: text); text = "" }
                }
                List(chat.messages) { m in
                    VStack(alignment: .leading) {
                        Text(m.user).font(.caption).foregroundColor(.gray)
                        Text(m.text)
                    }
                }
            }.padding()
            .navigationTitle("Ahla SuperApp")
            .onAppear { chat.connect(room: room) }
        }
    }
}
