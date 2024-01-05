//
//  RealTimeRecoderView.swift
//  Hireica
//
//  Created by HiroakiSaito on 2023/12/19.
//

import SwiftUI
import Combine
import AVFoundation

struct AudioRecorderView: View {
    @ObservedObject var realTimeRecorder: RealTimeAudioRecorder

    var body: some View {
        VStack {
            Button(action: {
                print("TODO: \(self.realTimeRecorder.testAudioRecorder.prepareToRecord())")
                if self.realTimeRecorder.testAudioRecorder.isRecording {
                    self.realTimeRecorder.stopRecording()
                } else {
                    self.realTimeRecorder.startRecording()
                }
            }, label: {
                Text(self.realTimeRecorder.testAudioRecorder.isRecording ? "Stop Recording" : "Start Recording")
                    .padding()
                    .foregroundColor(.white)
                    .background(self.realTimeRecorder.testAudioRecorder.isRecording ? Color.red : Color.green)
                    .cornerRadius(8)
            })

            if !realTimeRecorder.audioData.isEmpty {
                RecorderPlotView(audioData: realTimeRecorder.audioData)
            }
        }
        .padding()
    }
}
