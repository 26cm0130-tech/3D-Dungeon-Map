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
        AudioPlayback.logDecodeError(for: "ドアを開ける1", error: error)
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
    /// 前回のランダムステージseed。タイトル画面から同じ迷宮を再生成できる。
    @Published private(set) var lastRandomSeed: UInt64?

    private var titleBackgroundAudioPlayer: AVAudioPlayer?
    private var titleBackgroundAudioErrorDelegate: AudioPlaybackErrorDelegate?
    private var stageBackgroundAudioPlayer: AVAudioPlayer?
    private var stageBackgroundAudioErrorDelegate: AudioPlaybackErrorDelegate?
    private var doorOpenAudioPlayer: AVAudioPlayer?
    private var doorOpenCompletionDelegate: AudioPlayerCompletionDelegate?
    private var isPlayingDoorOpenSequence = false

    init() {
        AudioPlayback.configureForDeviceSettings()
        playTitleBackgroundMusic()
    }

    /// 面を選んで、プレイを開始する。
    /// 毎回、新しいゲームを作るので、前回のプレイの状態は引き継がない(仕様書§13.2)
    func startGame(stage: Stage) {
        stopTitleBackgroundMusic()
        stopStageBackgroundMusic()
        doorOpenAudioPlayer?.stop()
        doorOpenAudioPlayer = nil
        doorOpenCompletionDelegate = nil
        isPlayingDoorOpenSequence = false
        let newGame = GameManager(stage: stage)
        lastRandomSeed = stage.seed
        // ドアの音が終わってからクリア表示に切り替える
        newGame.onCleared = { [weak self] in
            self?.playDoorOpenThenShowClear()
        }
        game = newGame
        screen = .playing
        playStageBackgroundMusic()
    }

    /// 新しいseedでランダムステージを開始する。
    func startRandomGame() {
        let seed = UInt64.random(in: UInt64.min...UInt64.max)
        startGame(stage: Stages.random(seed: seed))
    }

    /// 前回のseedを使って同じ迷宮を再生成する。
    func replayRandomGame(seed: UInt64) {
        startGame(stage: Stages.random(seed: seed))
    }

    /// スタート画面に戻る。現在のプレイの状態は破棄する
    func returnToStart() {
        stopStageBackgroundMusic()
        doorOpenAudioPlayer?.stop()
        doorOpenAudioPlayer = nil
        doorOpenCompletionDelegate = nil
        isPlayingDoorOpenSequence = false
        game = nil
        screen = .start
        playTitleBackgroundMusic()
    }

    /// ドアを開ける音を最後まで再生してからクリア画面へ進む。
    private func playDoorOpenThenShowClear() {
        guard !isPlayingDoorOpenSequence else { return }
        isPlayingDoorOpenSequence = true
        stopStageBackgroundMusic()
        let gameAtClear = game

        guard let player = AudioPlayback.makePlayer(named: "ドアを開ける1") else {
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
        if !AudioPlayback.play(player, named: "ドアを開ける1") {
            doorOpenAudioPlayer = nil
            doorOpenCompletionDelegate = nil
            isPlayingDoorOpenSequence = false
            screen = .cleared
        }
    }

    /// ステージ中のBGMをループ再生する。
    private func playStageBackgroundMusic() {
        guard let player = AudioPlayback.makePlayer(named: "3dmap") else { return }

        player.numberOfLoops = -1
        let errorDelegate = AudioPlaybackErrorDelegate(resourceName: "3dmap")
        player.delegate = errorDelegate
        guard AudioPlayback.play(player, named: "3dmap") else { return }
        stageBackgroundAudioPlayer = player
        stageBackgroundAudioErrorDelegate = errorDelegate
    }

    /// タイトル画面のBGMをループ再生する。
    private func playTitleBackgroundMusic() {
        guard titleBackgroundAudioPlayer?.isPlaying != true,
              let player = AudioPlayback.makePlayer(named: "Where_the_Stone_Eyes_Watch") else { return }

        player.numberOfLoops = -1
        let errorDelegate = AudioPlaybackErrorDelegate(resourceName: "Where_the_Stone_Eyes_Watch")
        player.delegate = errorDelegate
        guard AudioPlayback.play(player, named: "Where_the_Stone_Eyes_Watch") else { return }
        titleBackgroundAudioPlayer = player
        titleBackgroundAudioErrorDelegate = errorDelegate
    }

    /// タイトル画面を離れるときにタイトルBGMを止める。
    private func stopTitleBackgroundMusic() {
        titleBackgroundAudioPlayer?.stop()
        titleBackgroundAudioPlayer = nil
        titleBackgroundAudioErrorDelegate = nil
    }

    /// ステージを離れるときはBGMを止める。
    private func stopStageBackgroundMusic() {
        stageBackgroundAudioPlayer?.stop()
        stageBackgroundAudioPlayer = nil
        stageBackgroundAudioErrorDelegate = nil
    }
}
