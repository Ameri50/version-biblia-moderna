// File: Views/SettingsView.swift
import SwiftUI

struct SettingsView: View {
    @Environment(AppEnvironment.self) private var app

    var body: some View {
        @Bindable var app = app

        NavigationStack {
            Form {
                Section("Lectura") {
                    Toggle("Mostrar numeros de versiculo", isOn: $app.showVerseNumbers)
                    VStack(alignment: .leading) {
                        Text("Tamano de letra: \(Int(app.fontSize)) pt")
                        Slider(value: $app.fontSize, in: 14...28, step: 1)
                    }
                    VStack(alignment: .leading) {
                        Text("Espaciado entre lineas: \(Int(app.lineSpacing)) pt")
                        Slider(value: $app.lineSpacing, in: 2...16, step: 1)
                    }
                }

                Section("Apariencia") {
                    Picker("Tema", selection: $app.colorSchemePreference) {
                        Text("Sistema").tag("system")
                        Text("Claro").tag("light")
                        Text("Oscuro").tag("dark")
                    }
                }

                Section("Inteligencia artificial") {
                    Toggle("Habilitar respuestas de IA", isOn: $app.aiEnabled)
                }

                Section("Traduccion") {
                    if let translation = app.currentTranslation {
                        LabeledContent("Version actual", value: translation.name)
                        Text(translation.licenseSummary)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Ajustes")
        }
    }
}
