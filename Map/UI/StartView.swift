import SwiftUI

/// スタート画面。石造りの門と古い金色の装飾で、クラシックな迷宮RPGの雰囲気を表現する。
struct StartView: View {
    /// 選べる面の一覧(表示順)
    let stages: [Stage]
    /// 面が選ばれたときの処理
    let onSelect: (Stage) -> Void

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.12, green: 0.105, blue: 0.085), .black, Color(red: 0.07, green: 0.065, blue: 0.055)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 19) {
                    DungeonGateEmblem()
                        .frame(width: 148, height: 132)
                        .padding(.top, 28)

                    VStack(spacing: 0) {
                        Text("What's gathered?")
                            .font(.system(size: 32, weight: .bold, design: .serif))
                            .minimumScaleFactor(0.85)
                            .lineLimit(1)
                        Text("Run!")
                            .font(.system(size: 58, weight: .heavy, design: .serif))
                            .padding(.top, -5)
                        Text("ワギャラン")
                            .font(.system(size: 22, weight: .semibold, design: .serif))
                            .tracking(4)
                            .padding(.top, 1)
                    }
                    .foregroundStyle(Color(red: 0.89, green: 0.78, blue: 0.49))
                    .accessibilityElement(children: .combine)

                    Rectangle()
                        .fill(Color(red: 0.64, green: 0.52, blue: 0.29).opacity(0.8))
                        .frame(width: 230, height: 1.5)
                        .padding(.vertical, 5)

                    Text("ファミコン時代の\nWizardry・女神転生を思わせる、\nグリッド型の3Dダンジョン探索ゲーム")
                        .font(.system(size: 15, weight: .medium, design: .serif))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Color.white.opacity(0.84))
                        .frame(maxWidth: 340)

                    Text("前進は1マス、左右は向きを変える操作です。\n鍵を取ってゴールへ進みましょう。")
                        .font(.system(size: 14, weight: .medium, design: .serif))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Color.white.opacity(0.85))
                        .frame(maxWidth: 320)

                    // 面を選ぶボタン(コマンドボタンと同じ様式)
                    VStack(spacing: 16) {
                        ForEach(stages.indices, id: \.self) { index in
                            let stage = stages[index]
                            Button {
                                onSelect(stage)
                            } label: {
                                Text(stage.title)
                                    .font(.system(size: 20, weight: .bold, design: .serif))
                                    .frame(maxWidth: .infinity, minHeight: 60)
                            }
                            .buttonStyle(DungeonPressButtonStyle())
                        }
                    }
                    .frame(maxWidth: 320)
                    .padding(.top, 3)
                    .padding(.bottom, 24)
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 26)
            }

            // 古い石碑を思わせる二重の金縁
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(red: 0.67, green: 0.57, blue: 0.36).opacity(0.65), lineWidth: 1)
                .padding(8)
                .allowsHitTesting(false)
            RoundedRectangle(cornerRadius: 9)
                .stroke(Color.white.opacity(0.12), lineWidth: 1)
                .padding(13)
                .allowsHitTesting(false)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .preferredColorScheme(.dark)
    }
}

/// 石積みのアーチ門と、門に刻まれた小さな紋章を描く。
private struct DungeonGateEmblem: View {
    private let gold = Color(red: 0.77, green: 0.66, blue: 0.42)

    var body: some View {
        Canvas { context, size in
            let scale = min(size.width / 120, size.height / 108)
            let offset = CGPoint(x: (size.width - 120 * scale) / 2, y: (size.height - 108 * scale) / 2)

            func rect(_ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat) -> CGRect {
                CGRect(x: offset.x + x * scale, y: offset.y + y * scale, width: width * scale, height: height * scale)
            }
            func point(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
                CGPoint(x: offset.x + x * scale, y: offset.y + y * scale)
            }

            // 門を囲む石壁
            context.fill(Path(roundedRect: rect(5, 5, 110, 98), cornerRadius: 5 * scale), with: .color(Color(red: 0.20, green: 0.18, blue: 0.15)))
            for row in 0..<5 {
                let y = CGFloat(9 + row * 19)
                let shift: CGFloat = row.isMultiple(of: 2) ? 0 : 10
                for column in 0..<4 {
                    let x = CGFloat(8 + column * 28) - shift
                    let stone = Path(roundedRect: rect(x, y, 25, 16), cornerRadius: 2 * scale)
                    let shade = 0.22 + Double((row * 3 + column) % 5) * 0.025
                    context.fill(stone, with: .color(Color(red: shade, green: shade * 0.93, blue: shade * 0.82)))
                    context.stroke(stone, with: .color(gold.opacity(0.24)), lineWidth: 0.7 * scale)
                }
            }

            // アーチ状の暗い開口部
            var arch = Path()
            arch.move(to: point(17, 96))
            arch.addLine(to: point(17, 39))
            arch.addQuadCurve(to: point(103, 39), control: point(60, 0))
            arch.addLine(to: point(103, 96))
            arch.closeSubpath()
            context.fill(arch, with: .color(Color(red: 0.045, green: 0.035, blue: 0.027)))
            context.stroke(arch, with: .color(gold), lineWidth: 2 * scale)

            // 閉ざされた扉と木板の縁取り
            let door = Path(roundedRect: rect(27, 48, 66, 48), cornerRadius: 2 * scale)
            context.stroke(door, with: .color(gold.opacity(0.74)), lineWidth: 1.4 * scale)
            for x in [CGFloat(39), 52, 68, 81] {
                var plank = Path()
                plank.move(to: point(x, 51))
                plank.addLine(to: point(x, 93))
                context.stroke(plank, with: .color(gold.opacity(0.36)), lineWidth: 0.8 * scale)
            }

            // 扉の中央に控えめな紋章
            var sigil = Path()
            sigil.move(to: point(60, 57))
            sigil.addLine(to: point(67, 64))
            sigil.addLine(to: point(60, 71))
            sigil.addLine(to: point(53, 64))
            sigil.closeSubpath()
            context.stroke(sigil, with: .color(gold), lineWidth: 1.2 * scale)
        }
        .accessibilityHidden(true)
    }
}
