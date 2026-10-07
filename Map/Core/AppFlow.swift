import Foundation
import Combine
import AVFoundation

private final class AudioPlayerCompletionDelegate: NSObject, AVAudioPlayerDelegate {
    private let completion: () -> Void
    private var hasCompleted = false

    init(completion: @escaping () -> Void) {
        self.completion = completion
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        finish()
    }

    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        finish()
    }

    private func finish() {
        guard !hasCompleted else { return }
        hasCompleted = true
        completion()
    }
}

/// アプリ全体の画面の流れ(スタート画面 → プレイ画面 → クリア表示 → スタート画面)を管理する。
/// UIは、ここが持つ状態に従って画面を切り替えて表示するだけにする(仕様書§13.1、UI仕様書§8)
final class AppFlow: ObservableObject {
    /// 画面の状態
    enum Screen {
        case start      // スタート画面
        case playing    // プレイ画面
        case cleared    // クリア表示(プレイ画面の上に重ねて表示する)
    }

    @Published private(set) var screen: Screen = .start

    /// 現在のプレイ(スタート画面のときは nil)
    @Published private(set) var game: GameManager?

    private var doorOpenAudioPlayer: AVAudioPlayer?
    private var doorOpenCompletionDelegate: AudioPlayerCompletionDelegate?
    private var isPlayingDoorOpenSequence = false

    /// 面を選んで、プレイを開始する。
    /// 毎回、新しいゲームを作るので、前回のプレイの状態は引き継がない(仕様書§13.2)
    func startGame(stage: Stage) {
        doorOpenAudioPlayer?.stop()
        doorOpenAudioPlayer = nil
        doorOpenCompletionDelegate = nil
        isPlayingDoorOpenSequence = false
        let newGame = GameManager(stage: stage)
        // ドアの音が終わってからクリア表示に切り替える
        newGame.onCleared = { [weak self] in
            self?.playDoorOpenThenShowClear()
        }
        game = newGame
        screen = .playing
    }

    /// スタート画面に戻る。現在のプレイの状態は破棄する
    func returnToStart() {
        doorOpenAudioPlayer?.stop()
        doorOpenAudioPlayer = nil
        doorOpenCompletionDelegate = nil
        isPlayingDoorOpenSequence = false
        game = nil
        screen = .start
    }

    /// ドアを開ける音を最後まで再生してからクリア画面へ進む。
    private func playDoorOpenThenShowClear() {
        guard !isPlayingDoorOpenSequence else { return }
        isPlayingDoorOpenSequence = true
        let gameAtClear = game

        guard let url = Bundle.main.url(forResource: "ドアを開ける1", withExtension: "mp3"),
              let player = try? AVAudioPlayer(contentsOf: url) else {
            isPlayingDoorOpenSequence = false
            screen = .cleared
            return
        }

        let completionDelegate = AudioPlayerCompletionDelegate { [weak self] in
            DispatchQueue.main.async {
                guard let self else { return }
                self.doorOpenAudioPlayer = nil
                self.doorOpenCompletionDelegate = nil
                self.isPlayingDoorOpenSequence = false
                guard self.game === gameAtClear, case .playing = self.screen else { return }
                self.screen = .cleared
            }
        }
        doorOpenAudioPlayer = player
        doorOpenCompletionDelegate = completionDelegate
        player.delegate = completionDelegate
        player.prepareToPlay()
        if !player.play() {
            doorOpenAudioPlayer = nil
            doorOpenCompletionDelegate = nil
            isPlayingDoorOpenSequence = false
            screen = .cleared
        }
    }
}
