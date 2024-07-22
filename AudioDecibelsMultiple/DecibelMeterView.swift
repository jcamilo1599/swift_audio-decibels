//
//  DecibelMeterView.swift
//  AudioDecibels
//
//  Created by Juan Camilo Marín Ochoa on 8/06/24.
//

import SwiftUI

struct DecibelMeterView: View {
    var decibels: Float
    var color: Color
    
    var body: some View {
        GeometryReader { geometry in
            let height = geometry.size.height
            let barHeight = CGFloat(decibels / 120) * height
            
            ZStack(alignment: .bottom) {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: height)
                Rectangle()
                    .fill(color)
                    .frame(height: barHeight)
            }
            .cornerRadius(8)
        }
    }
}

#Preview {
    DecibelMeterView(decibels: 100.0, color: .accent)
        .frame(width: 50, height: 300)
        .padding()
}
