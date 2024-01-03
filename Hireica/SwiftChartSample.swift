//
//  SwiftChartSample.swift
//  Hireica
//
//  Created by HiroakiSaito on 2024/01/03.
//

import SwiftUI
import Charts

struct SwiftChartSample: View {

    @State var data: [SampleData] = [
        .init(time: 0.1, power: 5),
        .init(time: 0.2, power: 1),
        .init(time: 0.3, power: 9),
        .init(time: 0.4, power: 0),
        .init(time: 0.5, power: 15),
        .init(time: 0.6, power: 4),
        .init(time: 0.7, power: 2),
        .init(time: 0.8, power: 7),
        .init(time: 0.9, power: 9),
        .init(time: 1.0, power: 1)
    ]

    var body: some View {
        Chart(data) { data in
            LineMark(
                x: .value("time [s]", data.time),
                y: .value("Power [dB]", data.power)
            )
            .lineStyle(StrokeStyle(lineWidth: 1.5))
            .interpolationMethod(.linear)
        }
        .frame(height: 300)
        .padding()
    }
}

struct SampleData: Identifiable {
    var time: Double
    var power: Double
    var id = UUID()
}

#Preview {
    SwiftChartSample()
}
