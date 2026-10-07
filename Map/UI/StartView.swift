import SwiftUI

/// スタート画面(仕様書§13.3、UI仕様書§13)。面を選んで開始する
struct StartView: View {
    /// 選べる面の一覧(表示順)
    let stages: [Stage]
    /// 面が選ばれたときの処理
    let onSelect: (Stage) -> Void

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            // 飾りの廊下のマーク
            CorridorIcon()

            Text("Dungeon Game")
                .font(.system(size: 40, weight: .bold))
                .tracking(1)
                .foregroundColor(.white)
                .padding(.bottom, 24)

            Text("前進は1マス、左右は向きを変える操作です。\n鍵を取ってゴールへ進みましょう。")
                .font(.system(size: 14))
                .multilineTextAlignment(.center)
                .foregroundColor(.white.opacity(0.85))
                .frame(maxWidth: 320)

            // 面を選ぶボタン(コマンドボタンと同じ様式)
            VStack(spacing: 24) {
                ForEach(stages.indices, id: \.self) { index in
                    let stage = stages[index]
                    Button {
                        onSelect(stage)
                    } label: {
                        Text(stage.title)
                            .font(.system(size: 18, weight: .bold))
                            .frame(maxWidth: .infinity, minHeight: 56)
                            .background(Color.black)
                            .foregroundColor(.white)
                            .overlay(Rectangle().stroke(Color.white, lineWidth: 2))
                    }
                }
            }
            .frame(maxWidth: 320)

            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.ignoresSafeArea())
    }
}

/// スタート画面の飾り。廊下を、ワイヤーフレームで小さく描いたマーク
private struct CorridorIcon: View {
    var body: some View {
        Canvas { ctx, size in
            let s = size.width

            // 0〜1の座標を、画面上の点に直す
            func pt(_ x: Double, _ y: Double) -> CGPoint {
                CGPoint(x: s * x, y: s * y)
            }
            // 黒で塗りつぶして白線で縁取り(3D表示と同じ描き方)
            func quad(_ pts: [(Double, Double)]) {
                var path = Path()
                path.move(to: pt(pts[0].0, pts[0].1))
                for p in pts.dropFirst() { path.addLine(to: pt(p.0, p.1)) }
                path.closeSubpath()
                ctx.fill(path, with: .color(.black))
                ctx.stroke(path, with: .color(.white), lineWidth: 2)
            }

            let a = 1.0 / 3.0
            let b = 2.0 / 3.0
            quad([(0, 0), (a, a), (a, b), (0, 1)])      // 左の壁
            quad([(1, 0), (b, a), (b, b), (1, 1)])      // 右の壁
            quad([(a, a), (b, a), (b, b), (a, b)])      // 正面の壁
        }
        .frame(width: 96, height: 96)
        .accessibilityHidden(true)
    }
}
