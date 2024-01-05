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
                y: .value("Power [dB]", 300 * (1.0 - data.power)) // geometry.size.height * (1 - CGFloat(value))
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
    RecorderPlotView()
}
