//
//  RealTimeRecoderView.swift
//  Hireica
//
//  Created by HiroakiSaito on 2023/12/19.
//

import SwiftUI
import Combine
import AVFoundation
import Charts
import MetalKit

class TestAudioRecorder: NSObject, ObservableObject  {
    var testAudioRecorder: AVAudioRecorder!
    @Published var audioData: [Float] = []

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
        audioData.removeAll()
        try? AVAudioSession.sharedInstance().setCategory(.record, mode: .default)
        try? AVAudioSession.sharedInstance().setActive(true)
        testAudioRecorder.record()
        startMetering()
    }

    func stopRecording() {
        testAudioRecorder.stop()
    }

    private func startMetering() {
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            self.testAudioRecorder.updateMeters()
            let averagePower = self.testAudioRecorder.averagePower(forChannel: 0)
            let normalizedPower = pow(10, (0.05 * averagePower))
            self.audioData.append(normalizedPower)
        }
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
            }) {
                Text(self.testRecorder.testAudioRecorder.isRecording ? "Stop Recording" : "Start Recording")
                    .padding()
                    .foregroundColor(.white)
                    .background(self.testRecorder.testAudioRecorder.isRecording ? Color.red : Color.green)
                    .cornerRadius(8)
            }

            if !testRecorder.audioData.isEmpty {
                PlotView(data: testRecorder.audioData)
                    .frame(height: 200)
            }
        }
        .padding()
    }
}

struct PlotView: View {
    let data: [Float]

    var body: some View {
        GeometryReader { geometry in
            Path { path in
                for (index, value) in data.enumerated() {
                    print(data)
                    let x = geometry.size.width * CGFloat(index) / CGFloat(data.count - 1)
                    let y = geometry.size.height * (1 - CGFloat(value))
                    print("x: ",x)
                    print("y: ",y)
                    if index == 0 {
                        path.move(to: CGPoint(x: x, y: y))
                    } else {
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                }
            }
            .stroke(Color.blue, lineWidth: 2)
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
}
