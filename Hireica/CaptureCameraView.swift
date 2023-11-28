//
//  ContentView.swift
//  Hireica
//
//  Created by HiroakiSaito on 2023/11/27.
//

import SwiftUI

protocol CaptureCameraViewDelegate {
    func passImage(image: UIImage)
}

struct CaptureCameraView: View {
    @Environment(\.isPresented) var presentation
    @Environment(\.dismiss) var dismiss
    @ObservedObject private(set) var viewModel = CaptureCameraViewModel()

    var delegate: CaptureCameraViewDelegate?

    var body: some View {
        ZStack {
            CapturePreView(captureCameraViewModel: viewModel)
            VStack {
                Spacer()
                Button {
                    viewModel.capture()
                } label: {
                    Image(systemName: "circle.inset.filled")
                        .resizable(resizingMode: .stretch)
                        .foregroundColor(.white)
                }
                .frame(width: 60, height: 60)
            }
        }
        .onChange(of: viewModel.imageData, { _, imageData in
            guard let imageData = imageData else { return }
            delegate?.passImage(image: imageData)
            dismiss()
        })
    }
}

struct CapturePreView: UIViewRepresentable {
    
    private var captureCameraViewModel: CaptureCameraViewModel

    init(captureCameraViewModel: CaptureCameraViewModel) {
        self.captureCameraViewModel = captureCameraViewModel
    }

    public func makeUIView(context: Context) -> some UIView {
        let cameraView = captureCameraViewModel.previewView
        cameraView.frame = UIScreen.main.bounds
        captureCameraViewModel.launchCamera()
        return cameraView
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {
    }
}

#Preview {
    CaptureCameraView()
}
