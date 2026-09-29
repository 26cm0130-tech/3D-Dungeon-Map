import SwiftUI

// ============================================================
// ContentView
// ------------------------------------------------------------
// ウィザードリィ風のマップ探索ゲーム本体です。
// ・Sからスタート
// ・前進 / 左旋回 / 右旋回で操作
// ・前方だけでなく、左・右の壁と通路を判定
// ・前方4マスまでを3Dワイヤーフレーム風に描画
// ・Gに到達すると「探索成功」
// ============================================================

struct ContentView: View {

    // ========================================================
    // MARK: - マップデータ
    // ========================================================
    // 0 = 壁
    // 1 = 通路
    // 2 = スタート
    // 3 = ゴール
    // ========================================================
    private let map: [[Int]] = [
        [0, 0, 0, 0, 0, 0, 0],
        [0, 0, 3, 1, 1, 0, 0],
        [0, 0, 0, 0, 1, 0, 0],
        [0, 0, 0, 0, 1, 0, 0],
        [0, 0, 0, 0, 1, 0, 0],
        [0, 0, 0, 0, 1, 0, 0],
        [0, 0, 0, 0, 2, 0, 0]
    ]

    // ========================================================
    // MARK: - プレイヤー状態
    // ========================================================
    @State private var playerRow = 6
    @State private var playerCol = 4
    @State private var direction: Direction = .north
    @State private var message = "探索を開始します。"
    @State private var isClear = false

    // ========================================================
    // MARK: - 方向
    // ========================================================
    enum Direction: Int {
        case north = 0
        case east = 1
        case south = 2
        case west = 3

        var name: String {
            switch self {
            case .north: return "北"
            case .east: return "東"
            case .south: return "南"
            case .west: return "西"
            }
        }

        var symbol: String {
            switch self {
            case .north: return "▲"
            case .east: return "▶"
            case .south: return "▼"
            case .west: return "◀"
            }
        }
    }

    // ========================================================
    // MARK: - 画面
    // ========================================================
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            VStack(spacing: 10) {
                Text("WIZARDRY CLONE")
                    .font(.system(size: 24, weight: .bold, design: .monospaced))
                    .foregroundStyle(.white)
                    .padding(.top, 12)

                // 前方4マスまでを3Dワイヤーフレームとして表示します。
                Dungeon3DView(
                    map: map,
                    playerRow: playerRow,
                    playerCol: playerCol,
                    direction: direction,
                    viewDepth: 4
                )
                .frame(height: 290)
                .padding(.horizontal, 12)

                Text("向き：\(direction.name)")
                    .font(.system(size: 14, design: .monospaced))
                    .foregroundStyle(.gray)

                Text(message)
                    .font(.system(size: 16, weight: .medium, design: .monospaced))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .frame(height: 30)

                controlPanel
                miniMap

                Spacer()
            }

