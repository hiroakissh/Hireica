//
//  Audio.swift
//  Hireica
//
//  Created by HiroakiSaito on 2023/12/13.
//

// サンプル： https://watlab-blog.com/2023/08/12/swift-averaged-fft/

import Foundation
import AVFoundation

class Recorder: NSObject, ObservableObject {
    var audioRecorder: AVAudioRecorder?

    // 録音の状態を管理するプロパティ
    @Published var isRecording = false
    // 録音データの変数を宣言
    @Published var waveformData: [Float] = []
    // サンプリングレート
    var sampleRate: Float = 12800

    // 再生用のAVAudioPlayerを宣言
    private var player: AVAudioPlayer?
    // audioFileURLをプロパティとして宣言(クラス全体でアクセスするため：再生用)
    private var audioFileURL: URL?

    // カスタムクラスのコンストラクタを定義
    override init() {
        super.init()
        setUpAudioRecorder()
    }

    private func setUpAudioRecorder() {

        let recordingSession = AVAudioSession.sharedInstance()

        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)

            // 辞書型で設定値を変更
            let settings: [String: Any] = [
                AVFormatIDKey: Int(kAudioFormatLinearPCM), // AV識別子 リニアPCMコーデック
                AVSampleRateKey: sampleRate, // サンプルレート
                AVNumberOfChannelsKey: 1, // チャンネル数
                AVLinearPCMBitDepthKey: 16, // リニアPCMオーディオ形式のビット深度
                AVLinearPCMIsBigEndianKey: false, //　データ形式がビックエンディアンとリトルエンディアンに違い
                AVLinearPCMIsFloatKey: false, // オーディオ形式が浮動小数点か固定小数点の判定
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue // オーディオ品質の列挙からの整数
            ]

            // wavファイルにパスを設定する .wavはリアルタイムに書き込まれる
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            audioFileURL = documentsPath.appendingPathComponent("recording.wav")

            // audioFileURLのnilチェック
            guard let url = audioFileURL else { return }
            
            do {
                audioRecorder = try AVAudioRecorder(url: url, settings: settings)
                // audioRecorderがnilでない場合のみバッファ割当てや初期化、設定する
                audioRecorder?.prepareToRecord()
            } catch {
                print("Error setting up audio recorder: \(error)")
            }

            audioRecorder = try AVAudioRecorder(url: url, settings: settings)

            // audioRecoderがnilでない場合のみバッファ割当てや初期化、設定をする
            audioRecorder?.prepareToRecord()

        } catch {
            print("Error setting up audio recorder: \(error)")
        }
    }

    func startRecording() {
        audioRecorder?.record()
        isRecording = false

    }

    func stopRecording() {
        audioRecorder?.stop()
        isRecording = false

        // 録音停止時にwavファイルのパスをコンソールに表示する
        if let audioFileURL = audioRecorder?.url {
            print(audioFileURL)

            getWaveFormData { waveformData in
                print("wave length=", waveformData.count)
                self.waveformData = waveformData
            }
        }
    }

    func getWaveFormData(completion: @escaping ([Float]) -> Void) {
        guard let audioFileURL = audioRecorder?.url else { return }

        do {
            let audioFile = try AVAudioFile(forReading: audioFileURL)
            let audioFormat = AVAudioFormat(
                standardFormatWithSampleRate: audioFile.processingFormat.sampleRate,
                channels: audioFile.processingFormat.channelCount
            )

            let audioBuffer = AVAudioPCMBuffer(pcmFormat: audioFormat!, frameCapacity: UInt32(audioFile.length))
            try audioFile.read(into: audioBuffer!)

            let floatArray = Array(UnsafeBufferPointer(start: audioBuffer!.floatChannelData![0], count: Int(audioBuffer!.frameLength)))

            completion(floatArray)
        } catch {
            print("Error getting waveform data: \(error)")
        }
    }

    func playRecording() {
        guard let url = audioFileURL else { return }

        do {
            try? AVAudioSession.sharedInstance().setCategory(.playAndRecord, options: .defaultToSpeaker)
            try? AVAudioSession.sharedInstance().overrideOutputAudioPort(.speaker)
            try? AVAudioSession.sharedInstance().setActive(true)

            player = try AVAudioPlayer(contentsOf: url)
            player?.prepareToPlay()
            player?.play()
        } catch {
            print("Error playing audio: \(error)")
        }
    }
}

// 点群データの構造体
struct PointsData: Identifiable {
    var xValue: Float
    var yValue: Float
    var id = UUID()
}
