//
//  AudioManager.swift
//  AudioDecibels
//
//  Created by Juan Camilo Marín Ochoa on 5/06/24.
//

import AVFoundation
import Combine

// Clase para manejar el audio y calcular los niveles de decibeles
class AudioManager: ObservableObject {
    private var audioRecorder: AVAudioRecorder?
    private var timer: Timer?
    private var decibelValues: [Float] = []
    
    @Published var decibels: Float = 0.0
    @Published var avgDecibels: Float = 0.0
    @Published var minimum: Float?
    @Published var maximum: Float?
    
    // Inicializador que configura el grabador de audio
    init() {
        requestMicrophoneAccess()
    }
    
    // Solicitar acceso al micrófono
    private func requestMicrophoneAccess() {
#if os(macOS)
        AVCaptureDevice.requestAccess(for: .audio) { granted in
            DispatchQueue.main.async {
                if granted {
                    self.setupRecorder()
                } else {
                    print("El acceso al micrófono fue denegado.")
                }
            }
        }
#else
        setupRecorder()
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
        requestMicrophoneAccess()
#endif
        
        audioRecorder?.record()
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
            if (decibels < 0) {
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
}
