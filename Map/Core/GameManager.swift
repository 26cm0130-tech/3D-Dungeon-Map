import Foundation
import Combine

/// ゲーム進行の管理。UIはここを通してのみ状態を変更する(UI仕様書§8)
final class GameManager: ObservableObject {
    /// 現在の面(マップ、鍵の要否などの定義)
    let stage: Stage
    @Published private(set) var state: GameState

    /// 現在の面のマップ
    var map: MapData { stage.map }

    /// クリアしたときに呼ばれる(画面の切り替えに使う)
    var onCleared: (() -> Void)?

    init(stage: Stage) {
        self.stage = stage
        self.state = GameState(
            start: stage.map.startPosition,
            direction: stage.map.initialDirection,
            requiresKey: stage.requiresKey,
            isStepByStepTutorial: stage.isStepByStepTutorial
        )
    }

    // MARK: 操作

    func turnLeft() {
        guard !state.isCleared else { return }
        var newState = state
        newState.player.direction = newState.player.direction.turnedLeft
        newState.message = ""
        newState.recordTutorialAction(.turn)
        state = newState
    }

    func turnRight() {
        guard !state.isCleared else { return }
        var newState = state
        newState.player.direction = newState.player.direction.turnedRight
        newState.message = ""
        newState.recordTutorialAction(.turn)
        state = newState
    }

    func moveForward() {
        guard !state.isCleared else { return }
        let next = state.player.position.moved(state.player.direction)
        let cell = map.cell(at: next)
        if cell.isWall {
            var newState = state
            newState.message = "前方は壁です。左右に向きを変えて進路を探しましょう。"
            state = newState
            return
        }

        // マスごとの特殊処理(T・K・G)は Events に任せる
        let event = TileEvents.event(for: cell)
        if let reason = event?.blockReason(state: state) {
            var newState = state
            newState.message = reason
            state = newState
            return
        }

        var newState = state
        newState.player.position = next
        newState.explored.insert(next)
        newState.message = ""
        newState.recordTutorialAction(.moveForward)
        event?.onEnter(state: &newState)
        state = newState

        // クリア状態になったら、画面を切り替えるために知らせる
        if newState.isCleared {
            onCleared?()
        }
    }
}
