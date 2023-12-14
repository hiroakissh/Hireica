////
////  fourierTransformModel.swift
////  Hireica
////
////  Created by HiroakiSaito on 2023/12/12.
////
//
//import UIKit
//import Accelerate
//
//class FourierTransformModel {
//
//    func transRate() -> CIImage {
//        let originalImage = UIImage(named: "test")!
//
//        guard let ciImage = CIImage(image: originalImage) else {
//            fatalError("Failed to convert UIImage to CIImage.")
//        }
//
//        return ciImage
//    }
//
//    func applyFourierTransform(to image: CIImage) -> CIImage? {
//        // CIImageをPixelBufferに変換
//        var pixelBuffer: CVPixelBuffer?
//        // 指定されたサイズとピクセル形式単一ピクセルバッファーを作成します。
//        CVPixelBufferCreate(
//            kCFAllocatorSystemDefault, // バッファプールの作成に使用するアロケータ
//            Int(image.extent.width), // ピクセルバッファの高さ
//            Int(image.extent.height), // ピクセルバッファの高さ
//            kCVPixelFormatType_32BGRA, // ４文字コードで識別されるピクセル形式
//            nil,
//            &pixelBuffer // 出力では新しく作成されたピクセルバッファー // &を使用するとポインターとして使える
//        )
//
//        let context = CIContext() // 画像処理結果をレンダリングし、画像分析を実行するための評価コンテキスト
//        context.render(image, to: pixelBuffer!) // 画像をピクセルバッファーにレンダリング
//
//        var transform = vImage_Buffer() // 画像のピクセルデータ、サイズ、行ストライドを保存する画像バッファー
//        vImageBuffer_InitWithCVPixelBuffer(&transform, pixelBuffer!, kCVPixelFormatType_32BGRA as! CVPixelBuffer) // CoreVideo ピクセルバッファの内容のコピーを使用してバッファを初期化
//
//        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0)) // ピクセルバッファのベースアドレスをロック
//        let baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer!)
//        let bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer!)
//        let width = CVPixelBufferGetWidth(pixelBuffer!)
//        let height = CVPixelBufferGetHeight(pixelBuffer!)
//
//        // vDSPで2Dフーリエ変換を実行
//        var real = [Float](repeating: 0.0, count: width * height)
//        var imag = [Float](repeating: 0.0, count: width * height)
//
//        // インターリーブされた複素数ベクトルの内容をC分割された複素数ベクトルにコピー単制度
//        vDSP_ctoz(
//            UnsafePointer<__vDSPComplex>(baseAddress!.assumingMemoryBound(to: __vDSPComplex.self)), // 単精度インターリーブ複素入力ベクトル
//            2, // 偶数でなければなりません
//            $__vDSPComplex(&real, &image), // 単精度分割複素数出力ベクトル
//            1, // ストライド
//            vDSP_Length(width * height) // 処理する要素の数
//        )
//
//        var splitComplex = DSPSplitComplex(realp: &real, imagp: &imag) // 実数部と虚数部が別々の配列に格納された単精度複素数ベクトルを表す構造体
//        let log2n = vDSP_Length(log2(Float(width * height))) // ベクトルの大豆とベクトル内の要素のインデックスを表す符号なし整数値
//        let fftSetup = vDSP_create_fftsetup(log2n, FFTradix(FFT_RADIX2))! // 単精度FFT関数の事前計算されたデータを含むセットアップ構造体を返す // FFTRadix: FFT分解の基数
//
//        vDSP_fft2d_zip(fftSetup, &splitComplex, 1, 0, log2n, log2n, FFTDirection(FFT_FORWARD)) // 2次元順方向or逆方向のインプレース単精度複素数FFT計算 // FFTDirection 順方向 or 逆方向かの指定
//
//        vDSP_destroy_fftsetup(fftSetup)
//
//        // 完了したら、結果をPixelBufferに戻す
//        // 分割された複素数ベクトルの内容をZ単精度インターリーブされた複素数ベクトルにコピー
//        vDSP_ztoc(
//            &splitComplex,
//            1,
//            UnsafeMutablePointer<__vDSPComplex>(baseAddress!.assumingMemoryBound(to: __vDSPComplex.self)),
//            2,
//            vDSP_Length(width * height)
//        )
//
//        // メモリの解放
//        CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
//
//        let resultImage = CIImage(CVPixelBuffer: pixelBuffer!)
//        return resultImage
//    }
//}
