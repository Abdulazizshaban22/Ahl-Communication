import Foundation

final class ChatViewModel: ObservableObject {
    @Published var messages: [Message] = [
        .init(id: UUID(), mine: false, text: "مرحبا 👋🏽", time: Date()),
        .init(id: UUID(), mine: true, text: "يا هلا", time: Date())
    ]

    func send(_ text: String) {
        messages.append(.init(id: UUID(), mine: true, text: text, time: Date()))
        // Demo call into Rust echo:
        let echoed = AhlaCoreBridge.shared.echo(text)
        messages.append(.init(id: UUID(), mine: false, text: echoed, time: Date()))
    }
}
