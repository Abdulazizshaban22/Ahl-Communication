import Foundation

struct Chat: Identifiable {
    let id: UUID
    var title: String
    var last: String
}

struct Message: Identifiable, Hashable {
    let id: UUID
    let mine: Bool
    let text: String
    let time: Date
}
