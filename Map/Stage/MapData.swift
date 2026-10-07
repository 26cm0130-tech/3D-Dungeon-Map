import Foundation

/// 1つの面のマップ。マップ外は壁として扱う
struct MapData {
    let cells: [[MapCell]]
    let startPosition: GridPos
    let initialDirection: Direction

    var rows: Int { cells.count }
    var cols: Int { cells.map { $0.count }.max() ?? 0 }

    /// 壁以外のマス数。ランダムトラップの配置数を決めるときに使う
    var passableCellCount: Int {
        cells.flatMap { $0 }.filter { !$0.isWall }.count
    }

    /// トラップを置ける、特殊地点ではない通常床の位置
    var normalFloorPositions: [GridPos] {
        cells.enumerated().flatMap { y, row in
            row.enumerated().compactMap { x, cell in
                cell == .floor ? GridPos(x: x, y: y) : nil
            }
        }
    }

    func cell(x: Int, y: Int) -> MapCell {
        guard y >= 0, y < cells.count else { return .wall }
        guard x >= 0, x < cells[y].count else { return .wall }
        return cells[y][x]
    }

    func cell(at pos: GridPos) -> MapCell {
        cell(x: pos.x, y: pos.y)
    }

    func isWall(x: Int, y: Int) -> Bool {
        cell(x: x, y: y).isWall
    }
}
