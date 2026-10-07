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
        var initialState = GameState(
            start: stage.map.startPosition,
            direction: stage.map.initialDirection,
            requiresKey: stage.requiresKey
        )
        initialState.traps = TrapPlacement.make(in: stage.map)
        self.state = initialState
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
        var stateForMove = state
        if stateForMove.hasMovementHindrance {
            guard stateForMove.isWaitingForSecondForwardPress else {
                stateForMove.isWaitingForSecondForwardPress = true
                stateForMove.message = "進行を妨害された"
                state = stateForMove
                return
            }
            stateForMove.isWaitingForSecondForwardPress = false
        }

        let next = stateForMove.player.position.moved(stateForMove.player.direction)
        let cell = map.cell(at: next)
        if cell.isWall {
            state = stateForMove
            return
        }

        // マスごとの特殊処理(T・K・G)は Events に任せる
        let event: (any TileEvent)?
        if let trapKind = stateForMove.traps[next] {
            let destinations = map.normalFloorPositions.filter { stateForMove.traps[$0] == nil }
            event = TrapEvent(kind: trapKind, warpDestinations: destinations)
        } else {
            event = TileEvents.event(for: cell)
        }
        if let reason = event?.blockReason(state: stateForMove) {
            var newState = stateForMove
            newState.message = reason
            state = newState
            return
        }

        var newState = stateForMove
        newState.player.position = next
        newState.explored.insert(next)
        newState.message = ""
        event?.onEnter(state: &newState)
        state = newState

        // クリア状態になったら、画面を切り替えるために知らせる
        if newState.isCleared {
            onCleared?()
        }
    }
}
