import Foundation

/// 面(ステージ)の定義(仕様書§5.5)
struct Stage {
    /// 面の名前(スタート画面などで使う)
    let title: String
    /// 面のマップ(初期方向を含む)
    let map: MapData
    /// Gでクリアするのに鍵が必要か(仕様書§3.3)
    let requiresKey: Bool
}

/// 各面のマップ定義(仕様書 付録A)
/// # = 壁, . = 床, S = スタート, G = ゴール, K = 鍵の宝箱
/// トラップは面の開始時に通常床へランダム配置する
enum Stages {
    /// スタート画面に並べる面の一覧(表示順)
    static let all: [Stage] = [tutorial, honban]

    /// チュートリアル(付録A.1)。S から G までの練習用。鍵は不要。
    /// 列は Excel の B〜F、行は 5〜14 に対応
    static let tutorial: Stage = make(
        title: "チュートリアル",
        rows: [
            "####.",  // 5
            "####.",  // 6
            "####.",  // 7
            "####.",  // 8
            ".....",  // 9
            "##.#.",  // 10
            "##G#.",  // 11
            "####.",  // 12
            "####.",  // 13
            "####S",  // 14
        ],
        initialDirection: .north,
        requiresKey: false
    )

    /// 本番(付録A.2)。鍵が必要。
    /// 列は Excel の I〜P、行は 2〜14 に対応
    static let honban: Stage = make(
        title: "本番",
        rows: [
            "##.#####",  // 2
            "##.#####",  // 3
            "##.#####",  // 4
            "##.#####",  // 5
            "S.......",  // 6
            "##....##",  // 7
            "##....##",  // 8
            "##....##",  // 9
            "##.##.##",  // 10
            "##.#K.##",  // 11
            "G..#####",  // 12
            "##.#####",  // 13
            "##.#####",  // 14
        ],
        initialDirection: .east,
        requiresKey: true
    )

    /// マップ定義の文字列から、面を作る。S が無い定義は、開発中のミスなので停止する
    private static func make(
        title: String,
        rows: [String],
        initialDirection: Direction,
        requiresKey: Bool
    ) -> Stage {
        guard let map = MapLoader.load(rows: rows, initialDirection: initialDirection) else {
            fatalError("\(title)のマップ定義に S がありません")
        }
        return Stage(title: title, map: map, requiresKey: requiresKey)
    }
}
