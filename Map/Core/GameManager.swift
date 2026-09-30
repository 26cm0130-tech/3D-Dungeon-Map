import Foundation
import Combine

/// ゲーム進行の管理。UIはここを通してのみ状態を変更する(UI仕様書§8)
final class GameManager: ObservableObject {
    /// 現在の面(マップ、鍵の要否などの定義)
    let stage: Stage
    @Published private(set) var state: GameState

    /// 現在の面のマップ
    var map: MapData { stage.map }

    init(stage: Stage) {
        self.stage = stage
        self.state = GameState(
            start: stage.map.startPosition,
            direction: stage.map.initialDirection,
            requiresKey: stage.requiresKey
        )
    }

    // MARK: 操作

    func turnLeft() {
        var newState = state
        newState.player.direction = newState.player.direction.turnedLeft
        state = newState
    }

    func turnRight() {
        var newState = state
        newState.player.direction = newState.player.direction.turnedRight
        state = newState
    }

    func moveForward() {
        let next = state.player.position.moved(state.player.direction)
        let cell = map.cell(at: next)
        if cell.isWall { return }

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
        event?.onEnter(state: &newState)
        state = newState
    }
}
