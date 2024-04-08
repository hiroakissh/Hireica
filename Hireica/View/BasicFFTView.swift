//
//  BasicFFTView.swift
//  Hireica
//
//  Created by HiroakiSaito on 2024/04/04.
//

import SwiftUI

struct BasicFFTView: View {
    var body: some View {
        VStack {
            Text("Sin Wave")
                .font(.title)
                .padding()
            SinWaveView()
                .frame(height: 200)
                .padding()
        }
    }
}

struct SinWaveView: View {
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let width = geometry.size.width
                let height = geometry.size.height

                print("width: \(width)")
                print("height: \(height)")

                path.move(to: CGPoint(x: 0, y: height / 2))
                for x in stride(from: 0, to: width, by: 10) {
                    let angle = (Double(x) / width) * 2 * .pi
                    let y = (sin(angle) * 50) + (height / 2)
                    print("angle: \(angle)")
                    print("y: \(y)")
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
