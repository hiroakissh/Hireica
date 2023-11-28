//
//  CaptureCameraViewModel.swift
//  Hireica
//
//  Created by HiroakiSaito on 2023/11/28.
//

import Foundation
import AVFoundation
import UIKit

class CaptureCameraViewModel: NSObject, ObservableObject {
    @Published private(set) var imageData: UIImage?
    var previewView: UIView = UIView()

    private var session: AVCaptureSession?
    private var photoOutput: AVCapturePhotoOutput?
    private var captureSetting: AVCapturePhotoSettings?

    func launchCamera() {
        if let session = self.session {
            Task {
//            DispatchQueue.global(qos: .background).async {
                session.startRunning()
            }
            return
        }

        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back), 
                let deviceInput = try? AVCaptureDeviceInput(device: device) else {
            return
        }

        let photoOutput = AVCapturePhotoOutput()
        let session = AVCaptureSession()

        switch UIDevice.current.userInterfaceIdiom {
        case .phone:
            session.sessionPreset = .high
        default:
            session.sessionPreset = .photo
        }

        session.addInput(deviceInput)
        session.addOutput(photoOutput)

        let videoPreviewLayer = AVCaptureVideoPreviewLayer(session: session)
        videoPreviewLayer.videoGravity = .resizeAspectFill
        videoPreviewLayer.connection?.videoOrientation = .portrait
        videoPreviewLayer.frame = previewView.bounds

        Task {
//        DispatchQueue.global(qos: .background).async {
            session.startRunning()
        }

        self.photoOutput = photoOutput
        self.session = session

        previewView.layer.insertSublayer(videoPreviewLayer, at: 0)
    }

    func closeCamera() {
        session?.stopRunning()
    }

    func capture() {
        Task { @MainActor in
            let captureSetting = AVCapturePhotoSettings()
            captureSetting.flashMode = .off
            photoOutput?.capturePhoto(with: captureSetting, delegate: self)
            self.captureSetting = captureSetting
        }
    }
}

extension CaptureCameraViewModel: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            print(error.localizedDescription)
            return
        }

        guard let fileData = photo.fileDataRepresentation(),
              let image = UIImage(data: fileData) else {
            return
        }
        imageData = image
    }
}
