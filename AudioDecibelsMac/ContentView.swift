//
//  ContentView.swift
//  AudioDecibelsMac
//
//  Created by Juan Camilo Marin Ochoa on 21/07/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var audioManager = AudioManager()
    @State private var showMicDeniedAlert = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                Text("Monitor de Decibelios")
                    .font(.title)
                    .padding()
                
                DecibelMeterView(decibels: audioManager.decibels, color: color(for: audioManager.decibels))
                    .frame(width: 50, height: 300)
                    .padding()
                
                if audioManager.decibels > 0 {
                    Text(description(for: audioManager.decibels))
                }
                
                Text("\(audioManager.decibels, specifier: "%.1f") dB")
                    .font(.title)
                    .foregroundStyle(.white)
                    .padding()
                    .frame(width: 200)
                    .background(color(for: audioManager.decibels))
                    .cornerRadius(16)
                
                // Los sonidos por encima de 85 dB son dañinos
            }
            .padding()
            
            Divider()
            
            HStack {
                Button(action: {
                    audioManager.startMonitoring()
                }) {
                    Text("Iniciar Monitor")
                        .padding()
                        .background(.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .buttonStyle(PlainButtonStyle())
                
                Button(action: {
                    audioManager.stopMonitoring()
                }) {
                    Text("Detener Monitor")
                        .padding()
                        .background(.red)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding()
            
            Divider()
            
            VStack {
                HStack {
                    Spacer()
                    Text("AVG")
                    Text("\(audioManager.avgDecibels, specifier: "%.1f") dB")
                        .bold()
                }
                
                HStack {
                    Spacer()
                    Text("Mínimo")
                    Text("\(audioManager.minimum ?? 0, specifier: "%.1f") dB")
                        .bold()
                }
                
                HStack {
                    Spacer()
                    Text("Máximo")
                    Text("\(audioManager.maximum ?? 0, specifier: "%.1f") dB")
                        .bold()
                }
            }
            .padding()
        }
        .windowConstraints()
        .onChange(of: audioManager.micDenied) { _, newValue in
            // Cuando el permiso está denegado, mostramos una alerta para guiar al usuario
            if newValue {
                showMicDeniedAlert = true
            }
        }
        .alert("Acceso al micrófono denegado", isPresented: $showMicDeniedAlert) {
            Button("Abrir Ajustes de Privacidad") {
                audioManager.openMicrophonePrivacyPane()
            }
            Button("Cancelar", role: .cancel) { }
        } message: {
            Text("Ve a Ajustes del Sistema > Privacidad y seguridad > Micrófono y permite el acceso para esta app.")
        }
    }
    
    private func description(for decibels: Float) -> String {
        switch decibels {
        case ..<40:
            return "Hojas crujiendo, susurrando"
        case 30..<60:
            return "Ruido promedio del hogar"
        case 40..<70:
            return "Conversación normal, música de fondo"
        case 70..<75:
            return "Ruido de la oficina, dentro de un coche"
        case 75..<80:
            return "Aspiradora, radio promedio"
        case 80..<90:
            return "Motor de césped eléctrico, tráfico pesado"
        case 90..<95:
            return "Metro, conversación gritada"
        case 95..<100:
            return "Reproductor de sonido, motocicleta"
        case 100..<120:
            return "Motosierra, soplador de hojas"
        case 120..<130:
            return "Multitud deportiva, concierto de rock"
        case 130..<140:
            return "Despegue de avión"
        default:
            return "Disparo, sirena, fuegos artificiales"
        }
    }
    
    private func color(for decibels: Float) -> Color {
        switch decibels {
        case ..<30:
            return .accent
        case 30..<40:
            return ._40DB
        case 40..<60:
            return ._60DB
        case 60..<70:
            return ._70DB
        case 70..<75:
            return ._75DB
        case 75..<80:
            return ._80DB
        case 80..<90:
            return ._90DB
        case 90..<100:
            return ._100DB
        case 100..<110:
            return ._110DB
        case 110..<120:
            return ._120DB
        case 120..<130:
            return ._130DB
        default:
            return ._140DB
        }
    }
}

#Preview {
    ContentView()
}

