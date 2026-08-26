// File: Views/AIChatView.swift
import SwiftData
import SwiftUI

struct AIChatView: View {
    @Environment(AppEnvironment.self) private var appEnvironment
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = AIViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Banner de advertencia si IA está desactivada
                if !appEnvironment.aiEnabled {
                    HStack(spacing: 8) {
                        Image(systemName: "exclamationmark.circle.fill")
                            .foregroundColor(.orange)
                        
                        Text("AI está desactivada")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                        
                        Spacer()
                    }
                    .padding(8)
                    .frame(maxWidth: .infinity)
                    .background(.orange.opacity(0.15))
                }

                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 12) {
                            ForEach(viewModel.messages) { message in
                                ChatBubbleView(message: message)
                                    .id(message.id)
                            }
                            
                            if viewModel.isLoading {
                                HStack(spacing: 8) {
                                    ProgressView()
                                        .scaleEffect(0.8, anchor: .center)
                                    
                                    Text("Pensando...")
                                        .foregroundStyle(.secondary)
                                        .font(.system(size: 14, weight: .medium))
                                }
                                .padding(.horizontal)
                                .padding(.top, 8)
                            }
                        }
                        .padding()
                    }
                    .onChange(of: viewModel.messages.count) { _, _ in
                        if let last = viewModel.messages.last {
                            withAnimation {
                                proxy.scrollTo(last.id, anchor: .bottom)
                            }
                        }
                    }
                }

                Divider()

                // Input de chat
                HStack(spacing: 8) {
                    TextField(
                        "Pregunta sobre la Biblia...",
                        text: $viewModel.input,
                        axis: .vertical
                    )
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(1...4)
                    .font(.system(size: 14, weight: .regular))
                    
                    Button {
                        Task {
                            await viewModel.ask(
                                using: appEnvironment,
                                modelContext: modelContext,
                                language: "es"
                            )
                        }
                    } label: {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                    .disabled(
                        viewModel.input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || viewModel.isLoading
                    )
                }
                .padding()
            }
            .navigationTitle("Pregunta a la IA")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Chat Bubble Component
private struct ChatBubbleView: View {
    let message: ChatMessage

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            if message.role == .user {
                Spacer(minLength: 40)
            } else {
                VStack(alignment: .center) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.blue)
                }
                .frame(width: 32, height: 32)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(message.text)
                    .font(.system(size: 15, weight: .regular))
                    .lineSpacing(2)
                    .foregroundColor(.primary)
                
                if !message.references.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(message.references) { reference in
                            HStack(spacing: 4) {
                                Image(systemName: "book.fill")
                                    .font(.system(size: 10))
                                    .foregroundColor(.blue)
                                
                                Text(reference.displayText)
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .padding(8)
                    .background(Color.blue.opacity(0.08))
                    .cornerRadius(6)
                }
            }
            .padding(12)
            .background(
                message.role == .user
                    ? Color.blue.opacity(0.15)
                    : Color.gray.opacity(0.1)
            )
            .cornerRadius(12)
            
            if message.role == .user {
                Spacer(minLength: 40)
            } else {
                Spacer(minLength: 40)
            }
        }
        .padding(.horizontal, 4)
    }
}

#Preview {
    AIChatView()
        .environment(AppEnvironment())
        .modelContainer(for: [AIQuestionHistoryEntry.self], inMemory: true)
}
