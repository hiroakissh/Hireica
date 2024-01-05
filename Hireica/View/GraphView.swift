//
//  GraphView.swift
//  Hireica
//
//  Created by HiroakiSaito on 2023/12/18.
//

import SwiftUI
import Charts

struct GraphView: View {

    @Binding var dataFreq: [PointsData]

    var body: some View {
        VStack{
            // 周波数分析の画面

            Text("Amplitude[dBA]")
                .font(.caption)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.all, 1)
            Chart {
                // データ構造からx, y値を取得して散布図プロット

                ForEach(dataFreq) { shape in
                    // 折れ線グラフをプロット

                    LineMark(
                        x: .value("x", shape.xValue),
                        y: .value("y", shape.yValue)
                    )
                }
            }

            Text("Frequency [Hz]")
                .font(.caption)
                .padding(.bottom, 10)

        }
        .padding()
        .tabItem{
            Image(systemName: "chart.bar.xaxis")
            Text("Freq.")
        }
    }
}

//#Preview {
//    @State var testDataFreq: [PointsData] = []
//    GraphView(dataFreq: $testDataFreq)
//}
