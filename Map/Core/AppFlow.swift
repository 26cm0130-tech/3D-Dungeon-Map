import Foundation
import Combine

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

    /// 面を選んで、プレイを開始する。
    /// 毎回、新しいゲームを作るので、前回のプレイの状態は引き継がない(仕様書§13.2)
    func startGame(stage: Stage) {
        let newGame = GameManager(stage: stage)
        // クリアしたら、クリア表示に切り替える
        newGame.onCleared = { [weak self] in
            self?.screen = .cleared
        }
        game = newGame
        screen = .playing
    }

    /// スタート画面に戻る。現在のプレイの状態は破棄する
    func returnToStart() {
        game = nil
        screen = .start
    }
}
