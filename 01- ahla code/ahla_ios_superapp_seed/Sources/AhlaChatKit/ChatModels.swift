import Foundation

public struct ChatMessage: Codable, Identifiable {
    public var id: UUID = UUID()
    public var room: String
    public var user: String
    public var text: String
    public var ts: Date = Date()
}
