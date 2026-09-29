import Foundation

/// ゲーム全体の状態(仕様書§11)
struct GameState {
    var player: Player
    var hasKey: Bool = false
    /// 探索済みのマス(オートマップ用)
    var explored: Set<GridPos>
    /// 画面に表示するメッセージ
    var message: String = ""

    init(start: GridPos, direction: Direction) {
        self.player = Player(position: start, direction: direction)
        self.explored = [start]   // Sは開始時に探索済み
    }
}
