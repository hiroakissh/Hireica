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
                if self.realTimeRecorder.isRecorderFlag {
                    self.realTimeRecorder.stopRecording()
                } else {
                    self.realTimeRecorder.startRecording()
                }
            }, label: {
                Text(self.realTimeRecorder.isRecorderFlag ? "Stop Recording" : "Start Recording")
                    .padding()
                    .foregroundColor(.white)
                    .background(self.realTimeRecorder.isRecorderFlag ? Color.red : Color.green)
                    .cornerRadius(8)
            })

            if !realTimeRecorder.audioData.isEmpty && realTimeRecorder.audioData[0].power != 1e-6 {
                RecorderPlotView(audioData: realTimeRecorder.audioData)
            } else if !realTimeRecorder.audioData.isEmpty  {
                Text(realTimeRecorder.audioData[0].power != 1e-6 ? "" : "Retry Tap")
                    .onAppear {
                        realTimeRecorder.stopRecording()
                    }
            }
        }
        .padding()
    }
}
