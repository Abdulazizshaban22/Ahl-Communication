import SwiftUI
import AhlaiOS

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
        VStack {
            HStack {
                TextField("room", text: $room).textFieldStyle(.roundedBorder)
                TextField("you@ahla.com", text: $user).textFieldStyle(.roundedBorder)
            }
            HStack {
                TextField("message", text: $text).textFieldStyle(.roundedBorder)
                Button("Send") { chat.send(room: room, user: user, text: text); text = "" }
            }
        }.padding().onAppear { chat.connect(room: room) }
    }
}
