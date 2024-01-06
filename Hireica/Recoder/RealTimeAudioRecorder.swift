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
    @Published var isRecorderFlag = false

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
        do {
            try AVAudioSession.sharedInstance().setCategory(.record, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch(let error) {
            print("Audio Start Error: \(error.localizedDescription)")
        }
        testAudioRecorder.record()
        isRecorderFlag = true
        startMetering()
    }

    private func startMetering() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            self.testAudioRecorder.updateMeters()
            let averagePower = self.testAudioRecorder.averagePower(forChannel: 0)
            let normalizedPower = pow(10, (0.05 * averagePower))
            self.audioData.append(.init(time: ceil(Float(self.audioData.endIndex))/10, power: normalizedPower))
            print("time1: \(ceil(Float(self.audioData.endIndex))/10)")
            print("time2: \(Date())")
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
            isRecorderFlag = false
        } else {
            print("Recording failed.")
        }
    }

    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        print("Audio Error: \(error.debugDescription)")
    }
}
