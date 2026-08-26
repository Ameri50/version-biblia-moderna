import SwiftUI
import AVFoundation

struct DetalleLibroView: View {
    let libroId: String
    let libroNombre: String
    @StateObject private var repository = BibliaNuevaRepository.shared
    @State private var selectedChapter = 1
    @State private var chapters: [Int] = []

    // UI state
    @State private var isShowingAddNote = false
    @State private var noteText = ""
    @State private var isPlaying = false
    @State private var isPaused = false
    @State private var speechRate: Float = 0.45
    @State private var speechSynth = AVSpeechSynthesizer()
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Group {
            if let libro = repository.obtenerLibro(libroId) {
                VStack(spacing: 0) {
                    // CONTROLES SUPERIORES: compartir, agregar nota, play/pause
                    HStack(spacing: 12) {
                        // Compartir capítulo
                        Button(action: {
                            shareCapitulo(libro: libro, capitulo: selectedChapter)
                        }) {
                            Label("Compartir", systemImage: "square.and.arrow.up")
                                .font(.subheadline)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 10)
                        }
                        .buttonStyle(.bordered)

                        // Agregar nota
                        Button(action: {
                            noteText = "" // reset
                            isShowingAddNote = true
                        }) {
                            Label("Agregar nota", systemImage: "pencil")
                                .font(.subheadline)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 10)
                        }
                        .buttonStyle(.bordered)

                        Spacer()

                        // Play / Pause / Stop
                        HStack(spacing: 8) {
                            Button(action: {
                                if isPlaying && !isPaused {
                                    // pause
                                    speechSynth.pauseSpeaking(at: .immediate)
                                    isPaused = true
                                } else if isPlaying && isPaused {
                                    // resume
                                    speechSynth.continueSpeaking()
                                    isPaused = false
                                } else {
                                    // start playing
                                    startSpeaking(libro: libro, capitulo: selectedChapter)
                                }
                            }) {
                                Image(systemName: isPlaying ? (isPaused ? "play.fill" : "pause.fill") : "play.fill")
                                    .frame(width: 36, height: 36)
                                    .background(Color(UIColor.systemGray5))
                                    .cornerRadius(8)
                            }

                            Button(action: stopSpeaking) {
                                Image(systemName: "stop.fill")
                                    .frame(width: 36, height: 36)
                                    .background(Color(UIColor.systemGray5))
                                    .cornerRadius(8)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(Color(.systemBackground))
                    .overlay(Divider(), alignment: .bottom)

                    // Selector de capítulos: chips en scroll horizontal
                    ScrollViewReader { proxy in
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(chapters, id: \.self) { cap in
                                    Button {
                                        withAnimation(.easeInOut(duration: 0.15)) {
                                            selectedChapter = cap
                                        }
                                    } label: {
                                        Text("\(cap)")
                                            .font(.system(size: 14, weight: .semibold))
                                            .frame(minWidth: 36, minHeight: 36)
                                            .background(
                                                Circle().fill(
                                                    cap == selectedChapter
                                                        ? Color.accentColor
                                                        : Color(.systemGray6)
                                                )
                                            )
                                            .foregroundColor(cap == selectedChapter ? .white : .primary)
                                    }
                                    .id(cap)
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                        }
                        .onChange(of: selectedChapter) { _old, nuevo in
                            withAnimation { proxy.scrollTo(nuevo, anchor: .center) }
                            // stop speech if chapter changes
                            stopSpeaking()
                        }
                    }

                    Divider()

                    // Versículos del capítulo seleccionado
                    ScrollView {
                        VStack(alignment: .leading, spacing: 14) {
                            Text("Capítulo \(selectedChapter)")
                                .font(.system(size: 20, weight: .bold))
                                .padding(.top, 16)

                            ForEach(libro.versiculosDelCapitulo(selectedChapter)) { versiculo in
                                HStack(alignment: .top, spacing: 8) {
                                    Text("\(versiculo.numeroVersiculo ?? 0)")
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundColor(.blue)
                                        .frame(width: 22, alignment: .trailing)

                                    Text(versiculo.contenidoLimpio)
                                        .font(.system(size: 16, weight: .regular))
                                        .foregroundColor(.primary)
                                        .lineSpacing(5)
                                }
                            }

                            // Navegación entre capítulos
                            HStack {
                                Button {
                                    irACapitulo(selectedChapter - 1)
                                } label: {
                                    Label("Anterior", systemImage: "chevron.left")
                                }
                                .disabled(selectedChapter <= (chapters.first ?? 1))

                                Spacer()

                                Button {
                                    irACapitulo(selectedChapter + 1)
                                } label: {
                                    Label("Siguiente", systemImage: "chevron.right")
                                }
                                .disabled(selectedChapter >= (chapters.last ?? 1))
                            }
                            .padding(.top, 16)
                            .padding(.bottom, 24)
                        }
                        .padding(.horizontal, 16)
                    }
                }
                .onAppear {
                    chapters = libro.capitulosUnicos.sorted()
                    if !chapters.contains(selectedChapter) {
                        selectedChapter = chapters.first ?? 1
                    }
                }
                .sheet(isPresented: $isShowingAddNote) {
                    AddNoteSheet(isPresented: $isShowingAddNote,
                                 initialReference: "\(libroNombre) \(selectedChapter)",
                                 bookName: libroNombre,
                                 onSave: { content in
                        // Crear BibleNote en modelContext
                        let note = BibleNote()
                        note.reference = "\(libroNombre) \(selectedChapter)"
                        note.bookName = libroNombre
                        note.noteContent = content
                        note.createdAt = Date()
                        modelContext.insert(note)
                        try? modelContext.save()
                    })
                }
            } else if repository.isLoading {
                ProgressView("Cargando \(libroNombre)...")
                    .frame(maxHeight: .infinity)
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "book.closed")
                        .font(.system(size: 40))
                        .foregroundColor(.gray)
                    Text("No se pudo cargar \(libroNombre)")
                        .foregroundColor(.gray)
                }
                .frame(maxHeight: .infinity)
            }
        }
        .navigationTitle(libroNombre)
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear {
            // asegurar que se detiene la lectura al salir
            stopSpeaking()
        }
    }

    private func irACapitulo(_ numero: Int) {
        guard chapters.contains(numero) else { return }
        withAnimation(.easeInOut(duration: 0.15)) {
            selectedChapter = numero
        }
    }

    // Compartir texto del capítulo
    private func shareCapitulo(libro: BibliaLibro, capitulo: Int) {
        let texto = libro.versiculosDelCapitulo(capitulo)
            .map { "\($0.numeroVersiculo ?? 0) \($0.contenidoLimpio)" }
            .joined(separator: "\n\n")
        let title = "\(libroNombre) - Capítulo \(capitulo)"
        let items: [Any] = [title, texto]
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let root = windowScene.windows.first?.rootViewController {
            let av = UIActivityViewController(activityItems: items, applicationActivities: nil)
            root.present(av, animated: true)
        }
    }

    // Text-to-Speech
    private func startSpeaking(libro: BibliaLibro, capitulo: Int) {
        guard !speechSynth.isSpeaking else {
            // si ya está en pausa/resume lo manejamos en botón
            return
        }
        let versos = libro.versiculosDelCapitulo(capitulo)
            .map { "\($0.numeroVersiculo ?? 0). \($0.contenidoLimpio)" }
            .joined(separator: " ")
        let utterance = AVSpeechUtterance(string: versos)
        utterance.voice = AVSpeechSynthesisVoice(language: "es-ES") ?? AVSpeechSynthesisVoice(language: "es-419")
        utterance.rate = speechRate
        utterance.pitchMultiplier = 1.0
        speechSynth.delegate = SpeechDelegate { finished in
            // cuando termina
            DispatchQueue.main.async {
                isPlaying = false
                isPaused = false
            }
        }
        isPlaying = true
        isPaused = false
        speechSynth.stopSpeaking(at: .immediate) // asegurar estado limpio
        speechSynth.speak(utterance)
    }

    private func stopSpeaking() {
        if speechSynth.isSpeaking {
            speechSynth.stopSpeaking(at: .immediate)
        }
        isPlaying = false
        isPaused = false
    }
}

// Helper para hoja de agregar nota
struct AddNoteSheet: View {
    @Binding var isPresented: Bool
    let initialReference: String
    let bookName: String
    var onSave: (String) -> Void
    @State private var content: String = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                Text("Nota para \(initialReference)")
                    .font(.headline)
                    .padding(.top)

                TextEditor(text: $content)
                    .padding(8)
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(8)
                    .frame(minHeight: 160)

                Spacer()
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        onSave(content.trimmingCharacters(in: .whitespacesAndNewlines))
                        isPresented = false
                    }
                    .disabled(content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { isPresented = false }
                }
            }
        }
    }
}

// Speech delegate para detectar fin de lectura
private class SpeechDelegate: NSObject, AVSpeechSynthesizerDelegate {
    private let onFinish: (Bool) -> Void
    init(onFinish: @escaping (Bool) -> Void) {
        self.onFinish = onFinish
    }
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        onFinish(true)
    }
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        onFinish(false)
    }
}
