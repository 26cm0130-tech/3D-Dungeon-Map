import Foundation
import Combine

/// ゲーム進行の管理。UIはここを通してのみ状態を変更する(UI仕様書§8)
final class GameManager: ObservableObject {
    let map: MapData
    @Published private(set) var state: GameState

    init(map: MapData) {
        self.map = map
        self.state = GameState(start: map.startPosition, direction: map.initialDirection)
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
