import SwiftUI

// MARK: - 3D描画ビュー(透視投影で壁を奥から手前へ描く)
struct DungeonView: View {
    /// (d, i) = (前へdマス, 右へiマス) が壁かどうか
    let isWall: (Int, Int) -> Bool
    let maxDepth = 5

    var body: some View {
        Canvas { ctx, size in
            let f = Double(size.width) / 2          // 画面の半幅。近い横壁が画面端に届く値
            let cx = Double(size.width) / 2
            let cy = Double(size.height) / 2

            // 3D点(X:横, Y:高さ, Z:奥行き) → 画面座標
            func P(_ X: Double, _ Y: Double, _ Z: Double) -> CGPoint {
                CGPoint(x: cx + f * X / Z, y: cy - f * Y / Z)
            }
            // 黒で塗りつぶして白線で縁取り(奥の線を隠すため)
            func quad(_ pts: [CGPoint]) {
                var path = Path()
                path.move(to: pts[0])
                for p in pts.dropFirst() { path.addLine(to: p) }
                path.closeSubpath()
                ctx.fill(path, with: .color(.black))
                ctx.stroke(path, with: .color(.white), lineWidth: 2)
            }

            // 正面が壁に当たる深さまでを描画対象にする
            var depth = 0
            while depth < maxDepth && !isWall(depth + 1, 0) { depth += 1 }

            // 奥 → 手前、外側 → 中央 の順に描く(画家のアルゴリズム)
            for d in stride(from: depth, through: 0, by: -1) {
                for i in [-2, 2, -1, 1, 0] {
                    if isWall(d, i) { continue }
                    let z0 = Double(d) + 0.5
                    let z1 = Double(d) + 1.5
                    let xl = Double(i) - 0.5
                    let xr = Double(i) + 0.5

                    // 正面の壁
                    if isWall(d + 1, i) {
                        quad([P(xl, 0.5, z1), P(xr, 0.5, z1), P(xr, -0.5, z1), P(xl, -0.5, z1)])
                    }
                    // 左の壁
                    if isWall(d, i - 1) {
                        quad([P(xl, 0.5, z0), P(xl, 0.5, z1), P(xl, -0.5, z1), P(xl, -0.5, z0)])
                    }
                    // 右の壁
                    if isWall(d, i + 1) {
                        quad([P(xr, 0.5, z0), P(xr, 0.5, z1), P(xr, -0.5, z1), P(xr, -0.5, z0)])
                    }
                }
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .background(Color.black)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.8), lineWidth: 2))
    }
}
