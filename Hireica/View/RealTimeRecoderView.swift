//
//  RealTimeRecoderView.swift
//  Hireica
//
//  Created by HiroakiSaito on 2023/12/19.
//

import SwiftUI
import Combine
import AVFoundation

class TestAudioRecorder: NSObject, ObservableObject  {
    var testAudioRecorder: AVAudioRecorder!
    @Published var audioData: [AudioData] = []

    override init() {
        super.init()
        setupRecorder()
    }

    private func setupRecorder() {
        let audioFilename = getDocumentsDirectory().appendingPathComponent("recording.wav")
        let settings = [
            AVFormatIDKey: Int(kAudioFormatLinearPCM),
            AVSampleRateKey: 44100.0,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.max.rawValue
        ] as [String : Any]

        do {
            testAudioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            testAudioRecorder.delegate = self
            testAudioRecorder.isMeteringEnabled = true
            testAudioRecorder.prepareToRecord()
        } catch {
            print("Error setting up audio recorder: \(error.localizedDescription)")
        }
    }

    func startRecording() {
//        audioData.removeAll()
        try? AVAudioSession.sharedInstance().setCategory(.record, mode: .default)
        try? AVAudioSession.sharedInstance().setActive(true)
        testAudioRecorder.record()
        startMetering()
    }

    private func startMetering() {
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            self.testAudioRecorder.updateMeters()
            let averagePower = self.testAudioRecorder.averagePower(forChannel: 0)
            let normalizedPower = pow(10, (0.05 * averagePower))
            self.audioData.append(.init(time: Float(self.audioData.endIndex) * 0.1, power: normalizedPower))
            print("add power: \(normalizedPower)")
            print("averagePower: \(averagePower)")
            print("output: \(150.0 * (1.0 - CGFloat(normalizedPower)))")
            print("")
        }
    }


    func stopRecording() {
        testAudioRecorder.stop()
    }

    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}

extension TestAudioRecorder: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            print("Recording finished successfully.")
        } else {
            print("Recording failed.")
        }
    }
}

struct AudioRecorderView: View {
    @ObservedObject var testRecorder: TestAudioRecorder

    var body: some View {
        VStack {
            Button(action: {
                if self.testRecorder.testAudioRecorder.isRecording {
                    self.testRecorder.stopRecording()
                } else {
                    self.testRecorder.startRecording()
                }
            }, label: {
                Text(self.testRecorder.testAudioRecorder.isRecording ? "Stop Recording" : "Start Recording")
                    .padding()
                    .foregroundColor(.white)
                    .background(self.testRecorder.testAudioRecorder.isRecording ? Color.red : Color.green)
                    .cornerRadius(8)
            })

            if !testRecorder.audioData.isEmpty {
                RecorderPlotView(audioData: testRecorder.audioData)
            }
        }
        .padding()
    }
}

struct PlotView: View {
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

//@main
//struct RealTimeAudioRecordingApp: App {
//    @StateObject private var recorder = TestAudioRecorder()
//
//    var body: some Scene {
//        WindowGroup {
//            AudioRecorderView(testRecorder: recorder)
//        }
//    }
//}
//}
