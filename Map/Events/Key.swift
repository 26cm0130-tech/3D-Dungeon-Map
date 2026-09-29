import Foundation

/// K:鍵・宝箱(C担当)。取得すると hasKey が true になる
struct KeyEvent: TileEvent {
    func onEnter(state: inout GameState) {
        state.hasKey = true
        state.message = "鍵を手に入れた"
    }
}

/// G:ゴール(C担当)。鍵がないと入れない
struct GoalEvent: TileEvent {
    func blockReason(state: GameState) -> String? {
        state.hasKey ? nil : "扉に鍵がかかっている"
    }

    func onEnter(state: inout GameState) {
        state.message = "ゴール!"
    }
}
