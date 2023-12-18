//
//  RecView.swift
//  Hireica
//
//  Created by HiroakiSaito on 2023/12/18.
//

import SwiftUI
import Charts

struct RecView: View {
    @StateObject private var recorder = Recorder()
    private var dt: Float { Float(1.0 / recorder.sampleRate) }
    @State private var isDisplayingData = false

    @State private var data: [PointsData] = []
    @State private var x: [Float] = []
    @State private var y: [Float] = []

    @Binding var dataFreq: [PointsData]
    @State private var x_freq: [Float] = []
    @State private var y_freq: [Float] = []
    
    @Binding var text_overlapRatio: String
    @Binding var text_dbref: String

    @State private var Fs: Int = 2048
    
    @Binding var selectedFs: Int

    var body: some View {
        VStack{
            // 録音と再生の画面


            Text("Amplitude[Lin.]")
                .font(.caption)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.all, 1)

            Chart {
                // データ構造からx, y値を取得して散布図プロット

                ForEach(data) { shape in
                    // 折れ線グラフをプロット

                    LineMark(
                        x: .value("x", shape.xValue),
                        y: .value("y", shape.yValue)
                    )
                }
            }


            .padding(.all, 10)
            Text("Time [s]")
                .font(.caption)
                .padding(.all, 1)

            HStack{
                if recorder.isRecording {
                    // 録音している時

                    Button(action: {
                        // 停止ボタンが押されたらデータをChartsに表示させる

                        // 録音の実行
                        print("Stop")
                        recorder.stopRecording()


                        // データ取得
                        y = recorder.waveformData

                        // 時間波形
                        let samplePoints = Float(y.count)
                        x = Array(stride(from: 0.0, to: samplePoints * dt, by: dt))

                        // 時間波形プロットデータの追加
                        data.removeAll()
                        dataFreq.removeAll()
                        data = zip(x, y).map { PointsData(xValue: $0, yValue: $1) }
                        isDisplayingData = false

                        // FFT用パラメータの読み込み
                        guard let overlapRatio = Float(text_overlapRatio), let dbref = Float(text_dbref) else {
                            print("Invalid input")
                            isDisplayingData = false
                            return
                        }

                        // バックグラウンドでデータ処理を行う
                        DispatchQueue.global(qos: .userInitiated).async {


                            // 平均化FFT
                            let (averageAmplitude, freq) = DSP.averagedFFT(y: y, sampleRate: Float(recorder.sampleRate), Fs: Fs, overlapRatio: overlapRatio)

                            // dB変換
                            let dBAmplitudes = DSP.db(x: averageAmplitude, dBref: dbref)

                            // Aスケール聴感補正
                            let correctedAmplitudes = DSP.aweightings(frequencies: freq, dB: dBAmplitudes).enumerated().map { dBAmplitudes[$0.offset] + $0.element }

                            // メインと同期させる
                            DispatchQueue.main.async {
                                // FFT波形のプロット
                                dataFreq = zip(freq, correctedAmplitudes).map { PointsData(xValue: $0, yValue: $1) }
                                isDisplayingData = false
                            }
                        }
                    }) {
                        Text("Stop Recording")
                            .padding()
                            .background(Color.red)
                            .foregroundColor(Color.white)
                            .cornerRadius(10)
                            .padding(.all, 10)
                    }
                } else {
                    // 録音していない時

                    Button(action: {
                        print("Start")
                        isDisplayingData = true
                        recorder.startRecording()

                    }) {
                        Text("Start Recording")
                            .padding()
                            .background(Color.green)
                            .foregroundColor(Color.white)
                            .cornerRadius(10)
                            .padding(.all, 10)
                    }
                    .opacity(isDisplayingData ? 0.5 : 1.0)
                    .disabled(isDisplayingData)
                }
                Button("Play"){
                    // 音声を再生する

                    recorder.playRecording()

                }
                .padding()
                .background(Color.blue)
                .foregroundColor(Color.white)
                .cornerRadius(10)
                .padding(.all, 10)
            }
        }
        .padding()
        .tabItem{
            Image(systemName: "mic.circle.fill")
            Text("REC")
        }
    }
}

//#Preview {
//
//    @State var testDataFreq2: [PointsData] = []
//    @State var testSelectedFs2: Int = 1048
//    @State var test_text_overlapRatio2: String = "test"
//    @State var test_text_dbref2: String = "test"
//
//    RecView(
//        dataFreq: $testDataFreq2,
//        text_overlapRatio: $test_text_overlapRatio2,
//        text_dbref: $test_text_dbref2,
//        selectedFs: $testSelectedFs2
//    )
//}
