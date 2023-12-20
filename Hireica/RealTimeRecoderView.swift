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
//        GeometryReader { geometry in
//            Path { path in
//                for (index, value) in data.enumerated() {
//                    let x = geometry.size.width * CGFloat(index) / CGFloat(data.count - 1)
//                    let y = geometry.size.height * (1 - CGFloat(value))
//                    if index == 0 {
//                        path.move(to: CGPoint(x: x, y: y))
//                    } else {
//                        path.addLine(to: CGPoint(x: x, y: y))
//                    }
//                }
//            }
//            .stroke(Color.blue, lineWidth: 2)
//        }

//        Chart {
//            // データ構造からx, y値を取得して散布図プロット
//
//            ForEach($data) { shape in
//                // 折れ線グラフをプロット
//
//                LineMark(
//                    x: .value("x", shape.xValue),
//                    y: .value("y", shape.yValue)
//                )
//            }
//        }
        @StateObject var recorder = TestAudioRecorder()
        // Metal使った書き方
        VStack {
            AudioRecorderView(testRecorder: recorder)
            MetalPlotView(data: recorder.audioData)
                .frame(height: 200)
        }
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


// Metal使った書き方
struct MetalPlotView: UIViewRepresentable {
    var data: [Float]

    func makeUIView(context: Context) -> MTKView {
        let metalView = MTKView()
        metalView.device = MTLCreateSystemDefaultDevice()
        metalView.isPaused = true
        metalView.enableSetNeedsDisplay = true
        metalView.contentMode = .scaleAspectFit
        metalView.preferredFramesPerSecond = 60
        metalView.delegate = context.coordinator

        return metalView
    }

    func updateUIView(_ uiView: MTKView, context: Context) {
        context.coordinator.data = data
        uiView.draw()
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, MTKViewDelegate {
        var data: [Float] = []
        var plotView: MetalPlotView

        init(_ plotView: MetalPlotView) {
            self.plotView = plotView
        }

        func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
            // Do nothing
        }

        func draw(in view: MTKView) {
            if let commandBuffer = MetalManager.shared.commandQueue.makeCommandBuffer(),
               let drawable = view.currentDrawable,
               let renderPassDescriptor = view.currentRenderPassDescriptor {
                let commandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
                commandEncoder?.setRenderPipelineState(MetalManager.shared.pipelineState)

                // Draw the waveform using data
                var vertices: [Float] = []
                for (index, value) in data.enumerated() {
                    let x = -1.0 + Float(index) / Float(data.count - 1) * 2.0
                    let y = value * 2.0
                    vertices.append(contentsOf: [x, y, 0.0])
                }

                commandEncoder?.setVertexBytes(vertices, length: vertices.count * MemoryLayout<Float>.size, index: 0)
                commandEncoder?.drawPrimitives(type: .line, vertexStart: 0, vertexCount: data.count)

                commandEncoder?.endEncoding()
                commandBuffer.present(drawable)
                commandBuffer.commit()
            }
        }
    }
}


class MetalManager {
    static let shared = MetalManager()

    let device: MTLDevice
    let commandQueue: MTLCommandQueue
    let pipelineState: MTLRenderPipelineState

    private init() {
        guard let device = MTLCreateSystemDefaultDevice() else {
            fatalError("Metal is not supported on this device")
        }
        self.device = device
        self.commandQueue = device.makeCommandQueue()!

        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = MetalManager.loadShader("vertex_main")
        pipelineDescriptor.fragmentFunction = MetalManager.loadShader("fragment_main")
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm

        do {
            self.pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        } catch {
            fatalError("Failed to create pipeline state: \(error)")
        }
    }

    private static func loadShader(_ name: String) -> MTLFunction {
        let bundle = Bundle.main
        guard let path = bundle.path(forResource: name, ofType: "metal") else {
            fatalError("Failed to load shader")
        }

        do {
            let source = try String(contentsOfFile: path, encoding: .utf8)
            return try MetalManager().device.makeLibrary(source: source, options: nil).device.makeLibrary(source: source, options: nil).makeFunction(name: "main")!
        } catch {
            fatalError("Failed to load shader: \(error)")
        }
    }
}
