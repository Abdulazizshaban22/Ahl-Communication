import Foundation

public final class MeetSignaling: NSObject {
    private var ws: URLSessionWebSocketTask?
    public func connect(url: URL, room: String) {
        ws = URLSession.shared.webSocketTask(with: url)
        ws?.resume()
        let hello = ["room":room]
        let d = try! JSONSerialization.data(withJSONObject: hello)
        ws?.send(.data(d)) { _ in }
    }
    public func send(payload: [String:Any]) {
        let d = try! JSONSerialization.data(withJSONObject: payload)
        ws?.send(.data(d)) { _ in }
    }
}
