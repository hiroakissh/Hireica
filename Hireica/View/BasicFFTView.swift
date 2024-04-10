//
//  BasicFFTView.swift
//  Hireica
//
//  Created by HiroakiSaito on 2024/04/04.
//

import SwiftUI

struct BasicFFTView: View {
    @State var frequency = 100.0

    var body: some View {
        VStack {
            Text("Sin Wave")
                .font(.title)
                .padding()
            TextField("周波数を入力してください", value: $frequency, format: .number)
                .multilineTextAlignment(.center)
                .textFieldStyle(.roundedBorder)
                .padding()
            SinWaveView(frequency: frequency)
                .frame(height: 200)
                .padding()
        }
    }
}

struct SinWaveView: View {
    var frequency: Double
    init(frequency: Double) {
        self.frequency = frequency
    }
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let width = geometry.size.width
                let height = geometry.size.height

                let frequencyRad = frequency * 2 * .pi

                print("width: \(width)")
                print("height: \(height)")

                path.move(to: CGPoint(x: 0, y: height / 2))
                for x in stride(from: 0, to: frequencyRad, by: .pi / 180 ) {
                    let angle = x
                    let y = (sin(angle) * 50) + (height / 2)
                    print("angle: \(angle)")
                    print("y: \(y)")
                    print("sin: \(sin(.pi/2.0))")
                    path.addLine(to: CGPoint(x: x, y: y))
                }
            }
            .stroke(.blue, lineWidth: 2)
        }
    }
}

// Sin波をFFT解析する

// Sin波の周期を変動できるようにする

// FFT結果の表示

#Preview {
    BasicFFTView()
}
