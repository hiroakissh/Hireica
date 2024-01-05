//
//  ContentView.swift
//  Hireica
//
//  Created by HiroakiSaito on 2023/11/27.
//

import SwiftUI
import Charts

struct ContentView: View {
//    @ObservedObject private var recorder = RealTimeAudioRecorder()
    @StateObject private var recorder = RealTimeAudioRecorder()

    var body: some View {
        AudioRecorderView(realTimeRecorder: recorder)
    }

//    init() {
//        UITabBar.appearance().backgroundColor = UIColor(
//            red: 0.1,
//            green: 0.1,
//            blue: 0.1,
//            alpha: 0.2
//        )
//    }
//
    @State private var selectedFs = 2048

    @State var dataFreq: [PointsData] = []

    @State private var overlapRatio: Float = 50
    @State private var dbref: Float = 2e-5

    @State private var text_overlapRatio: String = "50"
    @State private var text_dbref: String = "2e-5"
//
//    var body: some View {
//        // UIとイベント
//        TabView() {
//            RecView(
//                dataFreq: $dataFreq,
//                text_overlapRatio: $text_overlapRatio,
//                text_dbref: $text_dbref,
//                selectedFs: $selectedFs
//            )
//            GraphView(dataFreq: $dataFreq)
//            SettingView(
//                selectedFs: $selectedFs,
//                text_overlapRatio: $text_overlapRatio,
//                text_dbref: $text_dbref
//            )
//        }
//        .accentColor(.blue)
//        .edgesIgnoringSafeArea(.top)
//    }
}

#Preview {
    ContentView()
}