            if isClear {
                clearOverlay
            }
        }
        .preferredColorScheme(.dark)
    }

    // ========================================================
    // MARK: - 操作ボタン
    // ========================================================
    private var controlPanel: some View {
        VStack(spacing: 8) {
            Button {
                moveForward()
            } label: {
                VStack(spacing: 2) {
                    Image(systemName: "arrow.up")
                    Text("前進")
                        .font(.system(size: 12, design: .monospaced))
                }
                .frame(width: 105, height: 55)
                .background(Color.blue)
                .foregroundStyle(.black)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }

            HStack(spacing: 12) {
                Button {
                    turnLeft()
                } label: {
                    VStack(spacing: 2) {
                        Image(systemName: "arrow.counterclockwise")
                        Text("左旋回")
                            .font(.system(size: 12, design: .monospaced))
                    }
                    .frame(width: 105, height: 55)
                    .background(Color.gray)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }

                Button {
                    turnRight()
                } label: {
                    VStack(spacing: 2) {
                        Image(systemName: "arrow.clockwise")
                        Text("右旋回")
                            .font(.system(size: 12, design: .monospaced))
                    }
                    .frame(width: 105, height: 55)
                    .background(Color.gray)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
        }
    }

    // ========================================================
    // MARK: - 前進
    // ========================================================
    private func moveForward() {
        let next = position(fromRow: playerRow, fromCol: playerCol, direction: direction)

        guard isInside(row: next.row, col: next.col) else {
            message = "おっと！壁で行き止まりだ。"
            return
        }

        if map[next.row][next.col] == 0 {
            message = "おっと！壁で行き止まりだ。"
            return
        }

        playerRow = next.row
        playerCol = next.col

        if map[next.row][next.col] == 3 {
            message = "ゴールに到達した！"
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                isClear = true
            }
            return
        }

        message = "足音が響いている……"
    }

    // ========================================================
    // MARK: - 左旋回
    // ========================================================
    private func turnLeft() {
        let newValue = (direction.rawValue + 3) % 4
        direction = Direction(rawValue: newValue)!
        message = "左を向いた。"
    }

    // ========================================================
    // MARK: - 右旋回
    // ========================================================
    private func turnRight() {
        let newValue = (direction.rawValue + 1) % 4
        direction = Direction(rawValue: newValue)!
        message = "右を向いた。"
    }

    // ========================================================
    // MARK: - マップ内判定
    // ========================================================
    private func isInside(row: Int, col: Int) -> Bool {
        row >= 0 && row < map.count && col >= 0 && col < map[row].count
    }

    // ========================================================
    // MARK: - 座標計算
    // ========================================================
    private func position(
        fromRow row: Int,
        fromCol col: Int,
        direction: Direction
    ) -> (row: Int, col: Int) {
        switch direction {
        case .north: return (row - 1, col)
        case .east: return (row, col + 1)
        case .south: return (row + 1, col)
        case .west: return (row, col - 1)
        }
    }

    // ========================================================
    // MARK: - ミニマップ
    // ========================================================
    private var miniMap: some View {
        VStack(spacing: 1) {
            ForEach(0..<map.count, id: \.self) { row in
                HStack(spacing: 1) {
                    ForEach(0..<map[row].count, id: \.self) { col in
                        miniMapCell(row: row, col: col)
                    }
                }
            }
        }
        .padding(5)
        .background(Color.white.opacity(0.05))
    }

    // ========================================================
    // MARK: - ミニマップの1マス
    // ========================================================
    @ViewBuilder
    private func miniMapCell(row: Int, col: Int) -> some View {
        let value = map[row][col]

        ZStack {
            if value == 0 {
                Rectangle().fill(Color.black)
            } else {
                Rectangle().fill(Color.white)
            }

            if value == 3 {
                Rectangle().fill(Color.red)
                Text("G")
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .foregroundStyle(.white)
            }

            if value == 2 {
                Rectangle().fill(Color.green)
                Text("S")
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .foregroundStyle(.white)
            }

            if playerRow == row && playerCol == col {
                Rectangle().fill(Color.blue)
                Text(direction.symbol)
                    .font(.system(size: 10))
                    .foregroundStyle(.white)
            }
        }
        .frame(width: 18, height: 18)
        .overlay(Rectangle().stroke(Color.gray.opacity(0.3), lineWidth: 0.5))
    }

    // ========================================================
    // MARK: - クリア画面
    // ========================================================
    private var clearOverlay: some View {
        ZStack {
            Color.black.opacity(0.94).ignoresSafeArea()

            VStack(spacing: 25) {
                Text("EXPLORATION")
                    .font(.system(size: 20, weight: .bold, design: .monospaced))
                    .foregroundStyle(.green)

                Text("探索成功！")
                    .font(.system(size: 36, weight: .bold, design: .monospaced))
                    .foregroundStyle(.white)

                Text("GOALに到達しました")
                    .font(.system(size: 16, design: .monospaced))
                    .foregroundStyle(.gray)

                Button {
                    resetGame()
                } label: {
                    Text("もう一度探索する")
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                        .foregroundStyle(.black)
                        .padding()
                        .background(Color.green)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
        }
    }

    // ========================================================
    // MARK: - ゲームリセット
    // ========================================================
    private func resetGame() {
        playerRow = 6
        playerCol = 4
        direction = .north
        message = "探索を開始します。"
        isClear = false
    }
}

// ====================================================================
// MARK: - 3Dダンジョン表示
// ====================================================================
// プレイヤーから見える前方4マスを、距離に応じて小さくなる
// 複数の四角形として描画します。
//
// 今回の追加機能：
// ・左側が壁なら左壁を描画
// ・左側が通路なら「左へ続く横道」を描画
// ・右側も同様に判定
// ====================================================================

struct Dungeon3DView: View {
    let map: [[Int]]
    let playerRow: Int
    let playerCol: Int
    let direction: ContentView.Direction
    let viewDepth: Int

    var body: some View {
        Canvas { context, size in
            drawDungeon(context: &context, size: size)
        }
        .background(Color.black)
        .overlay(Rectangle().stroke(Color.white.opacity(0.8), lineWidth: 2))
    }

    // ========================================================
    // MARK: - ダンジョン描画
    // ========================================================
    private func drawDungeon(context: inout GraphicsContext, size: CGSize) {
        drawBackgroundGrid(context: &context, size: size)

        // 奥から手前へ描画して、近い壁が遠い部分を隠すようにします。
        for depth in stride(from: viewDepth, through: 1, by: -1) {
            drawDepthLayer(context: &context, size: size, depth: depth)
        }

        let front = cellAtDistance(1)

        if front == 3 {
            drawText(
                context: &context,
                text: "GOAL",
                point: CGPoint(x: size.width / 2, y: size.height / 2),
                fontSize: 26
            )
        } else if front == 0 {
            drawText(
                context: &context,
                text: "前方：壁面",
                point: CGPoint(x: size.width / 2, y: 25),
                fontSize: 17
            )
        } else {
            drawText(
                context: &context,
                text: "前方：通路",
                point: CGPoint(x: size.width / 2, y: 25),
                fontSize: 17
            )
        }
    }

    // ========================================================
    // MARK: - 背景グリッド
    // ========================================================
    private func drawBackgroundGrid(context: inout GraphicsContext, size: CGSize) {
        let centerX = size.width / 2
        let centerY = size.height / 2

        drawLine(
            context: &context,
            from: CGPoint(x: 0, y: 0),
            to: CGPoint(x: centerX, y: centerY)
        )
        drawLine(
            context: &context,
            from: CGPoint(x: size.width, y: 0),
            to: CGPoint(x: centerX, y: centerY)
        )
        drawLine(
            context: &context,
            from: CGPoint(x: 0, y: size.height),
            to: CGPoint(x: centerX, y: centerY)
        )
        drawLine(
            context: &context,
            from: CGPoint(x: size.width, y: size.height),
            to: CGPoint(x: centerX, y: centerY)
        )
    }

    // ========================================================
    // MARK: - 距離ごとの描画
    // ========================================================
    private func drawDepthLayer(
        context: inout GraphicsContext,
        size: CGSize,
        depth: Int
    ) {
        let value = cellAtDistance(depth)

        let ratio = CGFloat(depth) / CGFloat(viewDepth + 1)

        let left = size.width * (0.06 + ratio * 0.36)
        let right = size.width * (0.94 - ratio * 0.36)
        let top = size.height * (0.10 + ratio * 0.32)
        let bottom = size.height * (0.90 - ratio * 0.32)

        let rect = CGRect(
            x: left,
            y: top,
            width: right - left,
            height: bottom - top
        )

        // 現在の深さのマスが壁なら、正面の壁を描いて終了します。
        // 壁の向こう側は見えないため、左右の通路も描きません。
        if value == 0 {
            drawFrontWall(context: &context, rect: rect)
            return
        }

        // 左右の状態を判定します。
        let leftWall = isSideWall(depth: depth, side: .left)
        let rightWall = isSideWall(depth: depth, side: .right)

        // 左側が壁なら壁、通路なら横道を描きます。
        if leftWall {
            drawLeftWall(context: &context, size: size, rect: rect)
        } else {
            drawLeftOpening(
                context: &context,
                size: size,
                rect: rect,
                depth: depth
            )
        }

        // 右側も同じ考え方で描画します。
        if rightWall {
            drawRightWall(context: &context, size: size, rect: rect)
        } else {
            drawRightOpening(
                context: &context,
                size: size,
                rect: rect,
                depth: depth
            )
        }

        // 通路の奥行きを示す四角形を描きます。
        drawDepthRectangle(context: &context, rect: rect)

        // Gなら、その位置にGを表示します。
        if value == 3 {
            drawText(
                context: &context,
                text: "G",
                point: CGPoint(x: rect.midX, y: rect.midY),
                fontSize: max(12, 32 - CGFloat(depth * 5))
            )
        }
    }

    // ========================================================
    // MARK: - 距離からマップ値を取得
    // ========================================================
    private func cellAtDistance(_ depth: Int) -> Int {
        var row = playerRow
        var col = playerCol

        for _ in 0..<depth {
            let next = nextPosition(row: row, col: col, direction: direction)
            row = next.row
            col = next.col
        }

        guard row >= 0,
              row < map.count,
              col >= 0,
              col < map[row].count else {
            return 0
        }

        return map[row][col]
    }

    // ========================================================
    // MARK: - 次の座標
    // ========================================================
    private func nextPosition(
        row: Int,
        col: Int,
        direction: ContentView.Direction
    ) -> (row: Int, col: Int) {
        switch direction {
        case .north: return (row - 1, col)
        case .east: return (row, col + 1)
        case .south: return (row + 1, col)
        case .west: return (row, col - 1)
        }
    }

    // ========================================================
    // MARK: - 左右の壁 / 通路を判定
    // ========================================================
    private enum Side {
        case left
        case right
    }

    private func isSideWall(depth: Int, side: Side) -> Bool {
        // まず「depthマス先」の現在位置を取得します。
        var row = playerRow
        var col = playerCol

        for _ in 0..<depth {
            let next = nextPosition(row: row, col: col, direction: direction)
            row = next.row
            col = next.col
        }

        // その地点から左または右を向きます。
        let sideDirection: ContentView.Direction
        switch side {
        case .left:
            sideDirection = turnLeftDirection(direction)
        case .right:
            sideDirection = turnRightDirection(direction)
        }

        let sidePosition = nextPosition(
            row: row,
            col: col,
            direction: sideDirection
        )

        // マップ外は壁として扱います。
        guard sidePosition.row >= 0,
              sidePosition.row < map.count,
              sidePosition.col >= 0,
              sidePosition.col < map[sidePosition.row].count else {
            return true
        }

        // 0なら壁、それ以外なら通路側として扱います。
        return map[sidePosition.row][sidePosition.col] == 0
    }

    // ========================================================
    // MARK: - 左方向
    // ========================================================
    private func turnLeftDirection(_ direction: ContentView.Direction) -> ContentView.Direction {
        ContentView.Direction(rawValue: (direction.rawValue + 3) % 4)!
    }

    // ========================================================
    // MARK: - 右方向
    // ========================================================
    private func turnRightDirection(_ direction: ContentView.Direction) -> ContentView.Direction {
        ContentView.Direction(rawValue: (direction.rawValue + 1) % 4)!
    }

    // ========================================================
    // MARK: - 通路の奥行き四角形
    // ========================================================
    private func drawDepthRectangle(
        context: inout GraphicsContext,
        rect: CGRect
    ) {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()

        context.stroke(
            path,
            with: .color(Color.white.opacity(0.8)),
            lineWidth: 1.5
        )
    }

    // ========================================================
    // MARK: - 正面の壁
    // ========================================================
    private func drawFrontWall(
        context: inout GraphicsContext,
        rect: CGRect
    ) {
        var path = Path()
        path.addRect(rect)

        context.stroke(path, with: .color(.white), lineWidth: 2)
    }

    // ========================================================
    // MARK: - 左壁
    // ========================================================
    private func drawLeftWall(
        context: inout GraphicsContext,
        size: CGSize,
        rect: CGRect
    ) {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: 0, y: size.height))

        context.stroke(
            path,
            with: .color(Color.white.opacity(0.8)),
            lineWidth: 2
        )
    }

    // ========================================================
    // MARK: - 右壁
    // ========================================================
    private func drawRightWall(
        context: inout GraphicsContext,
        size: CGSize,
        rect: CGRect
    ) {
        var path = Path()
        path.move(to: CGPoint(x: size.width, y: 0))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: size.width, y: size.height))

        context.stroke(
            path,
            with: .color(Color.white.opacity(0.8)),
            lineWidth: 2
        )
    }

    // ========================================================
    // MARK: - 左側の通路入口
    // ========================================================
    // 左側が壁ではなく通路の場合、壁の一部が開いて
    // 「左へ曲がれる横道」が見えるように描画します。
    // ========================================================
    private func drawLeftOpening(
        context: inout GraphicsContext,
        size: CGSize,
        rect: CGRect,
        depth: Int
    ) {
        let scale = max(0.25, 1.0 - CGFloat(depth) * 0.12)
        let openingX = rect.minX
        let openingTop = rect.minY
        let openingBottom = rect.maxY
        let corridorLength = size.width * 0.25 * scale

        // 横道の上側の線
        drawLine(
            context: &context,
            from: CGPoint(x: openingX, y: openingTop),
            to: CGPoint(
                x: openingX - corridorLength,
                y: openingTop - corridorLength * 0.25
            )
        )

        // 横道の下側の線
        drawLine(
            context: &context,
            from: CGPoint(x: openingX, y: openingBottom),
            to: CGPoint(
                x: openingX - corridorLength,
                y: openingBottom + corridorLength * 0.25
            )
        )

        // 横道の奥を示す縦線
        drawLine(
            context: &context,
            from: CGPoint(
                x: openingX - corridorLength,
                y: openingTop - corridorLength * 0.25
            ),
            to: CGPoint(
                x: openingX - corridorLength,
                y: openingBottom + corridorLength * 0.25
            )
        )
    }

    // ========================================================
    // MARK: - 右側の通路入口
    // ========================================================
    private func drawRightOpening(
        context: inout GraphicsContext,
        size: CGSize,
        rect: CGRect,
        depth: Int
    ) {
        let scale = max(0.25, 1.0 - CGFloat(depth) * 0.12)
        let openingX = rect.maxX
        let openingTop = rect.minY
        let openingBottom = rect.maxY
        let corridorLength = size.width * 0.25 * scale

        // 横道の上側の線
        drawLine(
            context: &context,
            from: CGPoint(x: openingX, y: openingTop),
            to: CGPoint(
                x: openingX + corridorLength,
                y: openingTop - corridorLength * 0.25
            )
        )

        // 横道の下側の線
        drawLine(
            context: &context,
            from: CGPoint(x: openingX, y: openingBottom),
            to: CGPoint(
                x: openingX + corridorLength,
                y: openingBottom + corridorLength * 0.25
            )
        )

        // 横道の奥を示す縦線
        drawLine(
            context: &context,
            from: CGPoint(
                x: openingX + corridorLength,
                y: openingTop - corridorLength * 0.25
            ),
            to: CGPoint(
                x: openingX + corridorLength,
                y: openingBottom + corridorLength * 0.25
            )
        )
    }

    // ========================================================
    // MARK: - 線を描く
    // ========================================================
    private func drawLine(
        context: inout GraphicsContext,
        from: CGPoint,
        to: CGPoint
    ) {
        var path = Path()
        path.move(to: from)
        path.addLine(to: to)

        context.stroke(
            path,
            with: .color(Color.white.opacity(0.45)),
            lineWidth: 1
        )
    }

    // ========================================================
    // MARK: - テキストを描く
    // ========================================================
    private func drawText(
        context: inout GraphicsContext,
        text: String,
        point: CGPoint,
        fontSize: CGFloat
    ) {
        let resolvedText = context.resolve(
            Text(text)
                .font(.system(size: fontSize, weight: .bold, design: .monospaced))
                .foregroundStyle(.green)
        )

        context.draw(resolvedText, at: point, anchor: .center)
    }
}

// ================================================================
// Preview
// ================================================================
#Preview {
    ContentView()
}
