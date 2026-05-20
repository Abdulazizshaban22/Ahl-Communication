import SwiftUI

struct ChatView: View {
    @StateObject var vm = ChatViewModel()
    @State private var draft = ""

    let title: String

    var body: some View {
        VStack {
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(vm.messages) { m in
                        HStack {
                            if m.mine { Spacer() }
                            Text(m.text)
                                .padding(12)
                                .background(m.mine ? Color.green.opacity(0.2) : Color.gray.opacity(0.15))
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                            if !m.mine { Spacer() }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            HStack {
                TextField("اكتب رسالة…", text: $draft)
                    .textFieldStyle(.roundedBorder)
                Button("إرسال") {
                    guard !draft.isEmpty else { return }
                    vm.send(draft); draft = ""
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }
        .navigationTitle(title)
    }
}
