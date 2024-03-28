//
//  moveToSoundView.swift
//  Hireica
//
//  Created by HiroakiSaito on 2024/03/27.
//

import AVFoundation
import Accelerate
import SwiftUI
import Foundation
import Charts

struct moveToSoundView: View {
    var body: some View {
        VStack {
            Text("FFT Result (Magnitude Spectrum) - First Segment")
            Button {
                print(fftResults[0])
                print(fftResults[fftResults.count - 1])
            } label: {
                Text("Test")
            }
//            FFTPlotView(fftResult: fftResults[0])

            Text("FFT Result (Magnitude Spectrum) - Last Segment")
//            FFTPlotView(fftResult: fftResults[fftResults.count - 1])

            Button("Process Video") {
                processVideo()
            }
            .padding()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

//struct FFTPlotView: View {
//    let fftResult: [Float]
//
//    var body: some View {
//        LineView(data: fftResult.map { Double($0) }, title: "", legend: "", style: ChartStyle(backgroundColor: Color.white, accentColor: Color.blue, gradientColor: GradientColor(start: .blue, end: .green), textColor: Color.black, legendTextColor: Color.gray, dropShadowColor: .gray))
//            .frame(height: 300)
//            .padding()
//    }
//}

// 動画ファイルパス
let videoPath = "/private/var/mobile/Containers/Data/Application/BAD64C7F-4669-4059-AFD9-816BC8A3622E/Documents/mov_hts-samp003.mp4"

// サンプリング周波数
let sampleRate: Float = 44100

// FFTの結果を格納する配列
var fftResults: [[Float]] = []

// 動画ファイルからフレームをキャプチャしてFFTを実行
func processVideo() {
//    guard let url = URL(string: videoPath) else {
//        print("Invalid video URL")
//        return
//    }
    let url = URL(fileURLWithPath: videoPath)
    let asset = AVAsset(url: url)
    let reader = try! AVAssetReader(asset: asset)

    let videoTrack = asset.tracks(withMediaType: .video).first!
    let outputSettings: [String: Any] = [
        kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA
    ]
    let readerOutput = AVAssetReaderTrackOutput(track: videoTrack, outputSettings: outputSettings)

    reader.add(readerOutput)
    reader.startReading()

    var frameCount = 0

    while let sampleBuffer = readerOutput.copyNextSampleBuffer() {
        let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)!
        let ciImage = CIImage(cvImageBuffer: imageBuffer)

        let context = CIContext(options: nil)
        var cgImage = context.createCGImage(ciImage, from: ciImage.extent)!

        var frame = vImage_Buffer()
//        vImageBuffer_InitWithCGImage(&frame, (vImage_CGImageFormat(cgImage: cgImage))!, .none, [UInt32(kCGImageAlphaNoneSkipFirst)], .zero)

        // 画像処理とFFTを実行
        processFrame(frame)

        frameCount += 1

        // 必要なフレーム数だけ処理したら終了
        if frameCount >= 100 {
            break
        }
    }
}

// 画像処理とFFTを実行
func processFrame(_ frame: vImage_Buffer) {
    // 画像の中央を縦に5分割して、各部分ごとにFFT解析
    let frameWidth = Int(frame.width)
    let frameHeight = Int(frame.height)
    let frameData = frame.data.bindMemory(to: UInt8.self, capacity: frameWidth * frameHeight * 4)

    for i in 0..<5 {
        let startRow = Int(i * frameHeight / 5)
        let endRow = Int((i + 1) * frameHeight / 5)

        var columnToExtract: [Float] = []

        for y in startRow..<endRow {
            let pixelIndex = y * frameWidth * 4 + frameWidth * 2
            let pixelValue = Float(frameData[pixelIndex])
            columnToExtract.append(pixelValue)
        }

        // FFTを実行
        let fftResult = performFFT(columnToExtract)
        fftResults.append(fftResult)
    }
}

// FFTを実行
func performFFT(_ input: [Float]) -> [Float] {
    var realPart = [Float](input)
    var imaginaryPart = [Float](repeating: 0.0, count: input.count)
    var splitComplex = DSPSplitComplex(realp: &realPart, imagp: &imaginaryPart)

    let log2n = vDSP_Length(log2(Float(input.count)))
    let fftSetup = vDSP_create_fftsetup(log2n, FFTRadix(kFFTRadix2))!

    vDSP_fft_zip(fftSetup, &splitComplex, 1, log2n, FFTDirection(FFT_FORWARD))

    let magnitudeSquared = UnsafeMutablePointer<Float>.allocate(capacity: input.count)
    defer { magnitudeSquared.deallocate() }
    vDSP_zvmags(&splitComplex, 1, magnitudeSquared, 1, vDSP_Length(input.count))

    var magnitude = [Float](repeating: 0.0, count: input.count)
    vvsqrtf(&magnitude, magnitudeSquared, [Int32(input.count)])

    vDSP_destroy_fftsetup(fftSetup)

    return magnitude
}

#Preview {
    moveToSoundView()
}
