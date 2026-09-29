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
        state.player.direction = state.player.direction.turnedLeft
    }

    func turnRight() {
        state.player.direction = state.player.direction.turnedRight
    }

    func moveForward() {
        let next = state.player.position.moved(state.player.direction)
        let cell = map.cell(at: next)
        if cell.isWall { return }

        // マスごとの特殊処理(T・K・G)は Events に任せる
        let event = TileEvents.event(for: cell)
        if let reason = event?.blockReason(state: state) {
            state.message = reason
            return
        }

        state.player.position = next
        state.explored.insert(next)      // 新しいマスへ到達 → 探索済みにする
        state.message = ""
        event?.onEnter(state: &state)
    }

    // MARK: 3D描画用

    /// 視点相対(前へd、右へi)のマスが壁か
    func isWallRelative(_ d: Int, _ i: Int) -> Bool {
        let forward = state.player.direction
        let right = forward.turnedRight
        let p = state.player.position
        return map.isWall(
            x: p.x + forward.dx * d + right.dx * i,
            y: p.y + forward.dy * d + right.dy * i
        )
    }
}
