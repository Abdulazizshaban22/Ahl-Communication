import Foundation
public final class ChatWSClient: NSObject, ObservableObject {
    private var task: URLSessionWebSocketTask?
    private let url: URL
    @Published public var messages: [ChatMessage] = []
    public init(url: URL) { self.url = url; super.init() }
    public func connect(room: String) {
        var req = URLRequest(url: url)
        task = URLSession(configuration: .default).webSocketTask(with: req)
        task?.resume()
        listen()
        let hello = ["room": room]
        let d = try! JSONSerialization.data(withJSONObject: hello); task?.send(.data(d)) {_ in}
    }
    private func listen() {
        task?.receive { [weak self] result in
            guard let self = self else { return }
            if case .success(let msg) = result {
                switch msg {
                case .string(let s):
                    if let d = s.data(using: .utf8),
                       let cm = try? JSONDecoder().decode(ChatMessage.self, from: d) {
                        DispatchQueue.main.async { self.messages.insert(cm, at: 0) }
                    }
                case .data(let d):
                    if let cm = try? JSONDecoder().decode(ChatMessage.self, from: d) {
                        DispatchQueue.main.async { self.messages.insert(cm, at: 0) }
                    }
                @unknown default: break
                }
            }
            self.listen()
        }
    }
    public func send(room: String, user: String, text: String) {
        let msg = ChatMessage(room: room, user: user, text: text)
        if let d = try? JSONEncoder().encode(msg) { task?.send(.data(d)) { _ in } }
    }
    public func disconnect(){ task?.cancel() }
}
