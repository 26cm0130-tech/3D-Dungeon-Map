import SwiftUI

// MARK: - オートマップ(探索済みのマスだけを表示)
struct AutoMapView: View {
    let map: MapData
    let explored: Set<GridPos>
    let traps: [GridPos: TrapKind]
    let player: Player

    var body: some View {
        Canvas { ctx, size in
            let cols = map.cols
            let rows = map.rows
            let cell = min(size.width / CGFloat(cols), size.height / CGFloat(rows))
            let ox = (size.width - cell * CGFloat(cols)) / 2
            let oy = (size.height - cell * CGFloat(rows)) / 2

            func origin(_ x: Int, _ y: Int) -> CGPoint {
                CGPoint(x: ox + cell * CGFloat(x), y: oy + cell * CGFloat(y))
            }
            let sides: [(dx: Int, dy: Int)] = [(0, -1), (1, 0), (0, 1), (-1, 0)]

            for pos in explored {
                let o = origin(pos.x, pos.y)
                let r = CGRect(x: o.x, y: o.y, width: cell, height: cell)

                // 探索済みの床
                ctx.fill(Path(r), with: .color(Color.white.opacity(0.12)))

                // 確認済みの壁(そのマスの四辺のうち、隣が壁の辺)
                for k in 0..<4 {
                    let n = sides[k]
                    guard map.isWall(x: pos.x + n.dx, y: pos.y + n.dy) else { continue }
                    var p = Path()
                    switch k {
                    case 0:
                        p.move(to: CGPoint(x: r.minX, y: r.minY))
                        p.addLine(to: CGPoint(x: r.maxX, y: r.minY))
                    case 1:
                        p.move(to: CGPoint(x: r.maxX, y: r.minY))
                        p.addLine(to: CGPoint(x: r.maxX, y: r.maxY))
                    case 2:
                        p.move(to: CGPoint(x: r.minX, y: r.maxY))
                        p.addLine(to: CGPoint(x: r.maxX, y: r.maxY))
                    default:
                        p.move(to: CGPoint(x: r.minX, y: r.minY))
                        p.addLine(to: CGPoint(x: r.minX, y: r.maxY))
                    }
                    ctx.stroke(p, with: .color(.white), lineWidth: 2)
                }

                // 到達済みの特殊マスだけ記号を表示(未到達のT/K/Gは出さない)
                let symbol = traps[pos]?.mapSymbol ?? map.cell(at: pos).mapSymbol
                if let symbol, pos != player.position {
                    ctx.draw(
                        Text(symbol)
                            .font(.system(size: cell * 0.6, weight: .bold))
                            .foregroundColor(.white),
                        at: CGPoint(x: r.midX, y: r.midY)
                    )
                }
            }

            // プレイヤー(向きを示す三角形)
            let po = origin(player.position.x, player.position.y)
            let c = CGPoint(x: po.x + cell / 2, y: po.y + cell / 2)
            let s = Double(cell) * 0.38
            let theta = Double(player.direction.rawValue) * Double.pi / 2
            let base: [(Double, Double)] = [(0, -1), (-0.8, 0.8), (0.8, 0.8)]
            var tri = Path()
            for (idx, b) in base.enumerated() {
                let bx = b.0 * s
                let by = b.1 * s
                let qx = Double(c.x) + bx * cos(theta) - by * sin(theta)
                let qy = Double(c.y) + bx * sin(theta) + by * cos(theta)
                if idx == 0 {
                    tri.move(to: CGPoint(x: qx, y: qy))
                } else {
                    tri.addLine(to: CGPoint(x: qx, y: qy))
                }
            }
            tri.closeSubpath()
            ctx.fill(tri, with: .color(.white))
        }
        .background(Color.black)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.8), lineWidth: 2))
    }
}
