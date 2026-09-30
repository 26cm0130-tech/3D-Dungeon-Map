import SwiftUI

/// ③ コマンド表示(左旋回・前進・右旋回、ギブアップ)
struct CommandView: View {
    let onTurnLeft: () -> Void
    let onForward: () -> Void
    let onTurnRight: () -> Void
    /// ギブアップが押されたときの処理(確認の表示は、呼び出し側で行う)
    let onGiveUp: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            // 移動用の3つのボタン(同じ大きさで横に並べる)
            HStack(spacing: 8) {
                commandButton("左旋回", onTurnLeft)
                commandButton("前進", onForward)
                commandButton("右旋回", onTurnRight)
            }

            // ギブアップは、押し間違えにくいように、移動用ボタンとは別の位置に小さく置く
            HStack {
                Spacer()
                Button(action: onGiveUp) {
                    Text("ギブアップ")
                        .font(.system(size: 14, weight: .bold))
                        .frame(width: 120, height: 36)
                        .background(Color.black)
                        .foregroundColor(Color.white.opacity(0.8))
                        .overlay(Rectangle().stroke(Color.white.opacity(0.6), lineWidth: 1))
                }
            }
        }
    }

    private func commandButton(_ title: String, _ action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 18, weight: .bold))
                .frame(maxWidth: .infinity, minHeight: 56)
                .background(Color.black)
                .foregroundColor(.white)
                .overlay(Rectangle().stroke(Color.white, lineWidth: 2))
        }
    }
}
