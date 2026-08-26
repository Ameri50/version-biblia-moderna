import SwiftUI

struct ChatView: View {
    @State private var conversation: Conversation = Conversation(title: NSLocalizedString("tab.ai", comment: "Chat"))
    @State private var inputText: String = ""
    @State private var isSaved: Bool = false
    @State private var showShareSheet: Bool = false
    @State private var activityItems: [Any] = []
    @FocusState private var inputFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            // Messages
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(conversation.messages) { msg in
                            MessageRow(message: msg)
                                .id(msg.id)
                        }
                    }
                    .padding()
                }
                .background(Color(.systemBackground))
                .onChange(of: conversation.messages.count) { _ in
                    // scroll to last
                    if let last = conversation.messages.last {
                        withAnimation { proxy.scrollTo(last.id, anchor: .bottom) }
                    }
                }
            }

            Divider()

            // Pill / toggle above input
            HStack(spacing: 8) {
                Toggle(isOn: Binding(get: { conversation.bibleMode }, set: { conversation.bibleMode = $0 })) {
                    Text(NSLocalizedString("chat.bible.pill", comment: "Sobre la Biblia"))
                        .font(.subheadline)
                }
                .toggleStyle(.button)
                .tint(.blue)

                Spacer()

                Button(action: hideKeyboard) {
                    Text(NSLocalizedString("chat.hideKeyboard", comment: "Bajar teclado"))
                        .font(.subheadline)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)

            // Input area
            HStack(spacing: 8) {
                TextField(NSLocalizedString("chat.placeholder", comment: "Escribe tu mensaje…"), text: $inputText)
                    .textFieldStyle(.roundedBorder)
                    .focused($inputFocused)

                Button(action: sendMessage) {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.blue)
                        .padding(8)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
            .background(Color(.secondarySystemBackground))

            // Actions: Save toggle, Share, Delete
            HStack(spacing: 16) {
                Toggle(isOn: $isSaved) {
                    Text(NSLocalizedString("chat.save.toggle", comment: "Guardar conversación"))
                }
                .onChange(of: isSaved) { save in
                    Task {
                        if save {
                            do { try ConversationStorage.shared.save(conversation) ; showSavedToast() } catch { print("Save error: \(error)") }
                        } else {
                            // if toggled off, remove from disk
                            do { try ConversationStorage.shared.delete(conversation) } catch { /* ignore */ }
                        }
                    }
                }

                Spacer()

                Button(action: shareConversation) {
                    Text(NSLocalizedString("chat.share", comment: "Compartir conversación"))
                }

                Button(role: .destructive, action: confirmDelete) {
                    Text(NSLocalizedString("chat.delete", comment: "Borrar chat"))
                }
            }
            .padding()
            .background(Color(.systemBackground))
        }
        .navigationTitle(NSLocalizedString("tab.ai", comment: "Chat"))
        .toolbar { }
        .sheet(isPresented: $showShareSheet) {
            ActivityView(activityItems: activityItems)
        }
    }

    private func sendMessage() {
        let trimmed = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        // append user message
        let userMsg = Message(sender: NSLocalizedString("chat.sender.user", comment: "Tú"), text: trimmed)
        conversation.messages.append(userMsg)
        inputText = ""

        // If saved, persist
        if isSaved {
            try? ConversationStorage.shared.save(conversation)
        }

        // Simulate assistant reply placeholder — integration point for real engine
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            let replyText: String
            if conversation.bibleMode {
                replyText = NSLocalizedString("chat.bible.activated", comment: "Respuestas con contexto bíblico")
            } else {
                replyText = NSLocalizedString("chat.response.label", comment: "Respuesta") + ": " + "Aquí va la respuesta"
            }
            let assistantMsg = Message(sender: NSLocalizedString("chat.sender.assistant", comment: "Chat"), text: replyText)
            conversation.messages.append(assistantMsg)

            if isSaved {
                try? ConversationStorage.shared.save(conversation)
            }
        }
    }

    private func shareConversation() {
        let convoText = conversation.messages.map { "\($0.sender): \($0.text)" }.joined(separator: "\n\n")
        activityItems = [convoText]
        showShareSheet = true
    }

    private func confirmDelete() {
        guard !conversation.messages.isEmpty else { return }
        // Confirmation using native alert (SwiftUI Alert)
        let title = NSLocalizedString("chat.delete.confirm.title", comment: "¿Borrar toda la conversación?")
        let body = NSLocalizedString("chat.delete.confirm.body", comment: "Esta acción no se puede deshacer.")
        // Since we are in a function, use a simple confirmation via UIAlertController
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let root = windowScene.windows.first?.rootViewController {
            let alert = UIAlertController(title: title, message: body, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("chat.delete.confirm.cancel", comment: "Cancelar"), style: .cancel))
            alert.addAction(UIAlertAction(title: NSLocalizedString("chat.delete.confirm.delete", comment: "Borrar"), style: .destructive) { _ in
                conversation.messages.removeAll()
                isSaved = false
                try? ConversationStorage.shared.delete(conversation)
                showDeletedToast()
            })
            root.present(alert, animated: true)
        }
    }

    private func hideKeyboard() {
        inputFocused = false
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    private func showSavedToast() {
        // lightweight user feedback; replace with app's toast system if available
        DispatchQueue.main.async {
            let alert = UIAlertController(title: nil, message: NSLocalizedString("chat.saved", comment: "Conversación guardada"), preferredStyle: .alert)
            UIApplication.shared.topMostViewController?.present(alert, animated: true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { alert.dismiss(animated: true) }
        }
    }

    private func showDeletedToast() {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: nil, message: NSLocalizedString("chat.delete.confirmed", comment: "Conversación eliminada"), preferredStyle: .alert)
            UIApplication.shared.topMostViewController?.present(alert, animated: true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { alert.dismiss(animated: true) }
        }
    }
}

struct MessageRow: View {
    let message: Message

    var isUser: Bool { message.sender == NSLocalizedString("chat.sender.user", comment: "Tú") }

    var body: some View {
        HStack {
            if isUser { Spacer() }

            VStack(alignment: .leading, spacing: 6) {
                Text(message.sender)
                    .font(.caption)
                    .foregroundColor(.gray)
                Text(message.text)
                    .padding(10)
                    .background(isUser ? Color.blue : Color(.systemGray5))
                    .foregroundColor(isUser ? .white : .primary)
                    .cornerRadius(12)
            }
            .frame(maxWidth: UIScreen.main.bounds.width * 0.75, alignment: .leading)

            if !isUser { Spacer() }
        }
    }
}

// ActivityView for share
struct ActivityView: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// Extensions to find top-most view controller
extension UIApplication {
    var topMostViewController: UIViewController? {
        connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }?
            .rootViewController?.topMost
    }
}

extension UIViewController {
    var topMost: UIViewController {
        presentedViewController?.topMost ?? self
    }
}
