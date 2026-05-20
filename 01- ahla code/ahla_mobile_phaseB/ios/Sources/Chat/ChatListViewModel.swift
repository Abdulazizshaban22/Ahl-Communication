import Foundation

final class ChatListViewModel: ObservableObject {
    @Published var items: [Chat] = [
        .init(id: UUID(), title: "أحمد", last: "أهلاً!"),
        .init(id: UUID(), title: "سارة", last: "كيف الحال؟")
    ]
}
