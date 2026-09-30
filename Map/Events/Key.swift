import Foundation

/// K:鍵・宝箱(C担当)。取得すると hasKey が true になる
struct KeyEvent: TileEvent {
    func onEnter(state: inout GameState) {
        state.hasKey = true
        state.message = "鍵を手に入れた"
    }
}

/// G:ゴール(C担当)。鍵が必要な面では、鍵がないと入れない
struct GoalEvent: TileEvent {
    func blockReason(state: GameState) -> String? {
        // 鍵が必要な面(本番)で、鍵を持っていないときだけ入れない
        if state.requiresKey && !state.hasKey {
            return "扉に鍵がかかっている"
        }
        return nil
    }

    func onEnter(state: inout GameState) {
        state.isCleared = true      // クリア状態にする(仕様書§3・§11)
        state.message = "ゴール!"
    }
}
