//
//  DSP.swift
//  Hireica
//
//  Created by HiroakiSaito on 2023/12/15.
//

import Foundation
import Accelerate

class DSP {

    // 複素数型の構造体を定義
    struct Complex {
        // re: 実部, im: 虚部
        var re: Float
        var im: Float

        // Complex + Complexの場合の演算処理
        static func +(lhs: Complex, rhs: Complex) -> Complex {
            return Complex(re: lhs.re + rhs.re, im: lhs.im + rhs.im)
        }

        // Complex * Complexの場合の演算処理
        static func *(lhs: Complex, rhs: Complex) -> Complex {
            return Complex(re: lhs.re * rhs.re - lhs.im * rhs.im, im: lhs.re * rhs.im + lhs.im * rhs.re)
        }

        // Complex * Floatの場合の演算処理
        static func *(lhs: Complex, rhs: Float) -> Complex {
            return Complex(re: lhs.re * rhs, im: lhs.im * rhs)
        }
    }

    static func isPowerOfTwo(_ n: Int) -> Bool {
        // 入力が2のべき乗であるかどうかを判断する関数
        return (n != 0) && ((n & (n - 1)) == 0)
    }

    static func fft(_ x: [Float]) -> [Complex] {
        // 入力データの長さが2のべき乗であることを確認
        let log2n = vDSP_Length(log2(Double(x.count)).rounded(.up))
        let n = 1 << log2n

        // 入力データを複素数形式に変換
        var real = x
        var imaginary = [Float](repeating: 0.0, count: n)
        var splitComplexinput = DSPSplitComplex(realp: &real, imagp: &imaginary)

        // FFTの設定
        let fftSetUp = vDSP_create_fftsetup(log2n, FFTRadix(kFFTRadix2))!

        // FFTを適用
        vDSP_fft_zip(
            fftSetUp,
            &splitComplexinput,
            1,
            log2n,
            FFTDirection(kFFTDirection_Forward)
        )

        // 複素数の出力結果を作成
        var output = [Complex]()
        for i in 0..<n {
            output.append(Complex(re: splitComplexinput.realp[i], im: splitComplexinput.imagp[i]))
        }

        // FFT設定の解放
        vDSP_destroy_fftsetup(fftSetUp)

        return output
    }

    static func ov(data: [Float], sampleRate: Float, Fs: Int, overlap: Float) -> ([[Float]], Int) {
        // オーバラップ処理

        let Ts = Float(data.count) / sampleRate
        let Fc = Float(Fs) / sampleRate
        let x_ol = Float(Fs) * (1 - (overlap/100))
        let N_ave = Int((Ts - (Fc * (overlap/100))) / (Fc * (1-(overlap/100))))

        var array = [[Float]]()

        for i in 0..<N_ave {
            let ps = Int(x_ol * Float(i))
            array.append(Array(data[ps..<ps+Fs]))
        }

        return (array, N_ave)
    }

    static func hanningWindow(N: Int) -> ([Float], Float) {
        // ハニング窓
        let w = (0..<N).map { 0.5 - 0.5 * cos(2.0 * .pi * Float($0) / Float(N - 1)) }

        // ウィンドウ補正係数
        let acf = 1 / (w.reduce(0, +) / Float(N))

        return (w, acf)
    }

    static func averagedFFT(y: [Float], sampleRate: Float, Fs: Int, overlapRatio: Float) -> ([Float], [Float]) {
        let dt: Float = 1.0 / sampleRate

        // 時間波形をオーバラップ処理
        let (overlapData, _) = ov(data: y, sampleRate: sampleRate, Fs: Fs, overlap: overlapRatio)

        // 平均化FFT
        var fftResults: [[Complex]] = []
        let fftSize = isPowerOfTwo(overlapData[0].count) ? overlapData[0].count : 1 << Int(ceil(log2(Double(overlapData[0].count))))
        print("Frame size=", Fs)
        print("Overlap ratio=", Float(overlapRatio))
        print("Num. of frames=", overlapData.count)

        // ハニンウィンドウ
        let hanning_window = hanningWindow(N: fftSize)
        let window = hanning_window.0
        let acf = hanning_window.1
        print("acf.han=", acf)

        for frame in overlapData {
            // 窓関数を適用してFFT
            let fftResult = fft(zip(frame, window).map(*))
            fftResults.append(fftResult)
        }

        // 平均化FFT
        var averageAmplitude: [Float] = Array(repeating: 0.0, count: fftResults[0].count)
        let N = Float(fftResults[0].count)

        // 直流成分の平均化
        for i in 0..<fftResults.count {
            averageAmplitude[0] += pow(fftResults[i][0].re, 2)
        }
        averageAmplitude[0] /= (N * Float(fftResults.count))

        // 変動成分の平均化
        for i in 1..<averageAmplitude.count {
            for j in 0..<fftResults.count {
                let amplitude = sqrt(pow(fftResults[j][i].re, 2) + pow(fftResults[j][i].im, 2))
                averageAmplitude[i] += pow(amplitude, 2)
            }
            averageAmplitude[i] /= (2 * N * Float(fftResults.count))
        }
        averageAmplitude = averageAmplitude.map { sqrt($0) }

        // 周波数軸の計算
        let freq = Array(stride(from: 0.0, to: 1.0 / (2.0 * dt), by: 1.0 / (dt * Float(overlapData[0].count))))

        return (averageAmplitude, freq)
    }
}
