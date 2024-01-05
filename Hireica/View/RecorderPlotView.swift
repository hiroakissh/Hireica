//
//  RecorderPlotView.swift
//  Hireica
//
//  Created by HiroakiSaito on 2024/01/05.
//

import SwiftUI
import Charts

struct RecorderPlotView: View {
    let audioData: [AudioData]

    var body: some View {
        Chart(audioData) { data in
            LineMark(
                x: .value("time [s]", data.time),
                y: .value("Power [dB]", data.power) // geometry.size.height * (1 - CGFloat(value))
            )
            .lineStyle(StrokeStyle(lineWidth: 1.5))
            .interpolationMethod(.linear)
        }
        .animation(.default, value: 1.0)
        .chartXScale(
            domain: ((audioData.last?.time ?? 0.0) - 0.9) ... (audioData.last?.time ?? 1.0),
            range: .plotDimension(
                startPadding: CGFloat(audioData.first?.time ?? 0.0),
                endPadding: CGFloat(audioData.last?.time ?? 1.0)
            ),
            type: .linear
        )
        .frame(height: 300)
        .padding()
    }
}

#Preview {
    @State var previewData: [AudioData] = [
        .init(time: 0.1, power: 100.0),
        .init(time: 0.2, power: 200.0),
        .init(time: 0.3, power: 300.0),
        .init(time: 0.4, power: 400.0),
        .init(time: 0.5, power: 500.0),
        .init(time: 0.6, power: 400.0),
        .init(time: 0.7, power: 300.0),
        .init(time: 0.8, power: 200.0),
        .init(time: 0.9, power: 100.0),
        .init(time: 1.0, power: 0.0),
    ]
    
    return RecorderPlotView(audioData: previewData)
}
