import Foundation

/// 各面のマップ定義(仕様書 付録A)
/// # = 壁, . = 床, S = スタート, G = ゴール, T = トラップ, K = 鍵の宝箱
enum Stages {
    /// 本番(付録A.2)。列は Excel の I〜P、行は 2〜14 に対応
    static let honban: MapData = {
        let rows = [
            "##.#####",  // 2
            "##.#####",  // 3
            "##.#####",  // 4
            "##.#####",  // 5
            "S.......",  // 6
            "##....##",  // 7
            "##...T##",  // 8
            "##....##",  // 9
            "##.##.##",  // 10
            "##.#K.##",  // 11
            "G..#####",  // 12
            "##.#####",  // 13
            "##.#####",  // 14
        ]
        guard let map = MapLoader.load(rows: rows, initialDirection: .east) else {
            fatalError("本番のマップ定義に S がありません")
        }
        return map
    }()
}
