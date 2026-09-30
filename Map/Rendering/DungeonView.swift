import SwiftUI

// MARK: - 3D描画ビュー(透視投影で壁を奥から手前へ描く)
struct DungeonView: View {
    /// 3D描画に必要なマップとプレイヤー状態を、値のまま直接受け取る。
    /// (関数ではなく値で受け取ることで、位置や向きが変わるたびに SwiftUI が再描画する)
    let map: MapData
    let player: Player

    /// 描画する最大の奥行き(マス数)。仕様書§12.5
    let maxDepth = 5

    /// 視点相対(前へd、右へi)のマスが壁か。
    /// プレイヤーの向きに合わせて、相対位置をマップ上の絶対座標へ変換して調べる
    private func isWallRelative(_ d: Int, _ i: Int) -> Bool {
        let forward = player.direction          // 前方向
        let right = forward.turnedRight         // 右方向

        let x = player.position.x
            + forward.dx * d
            + right.dx * i
        let y = player.position.y
            + forward.dy * d
            + right.dy * i

        return map.isWall(x: x, y: y)
    }

    var body: some View {
        Canvas { ctx, size in
            let f = Double(size.width) / 2          // 画面の半幅。近い横壁が画面端に届く値
            let cx = Double(size.width) / 2         // 画面中央のx
            let cy = Double(size.height) / 2        // 画面中央のy

            // 3D点(X:横, Y:高さ, Z:奥行き) → 画面座標
            func P(_ X: Double, _ Y: Double, _ Z: Double) -> CGPoint {
                CGPoint(x: cx + f * X / Z, y: cy - f * Y / Z)
            }

            // 黒で塗りつぶして白線で縁取り(奥の線を手前の壁で隠すため)
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
            while depth < maxDepth && !isWallRelative(depth + 1, 0) {
                depth += 1
            }

            // 奥 → 手前、外側 → 中央 の順に描く(画家のアルゴリズム)
            for d in stride(from: depth, through: 0, by: -1) {
                for i in [-2, 2, -1, 1, 0] {
                    // 壁のマスは、中に立てないので描かない
                    if isWallRelative(d, i) { continue }

                    let z0 = Double(d) + 0.5    // このマスの手前側の奥行き
                    let z1 = Double(d) + 1.5    // このマスの奥側の奥行き
                    let xl = Double(i) - 0.5    // このマスの左端の横位置
                    let xr = Double(i) + 0.5    // このマスの右端の横位置

                    // 正面の壁
                    if isWallRelative(d + 1, i) {
                        quad([
                            P(xl, 0.5, z1), P(xr, 0.5, z1),
                            P(xr, -0.5, z1), P(xl, -0.5, z1)
                        ])
                    }

                    // 左の壁
                    if isWallRelative(d, i - 1) {
                        quad([
                            P(xl, 0.5, z0), P(xl, 0.5, z1),
                            P(xl, -0.5, z1), P(xl, -0.5, z0)
                        ])
                    }

                    // 右の壁
                    if isWallRelative(d, i + 1) {
                        quad([
                            P(xr, 0.5, z0), P(xr, 0.5, z1),
                            P(xr, -0.5, z1), P(xr, -0.5, z0)
                        ])
                    }
                }
            }
        }
        .aspectRatio(1, contentMode: .fit)          // 3D表示領域は正方形(仕様書§12.6)
        .background(Color.black)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.8), lineWidth: 2))
    }
}
