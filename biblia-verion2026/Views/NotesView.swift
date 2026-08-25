// File: Views/NotesView.swift
import SwiftData
import SwiftUI

struct NotesView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \BibleNote.updatedAt, order: .reverse) private var notes: [BibleNote]
    @State private var editingNote: BibleNote?
    @State private var editingText = ""

    var body: some View {
        NavigationStack {
            List {
                if notes.isEmpty {
                    Text("Aun no has escrito notas.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(notes) { note in
                        Button {
                            editingText = note.text
                            editingNote = note
                        } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(note.reference)
                                    .font(.subheadline.weight(.semibold))
                                Text(note.text)
                                    .font(.body)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(3)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                    .onDelete(perform: delete)
                }
            }
            .navigationTitle("Notas")
            .toolbar {
                if !notes.isEmpty {
                    EditButton()
                }
            }
            .sheet(item: $editingNote) { note in
                NoteEditorView(reference: note.reference, text: $editingText) {
                    note.text = editingText
                    note.updatedAt = .now
                    editingNote = nil
                }
            }
        }
    }

    private func delete(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(notes[index])
        }
    }
}
