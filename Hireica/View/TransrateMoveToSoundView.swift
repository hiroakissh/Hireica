//
//  TransrateMoveToSoundView.swift
//  Hireica
//
//  Created by HiroakiSaito on 2024/03/25.
//

import SwiftUI
import AVKit

struct TransrateMoveToSoundView: View {
    @State private var selectedVideo: URL?
    @State private var isShowingVideoPicker = false

    var body: some View {
        VStack {
            if let videoURL = selectedVideo {
                VideoPlayer(player: AVPlayer(url: videoURL))
                    .frame(height: 300)
                    .padding()
            } else {
                Text("動画を選択してください")
                    .padding()
            }

            Button("動画を選択") {
                isShowingVideoPicker.toggle()
            }
            .padding()
            .sheet(isPresented: $isShowingVideoPicker, content: {
                VideoPickerView(selectedVideo: $selectedVideo)
            })
        }
    }
}

struct VideoPickerView: UIViewControllerRepresentable {
    @Binding var selectedVideo: URL?

    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(documentTypes: ["public.moview"], in: .open)
        picker.allowsMultipleSelection = false
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {  }

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let parent: VideoPickerView

        init(parent: VideoPickerView) {
            self.parent = parent
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            if let url = urls.first {
                parent.selectedVideo = url
            }
        }
    }
}

#Preview {
    TransrateMoveToSoundView()
}
