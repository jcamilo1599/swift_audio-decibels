//
//  AudioManager.swift
//  AudioDecibels
//
//  Created by Juan Camilo Marín Ochoa on 5/06/24.
//

import AVFoundation
import Combine
#if os(macOS)
import AppKit
#endif

// Clase para manejar el audio y calcular los niveles de decibeles
class AudioManager: ObservableObject {
    private var audioRecorder: AVAudioRecorder?
    private var timer: Timer?
    private var decibelValues: [Float] = []
    
    @Published var decibels: Float = 0.0
    @Published var avgDecibels: Float = 0.0
    @Published var minimum: Float?
    @Published var maximum: Float?
    
    // Estado de permisos para que la UI pueda reaccionar
    @Published var micAuthorized: Bool = false
    @Published var micDenied: Bool = false
    
    // Inicializador que verifica/solicita acceso al micrófono
    init() {
        checkAndRequestMicrophoneAccessIfNeeded()
    }
    
    // Verifica el estado y, si hace falta, solicita acceso al micrófono
    private func checkAndRequestMicrophoneAccessIfNeeded() {
#if os(macOS)
        let status = AVCaptureDevice.authorizationStatus(for: .audio)
        switch status {
        case .authorized:
            micAuthorized = true
            micDenied = false
            setupRecorder()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .audio) { granted in
                DispatchQueue.main.async {
                    self.micAuthorized = granted
                    self.micDenied = !granted
                    if granted {
                        self.setupRecorder()
                    } else {
                        print("El acceso al micrófono fue denegado.")
                    }
                }
            }
        case .denied, .restricted:
            micAuthorized = false
            micDenied = true
            print("El acceso al micrófono fue denegado o restringido.")
        @unknown default:
            micAuthorized = false
            micDenied = true
            print("Estado de autorización desconocido para el micrófono.")
        }
#else
        setupRecorder()
        micAuthorized = true
        micDenied = false
#endif
    }
    
    // Configuración del grabador de audio
    private func setupRecorder() {
#if os(macOS)
        // Configuración del grabador de audio para macOS
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatAppleLossless), // Formato de audio
            AVSampleRateKey: 44100.0, // Tasa de muestreo
            AVNumberOfChannelsKey: 1, // Número de canales
            AVEncoderAudioQualityKey: AVAudioQuality.max.rawValue // Calidad de audio
        ]
        
        // URL del archivo de grabación (en este caso, un archivo temporal)
        let url = URL(fileURLWithPath: "/dev/null")
        do {
            audioRecorder = try AVAudioRecorder(url: url, settings: settings)
            audioRecorder?.isMeteringEnabled = true // Habilitar medición de niveles de audio
            audioRecorder?.prepareToRecord()
        } catch {
            print("Error setting up audio recorder: \(error.localizedDescription)")
        }
#else
        let audioSession = AVAudioSession.sharedInstance()
        do {
            // Configurar la sesión de audio para grabar y reproducir
            try audioSession.setCategory(.playAndRecord, mode: .default)
            try audioSession.setActive(true)
            
            // Configuración del grabador de audio
            let settings: [String: Any] = [
                AVFormatIDKey: Int(kAudioFormatAppleLossless), // Formato de audio
                AVSampleRateKey: 44100.0, // Tasa de muestreo
                AVNumberOfChannelsKey: 1, // Número de canales
                AVEncoderAudioQualityKey: AVAudioQuality.max.rawValue // Calidad de audio
            ]
            
            // URL del archivo de grabación (en este caso, un archivo temporal)
            let url = URL(fileURLWithPath: "/dev/null")
            audioRecorder = try AVAudioRecorder(url: url, settings: settings)
            audioRecorder?.isMeteringEnabled = true // Habilitar medición de niveles de audio
            audioRecorder?.prepareToRecord()
        } catch {
            print("Error setting up audio recorder: \(error.localizedDescription)")
        }
#endif
    }
    
    // Inicia el monitoreo de audio
    func startMonitoring() {
#if os(macOS)
        // No volver a pedir permiso aquí; usar el estado ya conocido
        guard micAuthorized else {
            // Si está denegado, informar (la UI puede ofrecer abrir Ajustes)
            if micDenied {
                print("Permiso de micrófono denegado. Abre Ajustes del Sistema > Privacidad y seguridad > Micrófono.")
            } else {
                // Si aún no se determinó, intenta solicitarlo
                checkAndRequestMicrophoneAccessIfNeeded()
            }
            return
        }
#endif
        audioRecorder?.record()
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            self.updateDecibels()
        }
    }
    
    // Detiene el monitoreo de audio
    func stopMonitoring() {
        audioRecorder?.stop()
        timer?.invalidate()
        timer = nil
        decibelValues.removeAll() // Limpiar valores de decibeles anteriores
    }
    
    // Actualiza los niveles de decibeles y calcula el promedio
    private func updateDecibels() {
        audioRecorder?.updateMeters()
        if let averagePower = audioRecorder?.averagePower(forChannel: 0) {
            // Definir los límites de la escala de decibeles
            let minDecibels: Float = -80.0 // Nivel mínimo de decibeles para el umbral
            let maxDecibels: Float = 0.0 // Nivel máximo de decibeles
            let scaledPower = max(minDecibels, averagePower)
            
            // Convertir el valor de potencia promedio a una escala de 0 a 120 dB
            decibels = (scaledPower - minDecibels) / (maxDecibels - minDecibels) * 120
            
            // Filtrado de valores anómalos
            if decibels < 0 {
                decibels = 0
            }
            
            // Almacenar el valor de decibeles y calcular el promedio
            decibelValues.append(decibels)
            avgDecibels = decibelValues.reduce(0, +) / Float(decibelValues.count)
            
            // Obtiene los decibeles mínimos
            if minimum == nil || decibels < minimum! {
                minimum = decibels
            }
            
            // Obtiene los decibeles máximos
            if maximum == nil || decibels > maximum! {
                maximum = decibels
            }
        }
    }
    
#if os(macOS)
    // Abre la sección de Privacidad del micrófono en Ajustes del Sistema
    func openMicrophonePrivacyPane() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Microphone") {
            NSWorkspace.shared.open(url)
        }
    }
#endif
}

