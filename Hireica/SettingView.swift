//
//  SettingView.swift
//  Hireica
//
//  Created by HiroakiSaito on 2023/12/18.
//

import SwiftUI

//struct SettingView: View {
//
//    @Binding var selectedFs: Int
//    let FsOptions = [1024, 2048, 4096, 8192]
//
//    @Binding var text_overlapRatio: String
//    @Binding var text_dbref: String
//
//    var body: some View {
//        VStack{
//            // 設定画面
//            GroupBox(label: Text("Frame size").font(.headline)) {
//                Picker("Select Fs", selection: $selectedFs) {
//                    ForEach(FsOptions, id: \.self) {
//                        Text("\($0)")
//                    }
//                }
//                .pickerStyle(MenuPickerStyle())
//            }
//            .padding(.bottom, 10)
//
//            GroupBox(label: Text("Overlap ratio[%]").font(.headline)) {
//                TextField("Enter Overlap ratio[%].", text:$text_overlapRatio)
//                    .keyboardType(.default)
//                    .textFieldStyle(RoundedBorderTextFieldStyle())
//            }
//            .padding(.bottom, 10)
//
//            GroupBox(label: Text("dBref").font(.headline)) {
//                TextField("Enter dBref.", text:$text_dbref)
//                    .keyboardType(.default)
//                    .textFieldStyle(RoundedBorderTextFieldStyle())
//            }
//        }
//        .padding()
//        .tabItem{
//            Image(systemName: "gear")
//            Text("Setting")
//        }
//    }
//}

//#Preview {
//    @State var testSelectedFs1: Int = 1048
//    @State var test_text_overlapRatio1: String = "test"
//    @State var test_text_dbref1: String = "test"
//
//    SettingView(
//        selectedFs: $testSelectedFs1,
//        text_overlapRatio: $test_text_overlapRatio1,
//        text_dbref: $test_text_dbref1
//    )
//}
