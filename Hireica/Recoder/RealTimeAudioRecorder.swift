//
//  RealTimeAudioRecorder.swift
//  Hireica
//
//  Created by HiroakiSaito on 2024/01/05.
//

import Foundation
import AVFoundation

class RealTimeAudioRecorder: NSObject, ObservableObject  {

    @Published var audioData: [AudioData] = []

    var testAudioRecorder: AVAudioRecorder!
    var timer: Timer?

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

    private func startMetering() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            self.testAudioRecorder.updateMeters()
            let averagePower = self.testAudioRecorder.averagePower(forChannel: 0)
            let normalizedPower = pow(10, (0.05 * averagePower))
            self.audioData.append(.init(time: ceil(Float(self.audioData.endIndex))/10, power: normalizedPower))
        }
    }

    func stopRecording() {
        testAudioRecorder.stop()
        timer?.invalidate()
    }

    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}

extension RealTimeAudioRecorder: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            print("Recording finished successfully.")
        } else {
            print("Recording failed.")
        }
    }
}
