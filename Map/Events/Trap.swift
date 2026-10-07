import Foundation

/// トラップの種類
enum TrapKind: CaseIterable, Hashable {
    case warp
    case movementHindrance

    /// オートマップに表示する記号
    var mapSymbol: String { "T" }
}

/// 面の開始時にトラップをランダム配置する
enum TrapPlacement {
    static func make(in map: MapData) -> [GridPos: TrapKind] {
        let totalCount = Int(ceil(Double(map.passableCellCount) * 0.1))
        let positions = Array(map.normalFloorPositions.shuffled().prefix(totalCount))
        let warpCount = (positions.count + 1) / 2

        var traps: [GridPos: TrapKind] = [:]
        for (index, position) in positions.enumerated() {
            traps[position] = index < warpCount ? .warp : .movementHindrance
        }
        return traps
    }
}

/// 種類ごとのトラップ処理
struct TrapEvent: TileEvent {
    let kind: TrapKind
    let warpDestinations: [GridPos]

    func onEnter(state: inout GameState) {
        switch kind {
        case .warp:
            guard let destination = warpDestinations.randomElement() else { return }
            state.player.position = destination
            state.explored.insert(destination)
            state.message = "ワープした"
        case .movementHindrance:
            state.hasMovementHindrance = true
            state.isWaitingForSecondForwardPress = false
            state.message = "進行を妨害された"
        }
    }
}
