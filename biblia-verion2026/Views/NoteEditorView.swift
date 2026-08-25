// File: Views/NoteEditorView.swift
import SwiftUI

struct NoteEditorView: View {
    @Environment(\.dismiss) private var dismiss
    let reference: String
    @Binding var text: String
    var onSave: () -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section(reference) {
                    TextEditor(text: $text)
                        .frame(minHeight: 160)
                }
            }
            .navigationTitle("Nota")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        onSave()
                        dismiss()
                    }
                    .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}
