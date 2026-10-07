import Foundation

/// ゲーム全体の状態(仕様書§11)
struct GameState {
    var player: Player
    var hasKey: Bool = false
    /// この面でクリアするのに、鍵が必要か(仕様書§3.3)。面の定義から設定する
    let requiresKey: Bool
    /// クリア済みか(仕様書§11 クリア状態)
    var isCleared: Bool = false
    /// 探索済みのマス(オートマップ用)
    var explored: Set<GridPos>
    /// 面の開始時に配置したトラップ
    var traps: [GridPos: TrapKind] = [:]
    /// 進行妨害トラップが有効か
    var hasMovementHindrance: Bool = false
    /// 進行妨害中の、前進ボタン1回目の入力を受け取った状態か
    var isWaitingForSecondForwardPress: Bool = false
    /// 画面に表示するメッセージ
    var message: String = ""

    init(start: GridPos, direction: Direction, requiresKey: Bool) {
        self.player = Player(position: start, direction: direction)
        self.requiresKey = requiresKey
        self.explored = [start]   // Sは開始時に探索済み
    }
}
