import SwiftUI

/// ③ コマンド表示(左旋回・前進・右旋回、ギブアップ)
struct CommandView: View {
    let onTurnLeft: () -> Void
    let onForward: () -> Void
    let onTurnRight: () -> Void
    /// ギブアップが押されたときの処理(確認の表示は、呼び出し側で行う)
    let onGiveUp: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            // 移動用の3つのボタン(同じ大きさで横に並べる)
            HStack(spacing: 8) {
                commandButton("左旋回", onTurnLeft)
                commandButton("前進", onForward)
                commandButton("右旋回", onTurnRight)
            }

            // ギブアップは、押し間違えにくいように、移動用ボタンとは別の位置に小さく置く(高さは、指で押しやすい44)
            HStack {
                Spacer()
                Button(action: onGiveUp) {
                    Text("ギブアップ")
                        .font(.system(size: 14, weight: .bold))
                        .frame(width: 120, height: 44)
                }
                .buttonStyle(DungeonPressButtonStyle())
            }
        }
    }

    private func commandButton(_ title: String, _ action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 18, weight: .bold))
                .frame(maxWidth: .infinity, minHeight: 56)
        }
        .buttonStyle(DungeonPressButtonStyle())
    }
}

/// 押している間だけ色・枠・大きさを変え、操作を受け付けたことを伝える。
struct DungeonPressButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                configuration.isPressed
                    ? Color(red: 0.12, green: 0.43, blue: 0.19)
                    : Color(red: 0.075, green: 0.07, blue: 0.06)
            )
            .foregroundColor(configuration.isPressed ? .white : Color.white.opacity(0.9))
            .overlay {
                Rectangle()
                    .stroke(
                        configuration.isPressed
                            ? Color(red: 0.84, green: 0.75, blue: 0.48)
                            : Color(red: 0.58, green: 0.54, blue: 0.45).opacity(0.9),
                        lineWidth: configuration.isPressed ? 2.5 : 1.5
                    )
            }
            .contentShape(Rectangle())
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .animation(.easeOut(duration: 0.09), value: configuration.isPressed)
    }
}
