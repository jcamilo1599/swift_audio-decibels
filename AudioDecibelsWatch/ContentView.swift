//
//  ContentView.swift
//  AudioDecibelsWatch
//
//  Created by Juan Camilo Marin Ochoa on 21/07/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var audioManager = AudioManager()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                Text("\(audioManager.decibels, specifier: "%.1f") dB")
                    .font(.title)
                    .foregroundStyle(.white)
                    .padding()
                    .frame(width: 200)
                    .cornerRadius(16)
                
                Divider()
                
                HStack {
                    Button(action: {
                        audioManager.startMonitoring()
                    }) {
                        VStack {
                            Image(systemName: "play.circle")
                                .font(.title)
                                .foregroundColor(.green)
                        }
                    }
                    
                    Button(action: {
                        audioManager.stopMonitoring()
                    }) {
                        VStack {
                            Image(systemName: "stop.circle")
                                .font(.title)
                                .foregroundColor(.red)
                        }
                    }
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
                .navigationTitle("Monitor de Decibelios")
            }
        }
    }
}

#Preview {
    ContentView()
}
