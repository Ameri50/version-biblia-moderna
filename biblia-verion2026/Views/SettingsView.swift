import SwiftUI

struct SettingsView: View {
    @StateObject private var languageManager = LanguageManager.shared
    @Environment(\.dismiss) var dismiss
    @State private var selectedLanguage: String = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // HEADER
                VStack(spacing: 8) {
                    Text(NSLocalizedString("settings.title", ""))
                        .font(.system(size: 24, weight: .bold, design: .default))
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.5, green: 0.5, blue: 0.5),
                            Color(red: 0.6, green: 0.6, blue: 0.6)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                
                ScrollView {
                    VStack(spacing: 16) {
                        // SECCIÓN DE IDIOMA
                        VStack(alignment: .leading, spacing: 12) {
                            Text(NSLocalizedString("settings.language", ""))
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.primary)
                            
                            VStack(spacing: 8) {
                                ForEach(Array(languageManager.getLanguages()), id: \.key) { key, value in
                                    LanguageOptionView(
                                        language: key,
                                        displayName: value,
                                        isSelected: languageManager.currentLanguage == key
                                    ) {
                                        languageManager.setLanguage(key)
                                    }
                                }
                            }
                        }
                        .padding(16)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        
                        // MÁS OPCIONES (placeholder para futuras configuraciones)
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Más opciones")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.primary)
                            
                            VStack(spacing: 8) {
                                SettingOptionView(
                                    title: "Tema",
                                    subtitle: "Claro / Oscuro",
                                    icon: "sun.max.fill"
                                )
                                
                                SettingOptionView(
                                    title: "Tamaño de fuente",
                                    subtitle: "Ajusta el tamaño",
                                    icon: "textformat.size"
                                )
                                
                                SettingOptionView(
                                    title: "Notificaciones",
                                    subtitle: "Lectura diaria",
                                    icon: "bell.fill"
                                )
                            }
                        }
                        .padding(16)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        
                        // INFORMACIÓN
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Información")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.primary)
                            
                            VStack(spacing: 8) {
                                SettingOptionView(
                                    title: "Versión",
                                    subtitle: "1.0.0",
                                    icon: "info.circle.fill"
                                )
                                
                                SettingOptionView(
                                    title: "Política de privacidad",
                                    subtitle: "Conoce nuestras políticas",
                                    icon: "lock.fill"
                                )
                            }
                        }
                        .padding(16)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                    .padding(16)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                selectedLanguage = languageManager.currentLanguage
            }
        }
    }
}

// MARK: - Componente: Opción de Idioma
struct LanguageOptionView: View {
    let language: String
    let displayName: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(displayName)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Text(language.uppercased())
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.blue)
                        .font(.system(size: 20))
                } else {
                    Circle()
                        .stroke(Color.gray, lineWidth: 2)
                        .frame(width: 20, height: 20)
                }
            }
            .padding(12)
            .background(isSelected ? Color.blue.opacity(0.1) : Color.white)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 1)
            )
        }
    }
}

// MARK: - Componente: Opción de Configuración
struct SettingOptionView: View {
    let title: String
    let subtitle: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .font(.system(size: 18))
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
                .font(.system(size: 14))
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(8)
    }
}

#Preview {
    SettingsView()
}
